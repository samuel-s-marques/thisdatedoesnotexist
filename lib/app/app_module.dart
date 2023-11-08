import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/features/auth/auth_module.dart';
import 'package:thisdatedoesnotexist/app/features/auth/store/auth_store.dart';

class AppModule extends Module {
  @override
  void binds(i) {
    i.add((i) => AuthStore());
  }

  @override
  void routes(r) {
    r.module('/', module: AuthModule());
  }
}
