import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobx/mobx.dart';

part 'auth_store.g.dart';

class AuthStore = AuthStoreBase with _$AuthStore;

abstract class AuthStoreBase with Store {
  @observable
  bool isLoading = false;

  @observable
  bool isSignUp = false;

  @observable
  bool obscurePassword = true;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repeatPasswordController = TextEditingController();

  @action
  Future<void> signUp(BuildContext context) async {
    isLoading = true;

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'weak-password') {
        // TODO: show error message
        print('The password provided is too weak.');
      } else if (error.code == 'email-already-in-use') {
        // TODO: show error message
        print('The account already exists for that email.');
      }
    } catch (error) {
      // TODO: show error message
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
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') {
        // TODO: show error message
        print('No user found for that email.');
      } else if (error.code == 'wrong-password') {
        // TODO: show error message
        print('Wrong password provided for that user.');
      }
    } catch (error) {
      // TODO: show error message
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
    } catch (error) {
      // TODO: show error message
    }

    isLoading = false;
  }

  @action
  void toggleIsSignUp() => isSignUp = !isSignUp;
}
