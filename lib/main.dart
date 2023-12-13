import 'package:feedback/feedback.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
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
      await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize(oneSignalAppId);

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
