import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/features/settings/pages/account_information_page.dart';
import 'package:thisdatedoesnotexist/app/features/settings/pages/faq_page.dart';
import 'package:thisdatedoesnotexist/app/features/settings/pages/help_and_support_page.dart';
import 'package:thisdatedoesnotexist/app/features/settings/pages/settings_page.dart';
import 'package:thisdatedoesnotexist/app/features/settings/store/settings_store.dart';

class SettingsModule extends Module {
  @override
  void binds(Injector i) {
    i.addLazySingleton((i) => SettingsStore());
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const SettingsPage());
    r.child('/account', child: (context) => AccountInformationPage());
    r.child('/help', child: (context) => const HelpAndSupportPage());
    r.child('/faq', child: (context) => FaqPage());
  }
}
