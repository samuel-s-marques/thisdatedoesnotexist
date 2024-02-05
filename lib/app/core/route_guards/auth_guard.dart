import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/features/auth/services/auth_service.dart';

class AuthGuard extends RouteGuard {
  AuthGuard() : super(redirectTo: '/login');

  @override
  Future<bool> canActivate(String path, ModularRoute route) async {
    final AuthService auth = Modular.get();

    return auth.isAuthenticated();
  }
}
