import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/features/chat/models/chat_model.dart';
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
                final UserModel character = UserModel.fromMap(data[index]['character']);
                final ChatModel chat = ChatModel(
                  name: '${character.name} ${character.surname}',
                  lastMessage: data[index]['last_message'],
                  seen: data[index]['seen'] != 0,
                  updatedAt: DateTime.parse(data[index]['updated_at']),
                );

                return ChatListTile(
                  id: character.uid,
                  name: '${character.name} ${character.surname}',
                  time: chat.updatedAt,
                  message: chat.lastMessage,
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
