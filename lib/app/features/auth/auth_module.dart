import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/features/auth/pages/auth_page.dart';
import 'package:thisdatedoesnotexist/app/features/auth/pages/check_auth_page.dart';
import 'package:thisdatedoesnotexist/app/features/auth/pages/forgot_password_page.dart';
import 'package:thisdatedoesnotexist/app/features/auth/services/auth_service.dart';
import 'package:thisdatedoesnotexist/app/features/auth/services/database_service.dart';
import 'package:thisdatedoesnotexist/app/features/auth/store/auth_store.dart';

class AuthModule extends Module {
  @override
  void binds(i) {
    i.addSingleton<AuthService>(AuthServiceImpl.new);
    i.addSingleton<DatabaseService>(DatabaseServiceImpl.new);
    i.addLazySingleton((i) => AuthStore());
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const CheckAuthPage());
    r.child('/login', child: (context) => const AuthPage());
    r.child('/forgot_password', child: (context) => const ForgotPasswordPage());
  }
}
