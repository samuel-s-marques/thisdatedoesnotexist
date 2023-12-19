import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

part 'chat_store.g.dart';

class ChatStore = ChatStoreBase with _$ChatStore;

abstract class ChatStoreBase with Store {
  AuthService authService = AuthService();
  User? authenticatedUser;
  final Dio dio = Dio();
  Uuid uuid = const Uuid();
  String server = const String.fromEnvironment('SERVER');
  String wssServer = const String.fromEnvironment('WSS_SERVER');

  @action
  Future<dynamic> getChats() async {
    authenticatedUser ??= authService.getUser();

    final Response<dynamic> response = await dio.get('$server/api/chats?uid=${authenticatedUser?.uid}');

    return response.data;
  }

  @action
  Future<dynamic> getCharacterById(String id) async {
    authenticatedUser ??= authService.getUser();

    final Response<dynamic> response = await dio.get('$server/api/characters/$id');

    return response.data;
  }

  @action
  Future<List<types.Message>> getMessages(String id, int page) async {
    authenticatedUser ??= authService.getUser();
    final List<types.Message> messages = [];
    final Response<dynamic> response = await dio.get('$server/api/messages?uid=$id&page=$page');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

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
}
