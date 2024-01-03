import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';
import 'package:thisdatedoesnotexist/app/core/services/dio_service.dart';
import 'package:uuid/uuid.dart';

part 'notification_store.g.dart';

class NotificationStore = NotificationStoreBase with _$NotificationStore;

abstract class NotificationStoreBase with Store {
  AuthService authService = AuthService();
  User? authenticatedUser;
  Uuid uuid = const Uuid();
  String server = const String.fromEnvironment('SERVER');
  String wssServer = const String.fromEnvironment('WSS_SERVER');
  final DioService dio = DioService();
  final DateFormat dateFormat = DateFormat('HH:mm:ss dd/MM/yyyy');

  @action
  Future<dynamic> getNotifications() async {
    authenticatedUser ??= authService.getUser();

    final Response<dynamic> response = await dio.get('$server/api/notifications?uid=${authenticatedUser?.uid}', options: DioOptions());

    return response.data;
  }

  @observable
  bool hasNotifications = false;

  @action
  void setNotificationState({required bool value}) {
    hasNotifications = value;
  }

  @action
  Future<dynamic> getReportedMessages() async {
    authenticatedUser ??= authService.getUser();

    final Response<dynamic> response = await dio.get(
      '$server/api/status/account/${authenticatedUser?.uid}',
      options: DioOptions(),
    );

    return response.data;
  }
}
