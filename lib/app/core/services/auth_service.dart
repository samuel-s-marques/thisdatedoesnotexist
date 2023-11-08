import 'package:firebase_auth/firebase_auth.dart';
import 'package:thisdatedoesnotexist/app/core/enum/auth_status_enum.dart';
import 'package:thisdatedoesnotexist/app/core/exceptions/auth_exception.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<AuthStatus> createAccount({required String email, required String password}) async {
    AuthStatus status = AuthStatus.unknown;

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _auth.currentUser!.updateDisplayName(email.toUsername());
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
}
