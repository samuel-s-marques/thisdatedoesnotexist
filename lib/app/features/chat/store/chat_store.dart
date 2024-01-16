import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/core/models/message_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';
import 'package:thisdatedoesnotexist/app/core/services/cache_service.dart';
import 'package:thisdatedoesnotexist/app/core/services/dio_service.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/chat/models/chat_model.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/chat_state_enum.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_type_enum.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'chat_store.g.dart';

class ChatStore = ChatStoreBase with _$ChatStore;

abstract class ChatStoreBase with Store {
  AuthService authService = AuthService();
  User? authenticatedUser;
  Uuid uuid = const Uuid();
  String server = const String.fromEnvironment('SERVER');
  String wssServer = const String.fromEnvironment('WSS_SERVER');
  final DioService dio = DioService();
  WebSocketChannel? channel;
  BuildContext? buildContext;
  Timer? timer;
  bool requestedChats = false;
  bool firstRequest = false;
  ScrollController scrollController = ScrollController();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  TextEditingController messageController = TextEditingController();
  CacheService cacheService = CacheService();

  @computed
  ChatState get state => getChatState();

  @observable
  bool isLoading = false;

  ChatState getChatState() {
    if (isLoading) {
      return ChatState.loading;
    } else if (errorMessage != null) {
      return ChatState.error;
    } else if (messages.isNotEmpty) {
      return ChatState.idle;
    } else if (isLoading) {
      return ChatState.loading;
    } else if (messages.isEmpty) {
      return ChatState.empty;
    }

    return ChatState.loading;
  }

  @observable
  bool areChatsLoading = true;

  @observable
  bool showScrollToBottom = false;

  @observable
  ScrollDirection lastScrollDirection = ScrollDirection.idle;

  @observable
  int availablePages = 1;

  @observable
  int currentPage = 1;

  @observable
  UserModel? character;

  @observable
  String? errorMessage;

  @observable
  ObservableList<ChatModel> chats = ObservableList();

  @observable
  ObservableList<Message> messages = ObservableList();

  @action
  void setLastScrollDirection(ScrollDirection scrollDirection) {
    lastScrollDirection = scrollDirection;
  }

  @action
  Future<void> handleEndReached(String uid) async {
    if (availablePages >= currentPage) {
      final List<Message> newMessages = await getMessages(uid, currentPage, (updatedAvailablePages) {
        availablePages = updatedAvailablePages;
      });

      final List<Message> updatedMessages = [...newMessages, ...messages];
      messages = ObservableList.of(updatedMessages);
      currentPage++;
    }

    isLoading = false;
  }

  @action
  void _addMessage(Message message) {
    channel!.sink.add(
      jsonEncode(
        {
          'type': 'text',
          'room_uid': character?.uid,
          'message': message.toMap(),
        },
      ),
    );
  }

  void onChanged(String? value) {
    cacheService.saveData('${character?.uid}-chat', value);
  }

  @action
  void onSendTap() {
    if (messageController.text.isEmpty) {
      return;
    }

    final Message newMessage = Message(
      id: uuid.v4(),
      text: messageController.text.trim(),
      type: MessageType.user,
      sendBy: authenticatedUser?.uid,
      createdAt: DateTime.now(),
    );

    _addMessage(newMessage);
    messages.insert(0, newMessage);

    messageController.clear();
    cacheService.deleteData('${character?.uid}-chat');
    scrollToBottom();
  }

  @action
  void scrollToBottom() {
    showScrollToBottom = false;
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  @action
  bool isSameDate(Message current, Message next) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final String currentDateFormatted = formatter.format(current.createdAt!);
    final String nextDateFormatted = formatter.format(next.createdAt!);
    return currentDateFormatted == nextDateFormatted;
  }

  Future<void> authenticateUser() async {
    authenticatedUser ??= authService.getUser();

    channel!.sink.add(jsonEncode({
      'type': 'auth',
      'user_id': authenticatedUser!.uid,
      'token': await authenticatedUser!.getIdToken(),
    }));
  }

