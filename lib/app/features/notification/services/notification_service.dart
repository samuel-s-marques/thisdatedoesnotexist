import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:thisdatedoesnotexist/app/core/env/env.dart';
import 'package:thisdatedoesnotexist/app/core/models/options.dart';
import 'package:thisdatedoesnotexist/app/core/models/return_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/service_return_model.dart';
import 'package:thisdatedoesnotexist/app/core/repository/repository.dart';

abstract class NotificationService {
  Future<ServiceReturn> getNotifications();
  Future<ServiceReturn> getReportedMessages();
}

class NotificationServiceImpl implements NotificationService {
  final Repository _repository = Modular.get<Repository>();
  final String _server = Env.server;
  FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  Future<ServiceReturn> getNotifications() async {
    final Return response = await _repository.get(
      '$_server/api/notifications',
      options: HttpOptions(cache: false),
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
  Future<ServiceReturn> getReportedMessages() async {
    final Return response = await _repository.get(
      '$_server/api/status/account',
      options: HttpOptions(cache: false),
    );

    if (response.statusCode == 200) {
      return ServiceReturn(
        success: true,
        data: response.data,
      );
    }

    return ServiceReturn(success: false);
  }
}
