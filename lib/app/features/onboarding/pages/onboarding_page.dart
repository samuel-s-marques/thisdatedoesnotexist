import 'package:flutter/cupertino.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:thisdatedoesnotexist/app/features/onboarding/store/onboarding_store.dart';

class OnboardingPage extends StatelessWidget {
  OnboardingPage({super.key});

  final OnboardingStore store = OnboardingStore();

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: 'Page one',
          bodyWidget: Column(
            children: [
              Text("Page one"),
            ],
          ),
        ),
        PageViewModel(
          title: 'Hobbies & Interests',
          bodyWidget: Column(
            children: [
              const Text('Pick up to 4 things you do or you have interest in doing. It will help you match with characters with similar interests.'),
              FutureBuilder(
                future: store.getHobbies(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return Container();
                },
              ),
            ],
          ),
        ),
      ],
      showNextButton: false,
      showDoneButton: false,
    );
  }
}
