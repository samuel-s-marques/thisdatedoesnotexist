import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/features/auth/auth_module.dart';
import 'package:thisdatedoesnotexist/app/features/auth/store/auth_store.dart';
import 'package:thisdatedoesnotexist/app/features/chat/chat_module.dart';
import 'package:thisdatedoesnotexist/app/features/home/home_module.dart';
import 'package:thisdatedoesnotexist/app/features/home/store/home_store.dart';
import 'package:thisdatedoesnotexist/app/features/settings/settings_module.dart';
import 'package:thisdatedoesnotexist/app/features/settings/store/settings_store.dart';

class AppModule extends Module {
  @override
  void binds(i) {
    i.add((i) => AuthStore());
    i.add((i) => HomeStore());
    i.add((i) => SettingsStore());
  }

  @override
  void routes(r) {
    r.module('/', module: AuthModule());
    r.module('/home', module: HomeModule());
    r.module('/chat', module: const ChatModule());
    r.module('/settings', module: SettingsModule());
  }
}
