import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/core/models/service_return_model.dart';
import 'package:thisdatedoesnotexist/app/features/notification/services/notification_service.dart';
import 'package:uuid/uuid.dart';

part 'notification_store.g.dart';

class NotificationStore = NotificationStoreBase with _$NotificationStore;

abstract class NotificationStoreBase with Store {
  Uuid uuid = const Uuid();
  final DateFormat dateFormat = DateFormat('HH:mm:ss dd/MM/yyyy');
  final String server = const String.fromEnvironment('SERVER');
  final NotificationService service = Modular.get();

  @observable
  bool hasNotifications = false;

  @action
  Future<dynamic> getNotifications() async {
    final ServiceReturn response = await service.getNotifications();
    return response.data;
  }

  @action
  Future<dynamic> getReportedMessages() async {
    final ServiceReturn response = await service.getReportedMessages();
    return response.data;
  }

  @action
  void setNotificationState({required bool value}) {
    hasNotifications = value;
  }
}
