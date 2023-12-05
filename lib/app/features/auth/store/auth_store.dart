import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/core/enum/auth_status_enum.dart';
import 'package:thisdatedoesnotexist/app/core/exceptions/auth_exception.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';
import 'package:thisdatedoesnotexist/app/core/services/database_service.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';

part 'auth_store.g.dart';

class AuthStore = AuthStoreBase with _$AuthStore;

abstract class AuthStoreBase with Store {
  AuthService authService = AuthService();
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController repeatPasswordController;

  @observable
  bool isLoading = false;

  @observable
  bool isSignUp = false;

  @observable
  bool obscurePassword = true;

  @action
  Future<void> signUp(BuildContext context) async {
    isLoading = true;

    final AuthStatus status = await authService.createAccount(
      email: emailController.text,
      password: passwordController.text,
    );

    if (status == AuthStatus.successful) {
      context.showSnackBarSuccess(message: 'Signed up with e-mail and password!');
      await Modular.to.pushReplacementNamed('/onboarding/');
    } else {
      final String error = AuthExceptionHandler.generateErrorMessage(status);
      context.showSnackBarError(message: error);
    }

    isLoading = false;
  }

  @action
  Future<void> signIn(BuildContext context) async {
    isLoading = true;

    final AuthStatus status = await authService.login(
      email: emailController.text,
      password: passwordController.text,
    );
    final DatabaseService databaseService = DatabaseService();

    if (status == AuthStatus.successful) {
      final UserModel? user = await databaseService.getUser();
      if (user == null || user.active == false) {
        await Modular.to.pushReplacementNamed('/onboarding/');
      } else {
        await Modular.to.pushReplacementNamed('/home/');
      }

      context.showSnackBarSuccess(message: 'Signed in with e-mail and password!');
    } else {
      final String error = AuthExceptionHandler.generateErrorMessage(status);
      context.showSnackBarError(message: error);
    }

    isLoading = false;
  }

  @action
  Future<void> signInWithGoogle(BuildContext context) async {
    isLoading = true;

    final AuthStatus status = await authService.loginWithGoogle();
    final DatabaseService databaseService = DatabaseService();

    if (status == AuthStatus.successful) {
      final UserModel? user = await databaseService.getUser();
      if (user == null || user.active == false) {
        await Modular.to.pushReplacementNamed('/onboarding/');
      } else {
        await Modular.to.pushReplacementNamed('/home/');
      }

      context.showSnackBarSuccess(message: 'Signed in with Google!');
    } else {
      final String error = AuthExceptionHandler.generateErrorMessage(status);
      context.showSnackBarError(message: error);
    }

    isLoading = false;
  }

  @action
  void toggleIsSignUp() => isSignUp = !isSignUp;

  @action
  Future<void> forgotPassword(BuildContext context) async {
    isLoading = true;

    final AuthStatus status = await authService.resetPassword(email: emailController.text);

    if (status == AuthStatus.successful) {
      context.showSnackBarSuccess(message: 'Sent reset password e-mail!');
    } else {
      final String error = AuthExceptionHandler.generateErrorMessage(status);
      context.showSnackBarError(message: error);
    }

    isLoading = false;
  }

  Future<void> checkLogin() async {
    final DatabaseService databaseService = DatabaseService();
    final UserModel? user = await databaseService.getUser();

    if (user != null && user.active!) {
      await Modular.to.pushReplacementNamed('/home/');
    }
  }
}
