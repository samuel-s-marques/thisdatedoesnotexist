import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:thisdatedoesnotexist/app/core/models/options.dart';
import 'package:thisdatedoesnotexist/app/core/models/return_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/service_return_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/repository/repository.dart';
import 'package:thisdatedoesnotexist/app/features/auth/services/database_service.dart';

abstract class OnboardingService {
  Future<ServiceReturn> upload(dynamic data);
  Future<ServiceReturn> createUser(UserModel user);
}

class OnboardingServiceImpl implements OnboardingService {
  final Repository _repository = Modular.get<Repository>();
  final String _server = const String.fromEnvironment('SERVER');
  FlutterSecureStorage storage = const FlutterSecureStorage();
  final DatabaseService _databaseService = Modular.get();

  @override
  Future<ServiceReturn> upload(dynamic data) async {
    try {
      final Return response = await _repository.post(
        '$_server/api/users/upload',
        data,
        options: HttpOptions(),
      );

      if (response.statusCode == 201) {
        return ServiceReturn(
          success: true,
          data: response.data,
        );
      }

      return ServiceReturn(success: false);
    } catch (e) {
      return ServiceReturn(success: false, message: e.toString());
    }
  }

  @override
  Future<ServiceReturn> createUser(UserModel user) async {
    try {
      return await _databaseService.createUser(user);
    } catch (e) {
      return ServiceReturn(success: false, message: e.toString());
    }
  }
}
