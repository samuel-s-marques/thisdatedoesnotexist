import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:thisdatedoesnotexist/app/core/models/options.dart';
import 'package:thisdatedoesnotexist/app/core/models/return_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/service_return_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/repository/repository.dart';

abstract class DatabaseService {
  Future<ServiceReturn> createUser(UserModel user);
  Future<ServiceReturn> updateUser(UserModel user);
  Future<ServiceReturn> userExists();
  Future<ServiceReturn> getUser();
}

class DatabaseServiceImpl implements DatabaseService {
  final Repository _repository = Modular.get<Repository>();
  final String _server = const String.fromEnvironment('SERVER');
  FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  Future<ServiceReturn> createUser(UserModel user) async {
    try {
      if (user.imageUrl == null) {
        return ServiceReturn(success: false);
      }

      final String fileName = user.imageUrl!.split('/').last;
      final FormData formData = FormData.fromMap({
        'profile_image': await MultipartFile.fromFile(
          user.imageUrl!,
          filename: fileName,
        ),
        ...user.toMap(),
      });

      final Return response = await _repository.post(
        '$_server/api/users',
        formData,
        options: HttpOptions(),
      );

      if (response.statusCode == 201) {
        final String? uid = await storage.read(key: 'uid');
        await OneSignal.login(uid!);

        return ServiceReturn(success: true);
      }

      return ServiceReturn(success: false, message: response.data['error']['details']);
    } catch (e) {
      return ServiceReturn(success: false, message: e.toString());
    }
  }

  @override
  Future<ServiceReturn> getUser() async {
    try {
      final Return response = await _repository.get(
        '$_server/api/users',
        options: HttpOptions(
          cache: false,
        ),
      );

      if (response.statusCode == 200) {
        return ServiceReturn(
          success: true,
          data: UserModel.fromMap(response.data),
        );
      }

      return ServiceReturn(success: false, message: response.data['error']['details']);
    } catch (e) {
      return ServiceReturn(success: false, message: e.toString());
    }
  }

  @override
  Future<ServiceReturn> updateUser(UserModel user) async {
    try {
      final Return response = await _repository.put(
        '$_server/api/users',
        user.toMap(),
        options: HttpOptions(),
      );

      if (response.statusCode == 201) {
        return ServiceReturn(success: true);
      }

      return ServiceReturn(success: false, message: response.data['error']['details']);
    } catch (e) {
      return ServiceReturn(success: false, message: e.toString());
    }
  }

  @override
  Future<ServiceReturn> userExists() async {
    try {
      final Return response = await _repository.get(
        '$_server/api/users',
        options: HttpOptions(),
      );

      if (response.statusCode == 200) {
        return ServiceReturn(success: true);
      }

      return ServiceReturn(success: false, message: response.data['error']['details']);
    } catch (e) {
      return ServiceReturn(success: false, message: e.toString());
    }
  }
}
