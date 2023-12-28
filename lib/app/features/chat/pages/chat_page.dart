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
            appBar: AppBar(
              leadingWidth: 30,
              flexibleSpace: InkWell(
                onTap: () {},
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
