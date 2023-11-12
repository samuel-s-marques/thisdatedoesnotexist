import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat name'),
      ),
      body: StreamBuilder<List<types.Message>>(
        initialData: const [],
        stream: FirebaseChatCore.instance.messages(
          const types.Room(
            id: 'id',
            type: types.RoomType.direct,
            users: [],
          ),
        ),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Chat(
            messages: [],
            onSendPressed: (types.PartialText message) {},
            user: const types.User(id: '0'),
          );
        },
      ),
    );
  }
}
