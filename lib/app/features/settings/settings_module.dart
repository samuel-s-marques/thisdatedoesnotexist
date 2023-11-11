import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/core/widgets/widget_module.dart';
import 'package:thisdatedoesnotexist/app/features/settings/pages/settings_page.dart';
import 'package:thisdatedoesnotexist/app/features/settings/store/settings_store.dart';

class SettingsModule extends WidgetModule {
  @override
  void binds(Injector i) {
    i.addLazySingleton((i) => SettingsStore());
  }

  @override
  Widget get view => SettingsPage();
}
