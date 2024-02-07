import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:thisdatedoesnotexist/app/core/models/message_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/features/chat/store/chat_store.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/chat_bubble.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/grouped_listview.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_from_enum.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_status_enum.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_type_enum.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/profile_drawer.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/waveform_view.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.id,
  });

  final String id;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatStore store = Modular.get<ChatStore>();
  Future<dynamic>? future;
  Uuid uuid = const Uuid();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    future = store.getChat(widget.id);
    store.handleEndReached(widget.id);
    store.audioRecorder = AudioRecorder();
    store.amplitudeStreamController = StreamController<double>.broadcast();
  }

  @override
  void dispose() {
    store.character = null;
    store.currentPage = 1;
    store.availablePages = 1;
    store.messages.clear();
    store.isLoading = true;
    store.messageController.clear();
    store.messageDebounce?.cancel();
    store.disposeRecording();
    store.hideEmojiKeyboard();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          final UserModel character = snapshot.data;

          return Scaffold(
            backgroundColor: const Color(0xFFf8f8f8),
            key: key,
            endDrawer: SizedBox(
              width: double.infinity,
              child: ProfileDrawer(),
            ),
            endDrawerEnableOpenDragGesture: false,
            appBar: AppBar(
              flexibleSpace: InkWell(
                onTap: () {
                  if (store.character != null) {
                    key.currentState!.openEndDrawer();
                  }
                },
              ),
              title: IgnorePointer(
                child: Row(
                  children: [
                    CircleAvatar(
                      maxRadius: 18,
                      backgroundImage: CachedNetworkImageProvider(
                        '${store.server}/uploads/characters/${character.uid}.png',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Observer(
                      builder: (_) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${character.name} ${character.surname}'),
                          if (store.isCharacterTyping)
                            const Text(
                              'Typing...',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              titleSpacing: 0,
              actions: [
                MenuAnchor(
                  builder: (BuildContext context, MenuController controller, Widget? child) {
                    return IconButton(
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                      icon: const Icon(Icons.more_vert),
                    );
                  },
                  menuChildren: [
                    MenuItemButton(
                      leadingIcon: const Icon(Icons.report_outlined),
                      child: const Text('Report'),
                      onPressed: () => store.report(context),
                    ),
                  ],
                ),
              ],
            ),
            body: Observer(
              builder: (_) => Column(
                children: [
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollNotification) {
                        final ScrollMetrics metrics = scrollNotification.metrics;
                        final ScrollDirection scrollDirection = store.chatScrollController.position.userScrollDirection;

                        if (metrics.atEdge) {
                          final bool isTop = metrics.pixels == 0;

                          if (isTop) {
                            store.handleEndReached(widget.id);
                          }
                        }

                        // Going up
                        if (scrollDirection == ScrollDirection.reverse) {
                          store.showScrollToBottom = false;
                          store.setLastScrollDirection(scrollDirection);
                        }

                        // Going down
                        if (scrollDirection == ScrollDirection.forward) {
                          store.setLastScrollDirection(scrollDirection);
                        }

                        if (scrollDirection == ScrollDirection.idle && store.lastScrollDirection == ScrollDirection.forward && metrics.pixels > 800) {
                          store.setLastScrollDirection(scrollDirection);
                          store.showScrollToBottom = true;
                        }

                        return true;
                      },
                      child: GroupedListView(
                        controller: store.chatScrollController,
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                        itemCount: store.messages.length,
                        state: store.state,
                        reverse: true,
                        emptyBuilder: (BuildContext context) {
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('No messages yet. Be the first to send a message!'),
                            ],
                          );
                        },
                        errorBuilder: (BuildContext context) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(store.errorMessage!),
                            ],
                          );
                        },
                        loadingBuilder: (BuildContext context) {
                          return Skeletonizer(
                            child: ListView.builder(
                              itemCount: Random().nextInt(10) + 1,
                              shrinkWrap: true,
                              reverse: true,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                              itemBuilder: (BuildContext context, int index) {
                                return ChatBubble(
                                  message: Message(
                                    id: uuid.v4(),
                                    content: 'Hello! This is a message! My index is $index',
                                    type: MessageType.text,
                                    from: index.isEven ? MessageFrom.sender : MessageFrom.user,
                                    createdAt: DateTime.now(),
                                    status: MessageStatus.read,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        itemBuilder: (BuildContext context, int index) {
                          final Message message = store.messages[index];
                          final bool isLastMessage = index == store.messages.length - 1;

                          return Column(
                            children: [
                              if (isLastMessage || !store.isSameDate(store.messages[index], store.messages[index + 1]))
                                ChatBubble(
                                  message: Message(
                                    content: DateFormat('dd/MM/yyyy').format(message.createdAt!),
                                    from: MessageFrom.system,
                                    type: MessageType.text,
                                    createdAt: DateTime.now(),
                                  ),
                                  bubbleColor: Colors.black.withOpacity(0.3),
                                  textColor: Colors.white,
                                ),
                              ChatBubble(message: message),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 14,
                      top: 15,
                      bottom: 15,
                    ),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (store.isRecording || store.recordedAudio != null)
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: const Color(0xFFf4f4f9),
                              ),
                              child: StreamBuilder(
                                stream: store.amplitudeStreamController!.stream,
                                builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
                                  if (snapshot.hasData) {
                                    final double amplitude = snapshot.data!;

                                    store.amplitudeValues.insert(0, amplitude);
                                    if (store.amplitudeValues.length > 100) {
                                      store.amplitudeValues.removeLast();
                                    }

                                    return WaveformView(amplitudeValues: store.amplitudeValues);
                                  }

                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          )
                        else
                          Flexible(
                            child: TextField(
                              controller: store.messageController,
                              textCapitalization: TextCapitalization.sentences,
                              minLines: 1,
                              maxLines: 5,
                              onChanged: store.onMessageFieldChanged,
                              keyboardType: TextInputType.multiline,
                              onTap: store.hideEmojiKeyboard,
                              decoration: InputDecoration(
                                fillColor: const Color(0xFFf4f4f9),
                                hintText: 'Message...',
                                suffixIcon: IconButton(
                                  onPressed: store.toggleEmojiKeyboard,
                                  icon: const Icon(
                                    Icons.emoji_emotions,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Observer(
                          builder: (_) => Row(
                            children: [
                              if (store.recordedAudio != null)
                                IconButton(
                                  onPressed: store.refreshRecording,
                                  icon: const Icon(
                                    Icons.close,
                                  ),
                                ),
                              Observer(
                                builder: (_) => IconButton(
                                  onPressed: store.allowSendMessage
                                      ? () async {
                                          if (store.allowAudioMessages && store.textMessage.isEmpty && store.recordedAudio == null) {
                                            await store.recordOrStop();
                                          } else {
                                            await store.onSendTap(store.recordedAudio != null ? MessageType.audio : MessageType.text);
                                          }
                                        }
                                      : null,
                                  icon: store.textMessage.isNotEmpty || store.recordedAudio != null || !store.allowAudioMessages
                                      ? const Icon(Icons.send)
                                      : store.isRecording
                                          ? const Icon(Icons.stop)
                                          : const Icon(Icons.mic),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Offstage(
                    offstage: !store.isEmojiKeyboardShowing,
                    child: SizedBox(
                      height: 250,
                      child: EmojiPicker(
                        textEditingController: store.messageController,
                        onBackspacePressed: store.onBackspaceEmojiKeyboardPressed,
                        onEmojiSelected: (Category? _, Emoji __) {
                          store.onMessageFieldChanged(store.messageController.text.trim());
                        },
                        config: const Config(
                          bottomActionBarConfig: BottomActionBarConfig(
                            backgroundColor: Color(0xFFEBEFF2),
                            buttonColor: Color(0xFFEBEFF2),
                            buttonIconColor: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            floatingActionButton: Observer(
              builder: (_) => Visibility(
                visible: store.showScrollToBottom,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 150),
                  child: FloatingActionButton(
                    onPressed: store.scrollToBottom,
                    child: const Icon(Icons.arrow_downward_outlined),
                  ),
                ),
              ),
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
