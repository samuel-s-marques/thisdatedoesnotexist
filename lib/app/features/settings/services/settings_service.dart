import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:thisdatedoesnotexist/app/core/models/options.dart';
import 'package:thisdatedoesnotexist/app/core/models/return_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/service_return_model.dart';
import 'package:thisdatedoesnotexist/app/core/repository/repository.dart';
import 'package:thisdatedoesnotexist/app/features/auth/services/auth_service.dart';

abstract class SettingsService {
  Future<ServiceReturn> saveFeedback({required String text, required MultipartFile screenshot});
  Future<ServiceReturn> deleteAccount();
  Future<ServiceReturn> logOut();
  Future<ServiceReturn> getReportedCharacters();
  Future<ServiceReturn> getAccountStatus();
  User? getUser();
}

class SettingsServiceImpl implements SettingsService {
  final Repository _repository = Modular.get<Repository>();
  final String _server = const String.fromEnvironment('SERVER');
  FlutterSecureStorage storage = const FlutterSecureStorage();
  final AuthService _authService = Modular.get();

  @override
  Future<ServiceReturn> saveFeedback({required String text, required MultipartFile screenshot}) async {
    try {
      final FormData data = FormData.fromMap({
        'text': text,
        'screenshot': screenshot,
      });

      final Return response = await _repository.post(
        '$_server/api/feedback',
        data,
        options: HttpOptions(),
      );

      return ServiceReturn(success: response.statusCode == 201);
    } catch (e) {
      return ServiceReturn(success: false, message: e.toString());
    }
  }

  @override
  Future<ServiceReturn> deleteAccount() async => _authService.deleteAccount();

  @override
  Future<ServiceReturn> getAccountStatus() async {
    final Return response = await _repository.get(
      '$_server/api/account',
      options: HttpOptions(),
    );

    if (response.statusCode == 200) {
      return ServiceReturn(
        success: true,
        data: response.data,
      );
    }

    return ServiceReturn(success: false);
  }

  @override
  Future<ServiceReturn> getReportedCharacters() async {
    final Return response = await _repository.get(
      '$_server/api/reports',
      options: HttpOptions(),
    );

    if (response.statusCode == 200) {
      return ServiceReturn(
        success: true,
        data: response.data,
      );
    }

    return ServiceReturn(success: false);
  }

  @override
  Future<ServiceReturn> logOut() async => _authService.logout();

  @override
  User? getUser() {
    return _authService.getUser();
  }
}
