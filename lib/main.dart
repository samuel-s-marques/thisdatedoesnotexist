import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/app_module.dart';
import 'package:thisdatedoesnotexist/app/app_widget.dart';
import 'package:thisdatedoesnotexist/firebase_options.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SentryFlutter.init(
    (options) {
      options.dsn = String.fromEnvironment('SENTRY_DSN');
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      ModularApp(
        module: AppModule(),
        child: AppWidget(),
      ),
    ),
  );
}
