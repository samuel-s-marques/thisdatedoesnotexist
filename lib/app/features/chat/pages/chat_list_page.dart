import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/features/chat/store/chat_store.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/chat_list_tile.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  ChatStore store = Modular.get<ChatStore>();
  bool authenticated = false;

  @override
  void initState() {
    super.initState();
    store.channel = WebSocketChannel.connect(
      Uri.parse(store.wssServer),
    );
    store.channel!.stream.listen(store.handleWebSocketMessage);
  }

  @override
  void dispose() {
    store.timer?.cancel();
    store.timer = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Observer(builder: (_) {
        if (store.chats.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          itemCount: store.chats.length,
          itemBuilder: (BuildContext context, int index) {
            return ChatListTile(
              id: store.chats[index].uid,
              name: store.chats[index].name,
              time: store.chats[index].updatedAt,
              draft: store.chats[index].draft,
              message: store.chats[index].lastMessage,
              avatarUrl: store.chats[index].avatarUrl,
            );
          },
        );
      }),
    );
  }
}
