import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:thisdatedoesnotexist/app/core/models/character_model.dart';
import 'package:thisdatedoesnotexist/app/features/chat/store/chat_store.dart';

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
  ChatStore store = ChatStore();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: store.getCharacterById(widget.id),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          final CharacterModel character = CharacterModel.fromMap(snapshot.data);

          return Scaffold(
            appBar: AppBar(
              leadingWidth: 30,
              title: Row(
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
            body: Chat(
              messages: const [],
              onSendPressed: (types.PartialText message) {},
              user: const types.User(id: '0'),
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
