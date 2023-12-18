import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/core/models/character_model.dart';
import 'package:thisdatedoesnotexist/app/features/chat/store/chat_store.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/chat_list_tile.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  ChatStore store = ChatStore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: store.getChats(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            final List<dynamic> data = snapshot.data['data'];

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                final CharacterModel character = CharacterModel.fromMap(data[index]['character']);

                return ChatListTile(
                  id: character.uid,
                  name: '${character.name} ${character.surname}',
                  time: character.updatedAt,
                  avatarUrl: '${store.server}/uploads/characters/${character.uid}.png',
                );
              },
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
