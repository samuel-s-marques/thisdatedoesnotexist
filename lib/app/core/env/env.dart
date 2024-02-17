import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'SENTRY_DSN', obfuscate: true)
  static String sentryDsn = _Env.sentryDsn;

  @EnviedField(varName: 'SERVER', obfuscate: true)
  static String server = _Env.server;

  @EnviedField(varName: 'WSS_SERVER', obfuscate: true)
  static String wssServer = _Env.wssServer;

  @EnviedField(varName: 'ONESIGNAL_APP_ID', obfuscate: true)
  static String oneSignalAppId = _Env.oneSignalAppId;
}
