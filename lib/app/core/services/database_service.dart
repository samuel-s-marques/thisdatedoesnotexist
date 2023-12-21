import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:thisdatedoesnotexist/app/core/enum/database_status_enum.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';
import 'package:thisdatedoesnotexist/app/core/services/dio_service.dart';

class DatabaseService {
  final AuthService authService = AuthService();
  String server = const String.fromEnvironment('SERVER');
  final DioService dio = DioService();

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

      if (user.imageUrl == null) {
        return DatabaseStatus.failure;
      }

      final String fileName = user.imageUrl!.split('/').last;
      final FormData formData = FormData.fromMap({
        'profile_image': await MultipartFile.fromFile(
          user.imageUrl!,
          filename: fileName,
        ),
        ...user.toMap(),
      });

      await dio.post(
        '$server/api/users',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await authenticatedUser.getIdToken()}',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      await OneSignal.login(authenticatedUser.uid);

      status = DatabaseStatus.successful;
    } catch (exception, stackTrace) {
      status = DatabaseStatus.failure;
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    }

    return status;
  }

  Future<UserModel?> getUser() async {
    final User authenticatedUser = authService.getUser();

    try {
      final Response<dynamic> response = await dio.get(
        '$server/api/users/${authenticatedUser.uid}',
        options: DioOptions(
          headers: {'Authorization': 'Bearer ${await authenticatedUser.getIdToken()}', 'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final UserModel user = UserModel.fromMap(response.data);

        return user;
      }
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );

      return null;
    }

    return null;
  }

  Future<bool> userExists() async {
    final User authenticatedUser = authService.getUser();

    final Response<dynamic> response = await dio.get(
      '$server/api/users/${authenticatedUser.uid}',
      options: DioOptions(
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
      return DatabaseStatus.successful;
    } catch (e) {
      return DatabaseStatus.failure;
    }
  }
}
