import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:thisdatedoesnotexist/app/core/enum/database_status_enum.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';

class DatabaseService {
  final AuthService authService = AuthService();
  String server = const String.fromEnvironment('SERVER');
  final Dio dio = Dio();

  Future<DatabaseStatus> createUser(UserModel user) async {
    DatabaseStatus status = DatabaseStatus.unknown;
    final User authenticatedUser = authService.getUser();

    try {
      await FirebaseChatCore.instance.createUserInFirestore(
        types.User(
          id: authenticatedUser.uid,
          firstName: authenticatedUser.displayName,
          imageUrl: authenticatedUser.photoURL,
        ),
      );

      await dio.post(
        '$server/api/users',
        data: user.toMap(),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await authenticatedUser.getIdToken()}',
            'Content-Type': 'application/json',
          },
        ),
      );

      status = DatabaseStatus.successful;
    } catch (error) {
      status = DatabaseStatus.failure;
    }

    return status;
  }

  Future<UserModel?> getUser() async {
    final User authenticatedUser = authService.getUser();

    try {
      final Response response = await dio.get(
        '$server/api/users/${authenticatedUser.uid}',
        options: Options(
          headers: {'Authorization': 'Bearer ${await authenticatedUser.getIdToken()}', 'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final UserModel user = UserModel.fromMap(response.data);

        return user;
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  Future<bool> userExists() async {
    final User authenticatedUser = authService.getUser();

    final Response response = await dio.get(
      '$server/api/users/${authenticatedUser.uid}',
      options: Options(
        headers: {'Authorization': 'Bearer ${await authenticatedUser.getIdToken()}', 'Content-Type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  // TODO: Implement updateUser
  Future<DatabaseStatus> updateUser(UserModel user) async {
    try {
      final User authenticatedUser = authService.getUser();
      return DatabaseStatus.successful;
    } catch (e) {
      return DatabaseStatus.failure;
    }
  }
}
