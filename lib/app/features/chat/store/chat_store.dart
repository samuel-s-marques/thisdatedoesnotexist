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
  bool requestedChats = false;
  ScrollController chatScrollController = ScrollController();
  ScrollController chatListScrollController = ScrollController();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  TextEditingController messageController = TextEditingController();
  CacheService cacheService = CacheService();
  Timer? debounce;

  @computed
  ChatState get state => getChatState();

  @observable
  bool isLoading = false;

  @observable
  bool firstRequest = false;

  @observable
  String? searchQuery;

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
  bool isSearching = false;

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

  void onSearch(String? value) {
    if (debounce?.isActive ?? false) {
      debounce?.cancel();
    }

    debounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery = value;
    });
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
    chatScrollController.animateTo(
      chatScrollController.position.minScrollExtent,
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

    channel!.sink.add(
      jsonEncode({
        'type': 'auth',
        'user_id': authenticatedUser!.uid,
        'token': await authenticatedUser!.getIdToken(),
      }),
    );
  }

  Future<void> initializeWebSocket() async {
    channel = WebSocketChannel.connect(
      Uri.parse(wssServer),
    );
    await authenticateUser();
    channel!.stream.listen(handleWebSocketMessage);
  }

  @action
  Future<void> handleWebSocketMessage(dynamic data) async {
    final Map<String, dynamic> json = jsonDecode(data ?? {});

    print(json);

    if (authenticatedUser == null || json['message'] == 'Unauthorized.') {
      await authenticateUser();
    }

    if (!firstRequest) {
      channel!.sink.add(
        jsonEncode({
          'type': 'chats',
          'search': searchQuery,
          'searching': isSearching,
        }),
      );
      print('requesting chats');
      firstRequest = true;
    }

    if (data != null) {
      if (json['type'] == 'system' && json['show']) {
        switch (json['status']) {
          case 'error':
            buildContext!.showSnackBarError(message: json['message']);
            break;
          case 'success':
            buildContext!.showSnackBarSuccess(message: json['message']);
            break;
          default:
            buildContext!.showSnackBar(message: json['message']);
            break;
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
        areChatsLoading = false;
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
  Future<void> openReportBottomSheet({
    required BuildContext context,
  }) {
    return showModalBottomSheet(
      context: context,
      enableDrag: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return ListView(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Report',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Inappropriate content'),
              leading: const Icon(Icons.no_adult_content_outlined),
              onTap: () async => sendReport(
                context: context,
                type: 'inappropriate content',
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Bug'),
              leading: const Icon(Icons.bug_report_outlined),
              onTap: () async => sendReport(context: context, type: 'bug'),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Other'),
              leading: const Icon(Icons.report_outlined),
              onTap: () {
                Navigator.pop(context);
                final TextEditingController _controller = TextEditingController();

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Report'),
                      actions: [
                        TextButton(
                          onPressed: () async => sendReport(
                            context: context,
                            type: 'other',
                            description: _controller.text.trim(),
                          ),
                          child: const Text('Send Report'),
                        ),
                      ],
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Please describe the issue:'),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _controller,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Description',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
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
