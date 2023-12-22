import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:thisdatedoesnotexist/app/core/enum/auth_status_enum.dart';
import 'package:thisdatedoesnotexist/app/core/exceptions/auth_exception.dart';
import 'package:thisdatedoesnotexist/app/core/services/dio_service.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';

class AuthService {
  String server = const String.fromEnvironment('SERVER');
  final _auth = FirebaseAuth.instance;
  final DioService dio = DioService();

  Future<AuthStatus> createAccount({required String email, required String password}) async {
    AuthStatus status = AuthStatus.unknown;

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _auth.currentUser!.updateDisplayName(email.toUsername());
      status = AuthStatus.successful;
    } on FirebaseAuthException catch (exception) {
      status = AuthExceptionHandler.handleAuthException(exception);
    }

    return status;
  }

  Future<AuthStatus> login({required String email, required String password}) async {
    AuthStatus status = AuthStatus.unknown;

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      status = AuthStatus.successful;
    } on FirebaseAuthException catch (exception) {
      status = AuthExceptionHandler.handleAuthException(exception);
    }

    return status;
  }

  Future<AuthStatus> loginWithGoogle() async {
    AuthStatus status = AuthStatus.unknown;

    try {
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      status = AuthStatus.successful;
    } on FirebaseAuthException catch (exception) {
      status = AuthExceptionHandler.handleAuthException(exception);
    }

    return status;
  }

  Future<AuthStatus> logout() async {
    AuthStatus status = AuthStatus.unknown;

    try {
      await _auth.signOut();

      status = AuthStatus.successful;
    } on FirebaseAuthException catch (exception) {
      status = AuthExceptionHandler.handleAuthException(exception);
    }

    return status;
  }

  Future<AuthStatus> resetPassword({required String email}) async {
    AuthStatus status = AuthStatus.unknown;

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());

      status = AuthStatus.successful;
    } on FirebaseAuthException catch (exception) {
      status = AuthExceptionHandler.handleAuthException(exception);
    }

    return status;
  }

  Future<AuthStatus> deleteAccount() async {
    AuthStatus status = AuthStatus.unknown;

    try {
      await dio.delete(
        '$server/api/users',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _auth.currentUser!.getIdToken()}',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      await FirebaseChatCore.instance.deleteUserFromFirestore(_auth.currentUser!.uid);
      await _auth.currentUser!.delete();
      await OneSignal.logout();

      status = AuthStatus.successful;
    } on FirebaseAuthException catch (exception) {
      status = AuthExceptionHandler.handleAuthException(exception);
    }

    return status;
  }

  User getUser() {
    final User? user = _auth.currentUser;

    if (user == null) {
      Modular.to.pushNamed('/');
    }

    return user!;
  }
}
