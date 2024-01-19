import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:thisdatedoesnotexist/app/core/models/message_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/features/chat/store/chat_store.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/chat_bubble.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/grouped_listview.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_type_enum.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/profile_drawer.dart';
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

  @override
  void initState() {
    super.initState();
    future = store.getCharacterById(widget.id);
    store.handleEndReached(widget.id);
  }

  @override
  void dispose() {
    store.character = null;
    store.currentPage = 1;
    store.availablePages = 1;
    store.messages.clear();
    store.isLoading = true;
    store.messageController.clear();
    store.key = GlobalKey<ScaffoldState>();
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
            key: store.key,
            endDrawer: SizedBox(
              width: double.infinity,
              child: ProfileDrawer(),
            ),
            endDrawerEnableOpenDragGesture: false,
            appBar: AppBar(
              flexibleSpace: InkWell(
                onTap: () {
                  store.key.currentState!.openEndDrawer();
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
                    Text('${character.name} ${character.surname}'),
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
                      onPressed: () => store.openReportBottomSheet(context: context),
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
                                  type: index.isEven ? MessageType.sender : MessageType.user,
                                  message: 'Hello! This is a message! My index is $index',
                                  createdAt: DateTime.now(),
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
                                  type: MessageType.system,
                                  message: DateFormat('dd/MM/yyyy').format(message.createdAt!),
                                  bubbleColor: Colors.black.withOpacity(0.3),
                                  textColor: Colors.white,
                                  createdAt: DateTime.now(),
                                ),
                              ChatBubble(
                                type: message.type!,
                                message: message.text ?? '',
                                createdAt: message.createdAt!,
                              ),
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
                        Flexible(
                          child: TextField(
                            controller: store.messageController,
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 1,
                            maxLines: 5,
                            onChanged: store.onChanged,
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                              fillColor: Color(0xFFf4f4f9),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: store.onSendTap,
                          icon: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
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
