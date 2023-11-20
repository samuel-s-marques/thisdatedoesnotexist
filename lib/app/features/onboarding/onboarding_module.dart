import 'package:flutter_modular/flutter_modular.dart';

class OnboardingModule extends Module {
  @override
  void binds(i) {
    // i.addLazySingleton((i) => OnboardingStore());
  }

  @override
  void routes(r) {
    // r.child('/', child: (context) => const OnboardingPage());
  }
}