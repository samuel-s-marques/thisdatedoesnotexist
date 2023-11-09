import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/chat_list_tile.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 2,
        itemBuilder: (BuildContext context, int index) {
          return ChatListTile(
            id: '0',
            name: 'Samuel',
            message: 'Hiiii',
            time: DateTime.now(),
            avatarUrl: 'https://placehold.co/256x256',
          );
        },
      ),
    );
  }
}
