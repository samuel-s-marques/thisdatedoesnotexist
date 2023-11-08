import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';

part 'auth_store.g.dart';

class AuthStore = AuthStoreBase with _$AuthStore;

abstract class AuthStoreBase with Store {
  @observable
  bool isLoading = false;

  @observable
  bool isSignUp = false;

  @observable
  bool obscurePassword = true;

  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController repeatPasswordController;

  @action
  Future<void> signUp(BuildContext context) async {
    isLoading = true;

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // TODO: Redirect to HomePage or Onboarding
      context.showSnackBarSuccess(message: 'Signed up with e-mail and password!');
    } on FirebaseAuthException catch (error) {
      if (error.code == 'weak-password') {
        context.showSnackBarError(message: 'The password provided is too weak.');
      } else if (error.code == 'email-already-in-use') {
        context.showSnackBarError(message: 'The account already exists for that email.');
      }
    } catch (error) {
      context.showSnackBarError(message: 'An unknown error occurred.');

      // TODO: Implement Sentry
      if (kDebugMode) {
        print(error);
      }
    }

    isLoading = false;
  }

  @action
  Future<void> signIn(BuildContext context) async {
    isLoading = true;

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      context.showSnackBarSuccess(message: 'Signed in with e-mail and password!');
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') {
        context.showSnackBarError(message: 'No user found for that e-mail.');
      } else if (error.code == 'wrong-password') {
        context.showSnackBarError(message: 'Wrong password provided for that user.');
      }
    } catch (error) {
      context.showSnackBarError(message: 'An unknown error occurred.');

      if (kDebugMode) {
        print(error);
      }
    }

    isLoading = false;
  }

  @action
  Future<void> signInWithGoogle(BuildContext context) async {
    isLoading = true;

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      context.showSnackBarSuccess(message: 'Signed in with Google!');
    } catch (error) {
      context.showSnackBarError(message: 'An unknown error occurred.');

      if (kDebugMode) {
        print(error);
      }
    }

    isLoading = false;
  }

  @action
  void toggleIsSignUp() => isSignUp = !isSignUp;
}
