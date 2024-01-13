import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/core/models/message_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/features/chat/store/chat_store.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/chat_bubble.dart';
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
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) {
        store.character = null;
        store.currentPage = 1;
        store.availablePages = 1;
        store.messages.clear();

        Modular.to.pop();
      },
      child: FutureBuilder(
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
                        child: const Text('Report'),
                        onPressed: () {
                          showModalBottomSheet(
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
                                    onTap: () async => store.sendReport(context: context, type: 'inappropriate content'),
                                  ),
                                  const SizedBox(height: 10),
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                                    title: const Text('Bug'),
                                    leading: const Icon(Icons.bug_report_outlined),
                                    onTap: () async => store.sendReport(context: context, type: 'bug'),
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
                                                onPressed: () async => store.sendReport(
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
                        },
                      ),
                    ],
                  ),
                ],
              ),
              body: Observer(
                builder: (_) => ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                  itemCount: store.messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Message message = store.messages[index];

                    return ChatBubble(
                      type: message.type!,
                      message: message.text ?? '',
                    );
                  },
                ),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
