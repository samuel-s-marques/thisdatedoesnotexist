import 'package:cloud_firestore/cloud_firestore.dart';
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
  FirebaseFirestore db = FirebaseFirestore.instance;
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
            'Content-Type': 'application/json'
          },
        ),
      );

      status = DatabaseStatus.successful;
    } catch (error) {
      status = DatabaseStatus.failure;
    }

    return status;
  }

  Future<UserModel> getUser() async {
    final User authenticatedUser = authService.getUser();
    final DocumentSnapshot<Map<String, dynamic>> user = await db.collection('users').doc(authenticatedUser.uid).get();

    return UserModel.fromMap(user.data()!);
  }

  Future<bool> userExists() async {
    final User authenticatedUser = authService.getUser();
    final DocumentSnapshot<Map<String, dynamic>> user = await db.collection('users').doc(authenticatedUser.uid).get();

    return user.exists;
  }

  Future<DatabaseStatus> updateUser(UserModel user) async {
    try {
      final User authenticatedUser = authService.getUser();
      await db.collection('users').doc(authenticatedUser.uid).set(user.toMap(), SetOptions(merge: true));
      return DatabaseStatus.successful;
    } catch (e) {
      return DatabaseStatus.failure;
    }
  }
}
