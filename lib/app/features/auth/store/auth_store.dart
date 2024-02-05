import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/core/exceptions/auth_exception.dart';
import 'package:thisdatedoesnotexist/app/core/models/service_return_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/auth/services/auth_service.dart';
import 'package:thisdatedoesnotexist/app/features/auth/services/database_service.dart';

part 'auth_store.g.dart';

class AuthStore = AuthStoreBase with _$AuthStore;

abstract class AuthStoreBase with Store {
  AuthService service = Modular.get();
  DatabaseService databaseService = Modular.get();

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

    final ServiceReturn response = await service.createAccount(
      email: emailController.text,
      password: passwordController.text,
    );

    if (response.success) {
      context.showSnackBarSuccess(message: 'Signed up with e-mail and password!');
      await Modular.to.pushReplacementNamed('/onboarding/');
    } else {
      final String error = AuthExceptionHandler.generateErrorMessage(response.data);
      context.showSnackBarError(message: error);
    }

    isLoading = false;
  }

  @action
  Future<void> signIn(BuildContext context) async {
    isLoading = true;

    final ServiceReturn response = await service.login(
      email: emailController.text,
      password: passwordController.text,
    );

    if (response.success) {
      final ServiceReturn dbResponse = await databaseService.getUser();
      final UserModel? user = dbResponse.data;

      if (user == null || user.active == false) {
        await Modular.to.pushReplacementNamed('/onboarding/');
      } else {
        await Modular.to.pushReplacementNamed('/home/');
      }

      context.showSnackBarSuccess(message: 'Signed in with e-mail and password!');
    } else {
      final String error = AuthExceptionHandler.generateErrorMessage(response.data);
      context.showSnackBarError(message: error);
    }

    isLoading = false;
  }

  @action
  Future<void> signInWithGoogle(BuildContext context) async {
    isLoading = true;

    final ServiceReturn response = await service.loginWithGoogle();

    if (response.success) {
      final ServiceReturn dbResponse = await databaseService.getUser();
      final UserModel? user = dbResponse.data;

      if (user == null || user.active == false) {
        await Modular.to.pushReplacementNamed('/onboarding/');
      } else {
        await Modular.to.pushReplacementNamed('/home/');
      }

      context.showSnackBarSuccess(message: 'Signed in with Google!');
    } else {
      final String error = AuthExceptionHandler.generateErrorMessage(response.data);
      context.showSnackBarError(message: error);
    }

    isLoading = false;
  }

  @action
  void toggleIsSignUp() => isSignUp = !isSignUp;

  @action
  Future<void> forgotPassword(BuildContext context) async {
    isLoading = true;

    final ServiceReturn response = await service.resetPassword(email: emailController.text);

    if (response.success) {
      context.showSnackBarSuccess(message: 'Sent reset password e-mail!');
    } else {
      final String error = AuthExceptionHandler.generateErrorMessage(response.data);
      context.showSnackBarError(message: error);
    }

    isLoading = false;
  }

  Future<void> checkAuth() async {
    final bool isAuthenticated = await service.isAuthenticated();

    if (isAuthenticated) {
      await Modular.to.pushReplacementNamed('/home/');
    } else {
      await Modular.to.pushReplacementNamed('/login');
    }
  }
}
