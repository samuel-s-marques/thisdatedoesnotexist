import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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

    try {} catch (error) {}

    isLoading = false;
  }

  @action
  Future<void> signInWithGoogle(BuildContext context) async {
    isLoading = true;

    try {} catch (error) {}

    isLoading = false;
  }

  @action
  void toggleIsSignUp() => isSignUp = !isSignUp;
}
