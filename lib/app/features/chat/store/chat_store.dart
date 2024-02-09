import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:thisdatedoesnotexist/app/core/models/message_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/service_return_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/cache_service.dart';
import 'package:thisdatedoesnotexist/app/core/services/report_service.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/auth/services/auth_service.dart';
import 'package:thisdatedoesnotexist/app/features/chat/models/chat_model.dart';
import 'package:thisdatedoesnotexist/app/features/chat/services/chat_service.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/chat_state_enum.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_from_enum.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_status_enum.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_type_enum.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'chat_store.g.dart';

class ChatStore = ChatStoreBase with _$ChatStore;

abstract class ChatStoreBase with Store {
  Uuid uuid = const Uuid();
  ChatService service = Modular.get();
  ReportService reportService = Modular.get();
  AuthService authService = Modular.get();
  String server = const String.fromEnvironment('SERVER');
  String wssServer = const String.fromEnvironment('WSS_SERVER');
  WebSocketChannel? channel;
  BuildContext? buildContext;
  bool requestedChats = false;
  ScrollController chatScrollController = ScrollController();
  ScrollController chatListScrollController = ScrollController();
  TextEditingController messageController = TextEditingController();
  AudioRecorder? audioRecorder;
  CacheService cacheService = CacheService();
  Timer? searchDebounce;
  Timer? messageDebounce;
  Timer? audioDuration;
  Timer? amplitudeTimer;
  List<double> amplitudeValues = [];
  StreamController<double>? amplitudeStreamController;

  @observable
  bool allowAudioMessages = false;

  @observable
  String? recordedAudio;

  @observable
  int recordDuration = 0;

  @observable
  bool isEmojiKeyboardShowing = false;

  @observable
  int chatListPage = 1;

  @computed
  ChatState get state => getChatState();

  @observable
  bool isLoading = false;

  @observable
  bool firstRequest = false;

  @observable
  bool authenticated = false;

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
  bool isCharacterTyping = false;

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

  @observable
  bool isRecording = false;

  @observable
  String textMessage = '';

  @computed
  bool get allowSendMessage {
    if (messages.isEmpty) {
      return true;
    } else {
      return messages.first.from != MessageFrom.user;
    }
  }

