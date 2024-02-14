import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/core/repository/dio_repository.dart';
import 'package:thisdatedoesnotexist/app/core/repository/repository.dart';
import 'package:thisdatedoesnotexist/app/core/route_guards/auth_guard.dart';
import 'package:thisdatedoesnotexist/app/core/services/data_service.dart';
import 'package:thisdatedoesnotexist/app/core/services/report_service.dart';
import 'package:thisdatedoesnotexist/app/core/services/websocket_service.dart';
import 'package:thisdatedoesnotexist/app/core/store/connectivity_store.dart';
import 'package:thisdatedoesnotexist/app/features/auth/auth_module.dart';
import 'package:thisdatedoesnotexist/app/features/auth/services/auth_service.dart';
import 'package:thisdatedoesnotexist/app/features/auth/services/database_service.dart';
import 'package:thisdatedoesnotexist/app/features/auth/store/auth_store.dart';
import 'package:thisdatedoesnotexist/app/features/chat/chat_module.dart';
import 'package:thisdatedoesnotexist/app/features/chat/services/chat_service.dart';
import 'package:thisdatedoesnotexist/app/features/chat/store/chat_store.dart';
import 'package:thisdatedoesnotexist/app/features/home/services/home_service.dart';
import 'package:thisdatedoesnotexist/app/features/home/store/home_store.dart';
import 'package:thisdatedoesnotexist/app/features/notification/notification_module.dart';
import 'package:thisdatedoesnotexist/app/features/notification/services/notification_service.dart';
import 'package:thisdatedoesnotexist/app/features/notification/store/notification_store.dart';
import 'package:thisdatedoesnotexist/app/features/onboarding/onboarding_module.dart';
import 'package:thisdatedoesnotexist/app/features/onboarding/services/onboarding_service.dart';
import 'package:thisdatedoesnotexist/app/features/onboarding/store/onboarding_store.dart';
import 'package:thisdatedoesnotexist/app/features/profile/services/profile_service.dart';
import 'package:thisdatedoesnotexist/app/features/settings/services/settings_service.dart';
import 'package:thisdatedoesnotexist/app/features/settings/settings_module.dart';
import 'package:thisdatedoesnotexist/app/features/settings/store/settings_store.dart';
import 'package:thisdatedoesnotexist/app/features/start/start_module.dart';
import 'package:thisdatedoesnotexist/app/features/start/store/start_store.dart';

class AppModule extends Module {
  @override
  void binds(i) {
    i.addSingleton<Repository>(DioRepository.new);
    i.addSingleton<NotificationService>(NotificationServiceImpl.new);
    i.addSingleton<OnboardingService>(OnboardingServiceImpl.new);
    i.addSingleton<WebsocketService>(WebsocketServiceImpl.new);
    i.addSingleton<DataService>(DataServiceImpl.new);
    i.addSingleton<HomeService>(HomeServiceImpl.new);
    i.addSingleton<ChatService>(ChatServiceImpl.new);
    i.addSingleton<ReportService>(ReportServiceImpl.new);
    i.addSingleton<ProfileService>(ProfileServiceImpl.new);
    i.addSingleton<SettingsService>(SettingsServiceImpl.new);
    i.addSingleton<DatabaseService>(DatabaseServiceImpl.new);
    i.addSingleton<AuthService>(AuthServiceImpl.new);
    i.addSingleton(NotificationStore.new);
    i.addSingleton(ConnectivityStore.new);
    i.add<AuthStore>((i) => AuthStore());
    i.add<OnboardingStore>((i) => OnboardingStore());
    i.add<HomeStore>((i) => HomeStore());
    i.add<SettingsStore>((i) => SettingsStore());
    i.addSingleton(ChatStore.new);
    i.addSingleton(StartStore.new);
  }

  @override
  void routes(r) {
    r.module('/', module: AuthModule());
    r.module('/onboarding', module: OnboardingModule());
    r.module('/start', module: StartModule(), guards: [AuthGuard()]);
    r.module('/chat', module: ChatModule(), guards: [AuthGuard()]);
    r.module('/settings', module: SettingsModule(), guards: [AuthGuard()]);
    r.module('/notifications', module: NotificationModule(), guards: [AuthGuard()]);
  }
}
