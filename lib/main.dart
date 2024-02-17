import 'dart:io';

import 'package:feedback/feedback.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hive/hive.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:thisdatedoesnotexist/app/app_module.dart';
import 'package:thisdatedoesnotexist/app/app_widget.dart';
import 'package:thisdatedoesnotexist/app/core/env/env.dart';
import 'package:thisdatedoesnotexist/app/features/notification/store/notification_store.dart';
import 'package:thisdatedoesnotexist/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final String oneSignalAppId = Env.oneSignalAppId;

  await SentryFlutter.init(
    (options) {
      options.dsn = Env.sentryDsn;
      options.tracesSampleRate = 1.0;
    },
    appRunner: () async {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      OneSignal.initialize(oneSignalAppId);
      final Directory hiveDir = await getTemporaryDirectory();
      Hive.init(hiveDir.path);
      await Hive.openBox('thisdatedoesnotexist');

      OneSignal.Notifications.addForegroundWillDisplayListener((notificationReceivedEvent) {
        try {
          final NotificationStore? notificationStore = Modular.tryGet<NotificationStore>();

          if (notificationStore != null) {
            notificationStore.setNotificationState(value: true);
          }
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      });

      return runApp(
        BetterFeedback(
          child: ModularApp(
            module: AppModule(),
            child: const AppWidget(),
          ),
        ),
      );
    },
  );
}