  @action
  void toggleEmojiKeyboard() {
    isEmojiKeyboardShowing = !isEmojiKeyboardShowing;

    if (isEmojiKeyboardShowing) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @action
  void hideEmojiKeyboard() {
    isEmojiKeyboardShowing = false;
  }

  @action
  void onBackspaceEmojiKeyboardPressed() {
    messageController
      ..text = messageController.text.characters.toString()
      ..selection = TextSelection.fromPosition(
        TextPosition(
          offset: messageController.text.length,
        ),
      );
    textMessage = messageController.text.trim();
  }

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

  void onMessageFieldChanged(String? value) {
    textMessage = value ?? '';

    if (messageDebounce?.isActive ?? false) {
      messageDebounce?.cancel();
    }

    messageDebounce = Timer(const Duration(milliseconds: 300), () {
      cacheService.saveData('${character?.uid}-chat', value);
      requestChats();
    });
  }

  void onSearch(String? value) {
    if (searchDebounce?.isActive ?? false) {
      searchDebounce?.cancel();
    }

    searchDebounce = Timer(const Duration(milliseconds: 300), () {
      requestChats(isSearching: true, searchQuery: value);
    });
  }

  @action
  Future<void> onSendTap(MessageType type) async {
    switch (type) {
      case MessageType.text:
        sendTextMessage();
        break;
      case MessageType.audio:
        await sendAudioMessage();
        await refreshRecording();
        break;
      default:
        sendTextMessage();
        break;
    }
  }

  @action
  void sendTextMessage() {
    if (messageController.text.isEmpty || textMessage.trim().isEmpty) {
      return;
    }

    final Message newMessage = Message(
      id: uuid.v4(),
      content: textMessage.trim(),
      type: MessageType.text,
      from: MessageFrom.user,
      sendBy: authService.getUser()!.uid,
      status: MessageStatus.sending,
      createdAt: DateTime.now().toLocal(),
    );
    messages.insert(0, newMessage);
    messageController.clear();
    textMessage = '';
    cacheService.deleteData('${character?.uid}-chat');
    // scrollToBottom();

    try {
      _addMessage(newMessage);
      updateMessageStatus(newMessage.id, 'sent');
    } catch (e) {
      if (kDebugMode) {
        print('WebSocket connection error: $e');
      }
    }
  }

  Future<void> sendAudioMessage() async {
    if (recordedAudio == null) {
      return;
    }

    final Uint8List audioBytes = await File(recordedAudio!).readAsBytes();

    final Message newMessage = Message(
      id: uuid.v4(),
      type: MessageType.audio,
      content: base64Encode(audioBytes),
      from: MessageFrom.user,
      sendBy: authService.getUser()!.uid,
      location: recordedAudio,
      duration: Duration(milliseconds: recordDuration),
      status: MessageStatus.sending,
      createdAt: DateTime.now().toLocal(),
    );
    messages.insert(0, newMessage);
    // scrollToBottom();
    // await disposeRecording();

    try {
      _addMessage(newMessage);
      recordDuration = 0;
      updateMessageStatus(newMessage.id, 'sent');
    } catch (e) {
      if (kDebugMode) {
        print('WebSocket connection error: $e');
      }
    }
  }

  @action
  Future<void> refreshRecording() async {
    recordedAudio = null;
    amplitudeValues.clear();
  }

  @action
  Future<void> disposeRecording() async {
    recordedAudio = null;
    await audioRecorder?.stop();
    isRecording = false;
    await audioRecorder?.dispose();
    await amplitudeStreamController?.close();
  }

  @action
  void startAudioDurationTimer() {
    audioDuration?.cancel();

    audioDuration = Timer.periodic(const Duration(milliseconds: 1), (Timer _) {
      recordDuration++;
    });
  }

  void _startAmplitudeStream() {
    amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      final Amplitude amplitude = await audioRecorder!.getAmplitude();
      final double maxAmplitude = amplitude.max.abs();
      final double currentAmplitude = amplitude.current.abs();

      amplitudeStreamController!.add(maxAmplitude / currentAmplitude);
    });
  }

  @action
  Future<void> recordOrStop() async {
    audioRecorder ??= AudioRecorder();

    if (await audioRecorder!.hasPermission()) {
      try {
        if (isRecording) {
          recordedAudio = await audioRecorder!.stop();
          isRecording = false;
          audioDuration?.cancel();
          amplitudeTimer?.cancel();
        } else {
          final Directory tempDirectory = await getTemporaryDirectory();

          recordedAudio = null;
          isRecording = true;
          await audioRecorder!.start(
            const RecordConfig(
              bitRate: 705600,
              sampleRate: 16000,
              numChannels: 1,
              encoder: AudioEncoder.wav,
              noiseSuppress: true,
            ),
            path: '${tempDirectory.path}/audio.wav',
          );

          startAudioDurationTimer();
          _startAmplitudeStream();
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error: $e');
        }
      }
    }
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
    channel!.sink.add(
      jsonEncode({
        'type': 'auth',
        'user_id': authService.getUser()!.uid,
        'token': await authService.getToken(),
      }),
    );
  }

  Future<void> initializeWebSocket() async {
    try {
      channel = WebSocketChannel.connect(
        Uri.parse(wssServer),
      );
      await authenticateUser();
      channel!.stream.listen(handleWebSocketMessage);
    } catch (e) {
      if (kDebugMode) {
        print('WebSocket connection error: $e');
      }
    }
  }

  @action
  void requestChats({
    int? page = 1,
    bool isSearching = false,
    String? searchQuery,
  }) {
    channel!.sink.add(
      jsonEncode({
        'type': 'chats',
        'search': searchQuery,
        'searching': isSearching,
        'page': chatListPage,
      }),
    );
  }

  @action
  Future<void> handleWebSocketMessage(dynamic data) async {
    final Map<String, dynamic> json = jsonDecode(data ?? {});

    if (await authService.getToken() == null || json['message'] == 'Unauthorized.') {
      await authenticateUser();
    }

    if (data != null) {
      if (json['type'] == 'system') {
        if (json['message'] == 'Authorized.') {
          authenticated = true;
        }

        if (json['show']) {
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
      }

      if (!firstRequest && authenticated) {
        requestChats();
        firstRequest = true;
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
            updatedAt: DateTime.parse(data['updated_at']).toLocal(),
          );

          tempChats.add(chat);
        }

        chats.clear();
        chats.addAll(tempChats.toSet());
        areChatsLoading = false;
        requestedChats = false;
      }

      if (json['type'] == 'text') {
        final Map<String, dynamic> messageData = json['message'];

        final String? id = messageData['id'].toString();
        final String? text = messageData['text'];
        final MessageType? type = MessageType.values.byName(messageData['type'] ?? 'text');
        final String? sendBy = messageData['send_by'];
        final DateTime? createdAt = DateTime.parse(messageData['created_at']).toLocal();
        final MessageStatus? status = MessageStatus.values.byName(messageData['status'] ?? 'read');
        final MessageFrom from = MessageFrom.values.byName(messageData['from']);
        final String? location = messageData['location'];

        final Message message = Message(
          id: id,
          content: text,
          from: from,
          type: type,
          sendBy: sendBy,
          status: status,
          location: location,
          createdAt: createdAt,
        );

        messages.insert(0, message);
      }

      if (json['type'] == 'message-status') {
        final String? id = json['message']['id'].toString();
        final String? status = json['message']['status'];

        updateMessageStatus(id, status);
      }

      if (json['type'] == 'typing') {
        final String? from = json['from'];
        final bool isTyping = json['isTyping'] ?? false;

        if (from == character?.uid) {
          isCharacterTyping = isTyping;
        }

        chats[chats.indexWhere((ChatModel chat) => chat.uid == from)].isTyping = isTyping;
      }
    }
  }

  @action
  void updateMessageStatus(String? id, String? newStatus) {
    final MessageStatus? status = MessageStatus.values.byName(newStatus ?? 'read');

    final Message message = messages.firstWhere((Message message) => message.id == id);
    message.status = status;
  }

  @action
  Future<UserModel?> getChat(String id) async {
    final ServiceReturn response = await service.getChat(id);

    if (response.success) {
      isCharacterTyping = false;
      character = response.data;
      isCharacterTyping = chats.firstWhere((ChatModel chat) => chat.uid == character!.uid).isTyping;

      if (await cacheService.getData('${character?.uid}-chat') != null) {
        messageController.text = await cacheService.getData('${character?.uid}-chat');
        textMessage = messageController.text.trim();
      }
    }

    return character;
  }

  @action
  Future<void> getChatSettings() async {
    final ServiceReturn response = await service.getChatSettings();

    if (response.success) {
      allowAudioMessages = response.data['audio'] ?? false;
    }
  }

  @action
  Future<List<Message>> getMessages(String id, int page, void Function(int) updateAvailablePages) async {
    final List<Message> messages = [];
    final ServiceReturn response = await service.getMessages(id, page, updateAvailablePages);

    if (response.success) {
      for (final Map<String, dynamic> item in response.data) {
        final String id = item['id'].toString();
        final String content = item['content'];
        final DateTime createdAt = DateTime.parse(item['created_at']).toLocal();
        final MessageFrom from = item['user']['uid'] == authService.getUser()!.uid ? MessageFrom.user : MessageFrom.sender;
        final MessageStatus status = MessageStatus.values.byName(item['status'] ?? 'read');
        final MessageType type = MessageType.values.byName(item['type'] ?? 'text');
        final int? duration = item['duration'];
        final String? location = item['location'];
        final Message message = Message(
          id: id,
          content: content,
          from: from,
          type: type,
          duration: duration != null ? Duration(milliseconds: duration) : null,
          createdAt: createdAt,
          location: location != null ? '$server/$location' : null,
          status: status,
          sendBy: item['user']['uid'],
        );

        messages.add(message);
      }
    } else {
      errorMessage = response.data['error']['details'] ?? 'Something went wrong, please try again later';
    }

    return messages;
  }

  @action
  Future<void> report(BuildContext context) => reportService.report(context: context, characterUid: character?.uid ?? '');
}
