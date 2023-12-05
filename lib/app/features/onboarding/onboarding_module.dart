import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/features/onboarding/pages/onboarding_page.dart';
import 'package:thisdatedoesnotexist/app/features/onboarding/store/onboarding_store.dart';

class OnboardingModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton((i) => OnboardingStore());
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const OnboardingPage());
  }
}