import 'package:firebase_auth/firebase_auth.dart';
import 'package:thisdatedoesnotexist/app/core/enum/auth_status_enum.dart';

class AuthExceptionHandler {
  static handleAuthException(FirebaseAuthException exception) {
    AuthStatus status;

    switch (exception.code) {
      case 'invalid-email':
        status = AuthStatus.invalidEmail;
        break;
      case 'user-disabled':
        status = AuthStatus.userDisabled;
        break;
      case 'user-not-found':
        status = AuthStatus.userNotFound;
        break;
      case 'wrong-password':
        status = AuthStatus.wrongPassword;
        break;
      case 'email-already-in-use':
        status = AuthStatus.emailAlreadyInUse;
        break;
      case 'weak-password':
        status = AuthStatus.weakPassword;
        break;
      default:
        status = AuthStatus.unknown;
    }

    return status;
  }

  static String generateErrorMessage(AuthStatus status) {
    String errorMessage;

    switch (status) {
      case AuthStatus.invalidEmail:
        errorMessage = 'Your e-mail address seems to be invalid.';
        break;
      case AuthStatus.userDisabled:
        errorMessage = 'User disabled.';
        break;
      case AuthStatus.userNotFound:
        errorMessage = 'This user was not found.';
        break;
      case AuthStatus.wrongPassword:
        errorMessage = 'Your e-mail or password is wrong.';
        break;
      case AuthStatus.emailAlreadyInUse:
        errorMessage = 'This e-mail address is already in use.';
        break;
      case AuthStatus.weakPassword:
        errorMessage = 'This password is weak.';
        break;
      default:
        errorMessage = 'An unknown error occurred.';
    }

    return errorMessage;
  }
}
