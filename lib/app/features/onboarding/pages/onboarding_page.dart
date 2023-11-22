import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:thisdatedoesnotexist/app/core/models/hobby_model.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/onboarding/store/onboarding_store.dart';

class OnboardingPage extends StatelessWidget {
  OnboardingPage({super.key});

  final OnboardingStore store = OnboardingStore();

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      bodyPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pick up to 4 things you do or you have interest in doing. It will help you match with characters with similar interests.'),
              const SizedBox(height: 15),
              FutureBuilder(
                future: store.getHobbies(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    final Map<String, List<Hobby>> groupedHobbies = snapshot.data;

                    return Observer(
                      builder: (_) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: groupedHobbies.keys.map((String key) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  key.capitalize(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Wrap(
                                  spacing: 5,
                                  children: groupedHobbies[key]!.map((Hobby hobby) {
                                    final bool isSelected = store.selectedHobbies.contains(hobby);

                                    return FilterChip(
                                      label: Text(hobby.name),
                                      selected: isSelected,
                                      onSelected: (bool selected) => store.selectHobby(
                                        selected: selected,
                                        hobby: hobby,
                                        context: context,
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 15),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
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
