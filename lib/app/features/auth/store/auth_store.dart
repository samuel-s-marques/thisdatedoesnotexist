import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';

part 'auth_store.g.dart';

class AuthStore = _AuthStoreBase with _$AuthStore;

abstract class _AuthStoreBase with Store {
  @observable
  bool isLoading = false;

  @observable
  bool obscurePassword = true;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repeatPasswordController = TextEditingController();

  @action
  Future<void> signUp(BuildContext context) async {
    isLoading = true;

    try {} catch (error) {}

    isLoading = false;
  }

  @action
  Future<void> signIn(BuildContext context) async {
    isLoading = true;

    try {} catch (error) {}

    isLoading = false;
  }
}
