import 'dart:io';

import 'package:feedback/feedback.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hive/hive.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:thisdatedoesnotexist/app/app_module.dart';
import 'package:thisdatedoesnotexist/app/app_widget.dart';
import 'package:thisdatedoesnotexist/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const String oneSignalAppId = String.fromEnvironment('ONESIGNAL_APP_ID');

  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment('SENTRY_DSN');
      options.tracesSampleRate = 1.0;
    },
    appRunner: () async {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      OneSignal.initialize(oneSignalAppId);
      final Directory hiveDir = await getTemporaryDirectory();
      Hive.init(hiveDir.path);
      await Hive.openBox('thisdatedoesnotexist');

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
