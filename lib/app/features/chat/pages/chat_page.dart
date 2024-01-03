import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/chat/store/chat_store.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/profile_drawer.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  List<types.Message> _messages = [];
  types.User? _user;
  Uuid uuid = const Uuid();
  WebSocketChannel? channel;
  int page = 1;
  int availablePages = 1;
  final GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(
      Uri.parse(store.wssServer),
    );
    future = store.getCharacterById(widget.id);
    _user = types.User(id: store.authenticatedUser!.uid);
    _handleEndReached();
    channel!.stream.listen(_handleWebSocketMessage);
  }

  @override
  void dispose() {
    channel!.sink.close();
    super.dispose();
  }

  void _addMessage(types.Message message, String roomId) {
    channel!.sink.add(jsonEncode(message.copyWith(roomId: roomId).toJson()));
  }

  void _handleSendPressed(types.PartialText message, String roomId) {
    final types.Message newMessage = types.TextMessage(
      author: _user!,
      id: uuid.v4(),
      text: message.text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    _addMessage(newMessage, roomId);

    setState(() {
      _messages.insert(0, newMessage);
    });
  }

  Future<void> _handleEndReached() async {
    if (availablePages >= page) {
      final List<types.Message> messages = await store.getMessages(widget.id, page, (updatedAvailablePages) {
        availablePages = updatedAvailablePages;
      });

      final List<types.Message> updatedMessages = [..._messages, ...messages];
      setState(() {
        _messages = updatedMessages;
        page++;
      });
    }
  }

  void _handleWebSocketMessage(dynamic data) {
    if (data != null) {
      final Map<String, dynamic> json = jsonDecode(data);

      if (json['type'] == 'system') {
        switch (json['status']) {
          case 'error':
            context.showSnackBarError(message: json['message']);
            break;
          case 'success':
            context.showSnackBarSuccess(message: json['message']);
            break;
          default:
            context.showSnackBar(message: json['message']);
        }
      }

      final types.Message message = types.Message.fromJson(json);

      setState(() {
        _messages.insert(0, message);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          final UserModel character = snapshot.data;

          return Scaffold(
            key: key,
            endDrawer: SizedBox(
              width: double.infinity,
              child: ProfileDrawer(),
            ),
            endDrawerEnableOpenDragGesture: false,
            appBar: AppBar(
              flexibleSpace: InkWell(
                onTap: () {
                  key.currentState!.openEndDrawer();
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
            body: Chat(
              messages: _messages,
              onSendPressed: (types.PartialText message) => _handleSendPressed(message, character.uid),
              onEndReached: _handleEndReached,
              user: _user!,
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
