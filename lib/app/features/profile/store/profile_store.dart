import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';
import 'package:thisdatedoesnotexist/app/core/services/database_service.dart';

part 'profile_store.g.dart';

class ProfileStore = ProfileStoreBase with _$ProfileStore;

abstract class ProfileStoreBase with Store {
  String server = const String.fromEnvironment('SERVER');
  DatabaseService databaseService = DatabaseService();
  AuthService authService = AuthService();
  User? authenticatedUser;

  @action
  Future<UserModel?> getUser() async {
    authenticatedUser = authService.getUser();
    return databaseService.getUser();
  }
}
