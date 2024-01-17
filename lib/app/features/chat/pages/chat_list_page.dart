import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:thisdatedoesnotexist/app/features/chat/models/chat_model.dart';
import 'package:thisdatedoesnotexist/app/features/chat/store/chat_store.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/chat_list_tile.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  ChatStore store = Modular.get<ChatStore>();
  bool authenticated = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    store.initializeWebSocket();
  }

  @override
  void dispose() {
    store.timer?.cancel();
    store.timer = null;
    store.debounce?.cancel();
    store.channel?.sink.close();
    store.requestedChats = false;
    store.firstRequest = false;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Observer(
          builder: (_) => AppBar(
            title: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: store.isSearching
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width - 56.0,
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: store.onSearch,
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    )
                  : const Text('Chats'),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  store.isSearching = !store.isSearching;

                  if (!store.isSearching) {
                    searchController.clear();
                  }
                },
                icon: Icon(store.isSearching ? Icons.close : Icons.search),
              ),
            ],
          ),
        ),
      ),
      body: Observer(builder: (_) {
        return Skeletonizer(
          enabled: store.areChatsLoading,
          child: ListView.builder(
            itemCount: store.areChatsLoading ? 10 : store.chats.length,
            itemBuilder: (BuildContext context, int index) {
              if (store.areChatsLoading) {
                return ChatListTile(
                  id: index.toString(),
                  name: 'Chat name $index',
                  message: 'Message $index',
                  time: DateTime.now(),
                  avatarUrl: 'https://placehold.co/256x256.png',
                );
              }

              final ChatModel chat = store.chats[index];

              return ChatListTile(
                id: chat.uid,
                name: chat.name,
                time: chat.updatedAt,
                draft: chat.draft,
                message: chat.lastMessage,
                avatarUrl: chat.avatarUrl,
              );
            },
          ),
        );
      }),
    );
  }
}
