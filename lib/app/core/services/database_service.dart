import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:thisdatedoesnotexist/app/core/enum/database_status_enum.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';

class DatabaseService {
  final AuthService authService = AuthService();

  Future<DatabaseStatus> createUser() async {
    DatabaseStatus status = DatabaseStatus.unknown;
    User authenticatedUser = authService.getUser();

    try {
      await FirebaseChatCore.instance.createUserInFirestore(
        types.User(
          id: authenticatedUser.uid,
          firstName: authenticatedUser.displayName,
          imageUrl: authenticatedUser.photoURL,
        ),
      );

      status = DatabaseStatus.successful;
    } catch (error) {
      status = DatabaseStatus.failure;
    }

    return status;
  }
}
