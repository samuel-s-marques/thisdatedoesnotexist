import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/features/profile/services/profile_service.dart';

part 'profile_store.g.dart';

class ProfileStore = ProfileStoreBase with _$ProfileStore;

abstract class ProfileStoreBase with Store {
  final ProfileService service = Modular.get();
  final String server = const String.fromEnvironment('SERVER');

  @action
  Future<UserModel?> getUser() => service.getUser();

  @action
  Future<void> updateUser(UserModel user) => service.updateUser(user);
}
