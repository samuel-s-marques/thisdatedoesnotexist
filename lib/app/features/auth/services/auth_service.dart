import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:thisdatedoesnotexist/app/core/env/env.dart';
import 'package:thisdatedoesnotexist/app/core/models/options.dart';
import 'package:thisdatedoesnotexist/app/core/models/service_return_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/repository/repository.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/auth/services/database_service.dart';

abstract class AuthService {
  Future<ServiceReturn> createAccount({required String email, required String password});
  Future<ServiceReturn> login({required String email, required String password});
  Future<ServiceReturn> loginWithGoogle();
  Future<ServiceReturn> logout();
  Future<ServiceReturn> resetPassword({required String email});
  Future<ServiceReturn> deleteAccount();
  Future<bool> isAuthenticated();
  Future<String?> getToken();
  User? getUser();
}

class AuthServiceImpl implements AuthService {
  final Repository _repository = Modular.get<Repository>();
  final String _server = Env.server;
  FlutterSecureStorage storage = const FlutterSecureStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _databaseService = Modular.get<DatabaseService>();

  @override
  Future<ServiceReturn> createAccount({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _auth.currentUser!.updateDisplayName(email.toUsername());

      if (await _auth.currentUser!.getIdToken() == null) {
        return ServiceReturn(success: false, message: 'Failed to create an account with e-mail and password.');
      }

      await storage.write(key: 'token', value: await _auth.currentUser!.getIdToken());
      await storage.write(key: 'uid', value: _auth.currentUser!.uid);

      return ServiceReturn(success: true);
    } on FirebaseAuthException catch (e) {
      return ServiceReturn(success: false, message: e.message);
    }
  }

  @override
  Future<ServiceReturn> deleteAccount() async {
    try {
      await _repository.delete('$_server/api/users', options: HttpOptions());

      await _auth.currentUser!.delete();
      await OneSignal.logout();
      await storage.deleteAll();

      return ServiceReturn(success: true);
    } on FirebaseAuthException catch (e) {
      return ServiceReturn(success: false, message: e.message);
    }
  }

  @override
  Future<ServiceReturn> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (await _auth.currentUser!.getIdToken() == null) {
        return ServiceReturn(success: false, message: 'Failed to log in with e-mail and password.');
      }

      await storage.write(key: 'token', value: await _auth.currentUser!.getIdToken());
      await storage.write(key: 'uid', value: _auth.currentUser!.uid);

      return ServiceReturn(success: true);
    } on FirebaseAuthException catch (e) {
      return ServiceReturn(success: false, message: e.message);
    }
  }

  @override
  Future<ServiceReturn> loginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      if (await _auth.currentUser!.getIdToken() == null) {
        return ServiceReturn(success: false, message: 'Failed to sign in with Google.');
      }

      await storage.write(key: 'token', value: await _auth.currentUser!.getIdToken());
      await storage.write(key: 'uid', value: _auth.currentUser!.uid);

      return ServiceReturn(success: true);
    } on FirebaseAuthException catch (e) {
      return ServiceReturn(success: false, message: e.message);
    }
  }

  @override
  Future<ServiceReturn> logout() async {
    try {
      await _auth.signOut();
      await OneSignal.logout();
      await storage.deleteAll();

      return ServiceReturn(success: true);
    } on FirebaseAuthException catch (e) {
      return ServiceReturn(success: false, message: e.message);
    }
  }

  @override
  Future<ServiceReturn> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());

      return ServiceReturn(success: true);
    } on FirebaseAuthException catch (e) {
      return ServiceReturn(success: false, message: e.message);
    }
  }

  @override
  User? getUser() {
    return _auth.currentUser;
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      if (getUser() == null) {
        return false;
      }

      await _auth.currentUser!.reload();
      final ServiceReturn response = await _databaseService.getUser();
      final UserModel? user = response.data;

      return user != null && user.active!;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        return await currentUser.getIdToken();
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('AuthService.getToken: $e');
      }
      return null;
    }
  }
}
