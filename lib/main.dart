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
  const String oneSignalAppId = String.fromEnvironment('ONESIGNAL_APP_ID');
  WidgetsFlutterBinding.ensureInitialized();

  OneSignal.initialize(oneSignalAppId);
  await OneSignal.Notifications.requestPermission(true);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment('SENTRY_DSN');
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      BetterFeedback(
        child: ModularApp(
          module: AppModule(),
          child: const AppWidget(),
        ),
      ),
    ),
  );
}
