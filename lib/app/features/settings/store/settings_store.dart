import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/core/enum/auth_status_enum.dart';
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';

part 'settings_store.g.dart';

class SettingsStore = SettingsStoreBase with _$SettingsStore;

abstract class SettingsStoreBase with Store {
  AuthService authService = AuthService();

  @action
  Future<void> logOut(BuildContext context) async {
    if (await authService.logout() == AuthStatus.successful) {
      await Modular.to.pushReplacementNamed('/');
      context.showSnackBarSuccess(message: 'Logged out successfully.');
    } else {
      context.showSnackBarError(message: 'Error logging out. Try again later.');
    }
  }
}
