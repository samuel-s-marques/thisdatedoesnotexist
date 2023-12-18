import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';

part 'chat_store.g.dart';

class ChatStore = ChatStoreBase with _$ChatStore;

abstract class ChatStoreBase with Store {
  AuthService authService = AuthService();
  User? authenticatedUser;
  final Dio dio = Dio();
  String server = const String.fromEnvironment('SERVER');

  @action
  Future<dynamic> getChats() async {
    authenticatedUser ??= authService.getUser();

    final Response<dynamic> response = await dio.get('$server/api/chats?uid=${authenticatedUser?.uid}');

    return response.data;
  }

  @action
  Future<dynamic> getCharacterById(String id) async {
    final Response<dynamic> response = await dio.get('$server/api/characters/$id');

    return response.data;
  }
}
