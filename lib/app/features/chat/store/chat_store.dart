import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';
import 'package:thisdatedoesnotexist/app/core/services/dio_service.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/chat/models/chat_model.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'chat_store.g.dart';

class ChatStore = ChatStoreBase with _$ChatStore;

abstract class ChatStoreBase with Store {
  AuthService authService = AuthService();
  User? authenticatedUser;
  Uuid uuid = const Uuid();
  String server = const String.fromEnvironment('SERVER');
  String wssServer = const String.fromEnvironment('WSS_SERVER');
  final DioService dio = DioService();
  WebSocketChannel? channel;
  BuildContext? buildContext;
  Timer? timer;
  bool requestedChats = false;
  bool firstRequest = false;

  @observable
  UserModel? character;

  @observable
  ObservableList<ChatModel> chats = ObservableList();

  Future<void> authenticateUser() async {
    authenticatedUser ??= authService.getUser();

    channel!.sink.add(jsonEncode({
      'type': 'auth',
      'user_id': authenticatedUser!.uid,
      'token': await authenticatedUser!.getIdToken(),
    }));
  }

  @action
  Future<void> handleWebSocketMessage(dynamic data) async {
    if (authenticatedUser == null) {
      await authenticateUser();
    }

    if (authenticatedUser != null) {
      if (!firstRequest) {
        channel!.sink.add(
          jsonEncode({
            'type': 'chats',
          }),
        );
        firstRequest = true;
      }

      if (!requestedChats) {
        timer?.cancel();
        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          channel!.sink.add(
            jsonEncode({
              'type': 'chats',
            }),
          );
          requestedChats = true;
        });
      }

      if (data != null) {
        final Map<String, dynamic> json = jsonDecode(data);

        if (json['type'] == 'system') {
          switch (json['status']) {
            case 'error':
              buildContext!.showSnackBarError(message: json['message']);
              break;
            case 'success':
              buildContext!.showSnackBarSuccess(message: json['message']);
              break;
            default:
              buildContext!.showSnackBar(message: json['message']);
          }
        }

        if (json['type'] == 'chats') {
          final List<ChatModel> tempChats = [];

          for (int index = 0; index < json['data']['data'].length; index++) {
            final Map<String, dynamic> data = json['data']['data'][index];

            final UserModel character = UserModel.fromMap(data['character']);
            final ChatModel chat = ChatModel(
              uid: character.uid,
              avatarUrl: '$server/uploads/characters/${character.uid}.png',
              name: '${character.name} ${character.surname}',
              lastMessage: data['last_message'],
              seen: data['seen'] != 0,
              updatedAt: DateTime.parse(data['updated_at']),
            );

            tempChats.add(chat);
          }

          chats.clear();
          chats.addAll(tempChats);
          requestedChats = false;
        }
      }
    }
  }

  @action
  Future<UserModel?> getCharacterById(String id) async {
    final Response<dynamic> response = await dio.get('$server/api/characters/$id', options: DioOptions());

    if (response.statusCode == 200) {
      character = UserModel.fromMap(response.data);
    }

    return character;
  }

  @action
  Future<List<types.Message>> getMessages(String id, int page, void Function(int) updateAvailablePages) async {
    final List<types.Message> messages = [];
    final Response<dynamic> response = await dio.get('$server/api/messages?uid=$id&page=$page', options: DioOptions(cache: false));

    if (response.statusCode == 200) {
      final int totalPages = response.data['meta']['last_page'] - page;
      final List<dynamic> data = response.data['data'];

      updateAvailablePages(totalPages);

      for (final Map<String, dynamic> item in data) {
        final String content = item['content'];
        final DateTime createdAt = DateTime.parse(item['created_at']);
        final DateTime updatedAt = DateTime.parse(item['updated_at']);

        final types.User author = types.User(id: item['user']['uid']);
        final types.Message message = types.TextMessage(
          id: uuid.v4(),
          text: content,
          type: types.MessageType.text,
          author: author,
          createdAt: createdAt.millisecondsSinceEpoch,
          updatedAt: updatedAt.millisecondsSinceEpoch,
        );

        messages.add(message);
      }
    }

    return messages;
  }

  @action
  Future<void> sendReport({
    required BuildContext context,
    required String type,
    String? description,
  }) async {
    try {
      final Response<dynamic> response = await dio.post('$server/api/reports', data: {
        'user_uid': authenticatedUser!.uid,
        'character_uid': character!.uid,
        'type': type,
      });

      if (response.statusCode == 200) {
        context.showSnackBarSuccess(message: 'Report sent successfully');
      } else {
        context.showSnackBarError(message: response.data['error'] ?? 'Something went wrong, please try again later');
      }

      Navigator.pop(context);
    } catch (e) {
      context.showSnackBarError(message: 'Something went wrong, please try again later');
    }
  }
}
