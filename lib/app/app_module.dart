import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/features/auth/auth_module.dart';
import 'package:thisdatedoesnotexist/app/features/auth/store/auth_store.dart';
import 'package:thisdatedoesnotexist/app/features/home/home_module.dart';
import 'package:thisdatedoesnotexist/app/features/home/store/home_store.dart';

class AppModule extends Module {
  @override
  void binds(i) {
    i.add((i) => AuthStore());
    i.add((i) => HomeStore());
  }

  @override
  void routes(r) {
    r.module('/', module: AuthModule());
    r.module('/home', module: HomeModule());
  }
}
