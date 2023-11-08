import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/features/auth/pages/auth_page.dart';
import 'package:thisdatedoesnotexist/app/features/auth/store/auth_store.dart';

class AuthModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton((i) => AuthStore());
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => AuthPage());
  }
}
