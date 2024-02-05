import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/features/notification/pages/notification_page.dart';
import 'package:thisdatedoesnotexist/app/features/notification/services/notification_service.dart';
import 'package:thisdatedoesnotexist/app/features/notification/store/notification_store.dart';

class NotificationModule extends Module {
  @override
  void binds(i) {
    i.addSingleton<NotificationService>(NotificationServiceImpl.new);
    i.addLazySingleton((i) => NotificationStore());
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const NotificationPage());
  }
}
