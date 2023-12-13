import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/database_service.dart';

class AuthGuard extends RouteGuard {
  AuthGuard() : super();

  @override
  Future<bool> canActivate(String path, ModularRoute route) async {
    /*
    final DatabaseService databaseService = DatabaseService();
    final UserModel? user = await databaseService.getUser();

    if (user != null && user.active!) {
      await Modular.to.pushReplacementNamed('/home/');
      return false;
    }
    */

    return true;
  }
}