  @action
  Future<void> handleWebSocketMessage(dynamic data) async {
    if (authenticatedUser == null) {
      await authenticateUser();
    }

    if (authenticatedUser != null) {
      if (!firstRequest) {
        channel!.sink.add(
          jsonEncode({
            'type': 'chats',
          }),
        );
        firstRequest = true;
        areChatsLoading = false;
      }

      if (!requestedChats) {
        timer?.cancel();
        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          channel!.sink.add(
            jsonEncode({
              'type': 'chats',
            }),
          );
          requestedChats = true;
        });
      }

      if (data != null) {
        final Map<String, dynamic> json = jsonDecode(data);

        if (json['type'] == 'system') {
          switch (json['status']) {
            case 'error':
              buildContext!.showSnackBarError(message: json['message']);
              break;
            case 'success':
              buildContext!.showSnackBarSuccess(message: json['message']);
              break;
            default:
              buildContext!.showSnackBar(message: json['message']);
          }
        }

        if (json['type'] == 'chats') {
          final List<ChatModel> tempChats = [];

          for (int index = 0; index < json['data']['data'].length; index++) {
            final Map<String, dynamic> data = json['data']['data'][index];

            final UserModel character = UserModel.fromMap(data['character']);
            final ChatModel chat = ChatModel(
              uid: character.uid,
              avatarUrl: '$server/uploads/characters/${character.uid}.png',
              name: '${character.name} ${character.surname}',
              lastMessage: data['last_message'],
              seen: data['seen'] != 0,
              draft: await cacheService.getData('${character.uid}-chat'),
              updatedAt: DateTime.parse(data['updated_at']),
            );

            tempChats.add(chat);
          }

          chats.clear();
          chats.addAll(tempChats);
          requestedChats = false;
        }

        if (json['type'] == 'text') {
          final Map<String, dynamic> messageData = json['message'];

          final String? id = messageData['id'].toString();
          final String? text = messageData['text'];
          final MessageType? type = MessageType.values.byName(messageData['type']);
          final String? sendBy = messageData['send_by'];
          final DateTime? createdAt = DateTime.parse(messageData['created_at']);

          final Message message = Message(
            id: id,
            text: text,
            type: type,
            sendBy: sendBy,
            createdAt: createdAt,
          );

          messages.insert(0, message);
        }
      }
    }
  }

  @action
  Future<UserModel?> getCharacterById(String id) async {
    final Response<dynamic> response = await dio.get('$server/api/characters/$id', options: DioOptions());

    if (response.statusCode == 200) {
      character = UserModel.fromMap(response.data);

      if (await cacheService.getData('${character?.uid}-chat') != null) {
        messageController.text = await cacheService.getData('${character?.uid}-chat');
      }
    }

    return character;
  }

  @action
  Future<List<Message>> getMessages(String id, int page, void Function(int) updateAvailablePages) async {
    final List<Message> messages = [];
    final Response<dynamic> response = await dio.get('$server/api/messages?uid=$id&page=$page', options: DioOptions(cache: false));

    if (response.statusCode == 200) {
      final int totalPages = response.data['meta']['last_page'] - page;
      final List<dynamic> data = response.data['data'];

      updateAvailablePages(totalPages);

      for (final Map<String, dynamic> item in data) {
        final String id = item['id'].toString();
        final String content = item['content'];
        final DateTime createdAt = DateTime.parse(item['created_at']);
        final MessageType type = item['user']['uid'] == authenticatedUser!.uid ? MessageType.user : MessageType.sender;
        final Message message = Message(
          id: id,
          text: content,
          type: type,
          createdAt: createdAt,
          sendBy: item['user']['uid'],
        );

        messages.add(message);
      }
    } else {
      errorMessage = response.data['error'] ?? 'Something went wrong, please try again later';
    }

    return messages;
  }

  @action
  Future<void> sendReport({
    required BuildContext context,
    required String type,
    String? description,
  }) async {
    try {
      final Response<dynamic> response = await dio.post('$server/api/reports', data: {
        'user_uid': authenticatedUser!.uid,
        'character_uid': character!.uid,
        'type': type,
      });

      if (response.statusCode == 200) {
        context.showSnackBarSuccess(message: 'Report sent successfully');
      } else {
        context.showSnackBarError(message: response.data['error'] ?? 'Something went wrong, please try again later');
      }

      Navigator.pop(context);
    } catch (e) {
      context.showSnackBarError(message: 'Something went wrong, please try again later');
    }
  }
}
