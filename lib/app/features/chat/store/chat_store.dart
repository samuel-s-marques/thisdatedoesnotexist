import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';
import 'package:thisdatedoesnotexist/app/core/services/dio_service.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

part 'chat_store.g.dart';

class ChatStore = ChatStoreBase with _$ChatStore;

abstract class ChatStoreBase with Store {
  AuthService authService = AuthService();
  User? authenticatedUser;
  Uuid uuid = const Uuid();
  String server = const String.fromEnvironment('SERVER');
  String wssServer = const String.fromEnvironment('WSS_SERVER');
  final DioService dio = DioService();

  @observable
  UserModel? character;

  @action
  Future<dynamic> getChats() async {
    authenticatedUser ??= authService.getUser();

    final Response<dynamic> response = await dio.get('$server/api/chats?uid=${authenticatedUser?.uid}', options: DioOptions());

    return response.data;
  }

  @action
  Future<UserModel?> getCharacterById(String id) async {
    authenticatedUser ??= authService.getUser();

    final Response<dynamic> response = await dio.get('$server/api/characters/$id', options: DioOptions());

    if (response.statusCode == 200) {
      character = UserModel.fromMap(response.data);
    }

    return character;
  }

  @action
  Future<List<types.Message>> getMessages(String id, int page, void Function(int) updateAvailablePages) async {
    authenticatedUser ??= authService.getUser();
    final List<types.Message> messages = [];
    final Response<dynamic> response = await dio.get('$server/api/messages?uid=$id&page=$page', options: DioOptions());

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
        Navigator.pop(context);
        context.showSnackBarSuccess(message: 'Report sent successfully');
      }
    } catch (e) {
      context.showSnackBarError(message: 'Something went wrong, please try again later');
    }
  }
}
