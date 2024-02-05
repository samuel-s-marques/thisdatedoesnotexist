import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/core/models/service_return_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/features/auth/services/database_service.dart';

abstract class ProfileService {
  Future<UserModel?> getUser();
  Future<ServiceReturn> updateUser(UserModel user);
}

class ProfileServiceImpl implements ProfileService {
  final DatabaseService _databaseService = Modular.get();

  @override
  Future<UserModel?> getUser() async {
    final ServiceReturn response = await _databaseService.getUser();

    if (response.success) {
      return response.data;
    }

    return null;
  }

  @override
  Future<ServiceReturn> updateUser(UserModel user) async {
    return _databaseService.updateUser(user);
  }
}
