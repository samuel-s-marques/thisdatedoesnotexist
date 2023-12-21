import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/features/chat/store/chat_store.dart';
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
  ChatStore store = ChatStore();
  Future<dynamic>? future;
  List<types.Message> _messages = [];
  types.User? _user;
  Uuid uuid = const Uuid();
  WebSocketChannel? channel;
  int page = 1;

  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(
      Uri.parse(store.wssServer),
    );
    future = store.getCharacterById(widget.id);
    _user = types.User(id: store.authenticatedUser!.uid);
    _handleEndReached();
  }

  @override
  void dispose() {
    channel!.sink.close();
    super.dispose();
  }

  void _addMessage(types.Message message, String roomId) {
    channel!.sink.add(jsonEncode(message.copyWith(roomId: roomId).toJson()));

    _messages.insert(0, message);
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
  }

  Future<void> _handleEndReached() async {
    final List<types.Message> messages = await store.getMessages(widget.id, page);

    setState(() {
      _messages = [..._messages, ...messages];
      page++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          final UserModel character = UserModel.fromMap(snapshot.data);

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
            body: StreamBuilder(
              stream: channel!.stream,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  final types.Message message = types.Message.fromJson(
                    jsonDecode(snapshot.data),
                  );

                  _messages.insert(0, message);
                }

                return Chat(
                  messages: _messages,
                  onSendPressed: (types.PartialText message) => _handleSendPressed(message, character.uid),
                  onEndReached: _handleEndReached,
                  user: _user!,
                );
              },
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
