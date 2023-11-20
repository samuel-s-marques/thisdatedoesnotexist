import 'package:flutter/cupertino.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:thisdatedoesnotexist/app/features/onboarding/store/onboarding_store.dart';

class OnboardingPage extends StatelessWidget {
  OnboardingPage({super.key});

  final OnboardingStore store = OnboardingStore();

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: store.pages,
      showNextButton: false,
      showDoneButton: false,
    );
  }
}
