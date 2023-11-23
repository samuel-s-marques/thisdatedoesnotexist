import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:thisdatedoesnotexist/app/core/models/hobby_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/onboarding/store/onboarding_store.dart';

class OnboardingPage extends StatefulWidget {
  OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final OnboardingStore store = OnboardingStore();

  @override
  void initState() {
    super.initState();

    store.user = UserModel(
      uid: store.authService.getUser().uid,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      bodyPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      pages: [
        PageViewModel(
          title: 'Page one',
          bodyWidget: const Column(
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
        PageViewModel(
          title: 'Your Preferences',
          bodyWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Time to set your preferences. What are you looking for? The more we understand you, the better we can match you.'),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Age range'),
                  Observer(
                    builder: (_) => Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: store.ageValues.start.round().toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                            text: ' - ',
                          ),
                          TextSpan(
                            text: store.ageValues.end.round().toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Observer(
                builder: (_) => RangeSlider(
                  min: 18,
                  max: 50,
                  values: store.ageValues,
                  onChanged: store.setAgeValues,
                ),
              ),
              const SizedBox(height: 15),
              const Text('Relationship goals'),
              const SizedBox(height: 10),
              FutureBuilder(
                future: store.getRelationshipGoals(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    final List<String> goals = snapshot.data;

                    return Observer(
                      builder: (_) => Wrap(
                        spacing: 5,
                        children: goals.map((String goal) {
                          final bool isSelected = store.selectedRelationshipGoal == goal;

                          return ChoiceChip(
                            label: Text(goal.capitalize()),
                            selected: isSelected,
                            onSelected: (_) => store.selectRelationshipGoal(goal),
                          );
                        }).toList(),
                      ),
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
              const SizedBox(height: 15),
              const Text('Political Views'),
              const SizedBox(height: 10),
              FutureBuilder(
                future: store.getPoliticalViews(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    final List<String> views = snapshot.data;

                    return Observer(
                      builder: (_) => Wrap(
                        spacing: 5,
                        children: views.map((String view) {
                          final bool isSelected = store.selectedPoliticalView == view;

                          return ChoiceChip(
                            label: Text(view.capitalize()),
                            selected: isSelected,
                            onSelected: (_) => store.selectPoliticalView(view),
                          );
                        }).toList(),
                      ),
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
        PageViewModel(
          title: 'Welcome!',
          bodyWidget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("You're oficially a part of ThisDateDoesNotExist!"),
              const SizedBox(height: 30),
              Text(
                "Congratulations, ${store.authService.getUser().displayName}! You're now part of a community that values connection and authenticity. Your personalized matches are just a heartbeat away. Swipe, chat, and discover the magic of ThisDateDoesNotExist!",
              ),
            ],
          ),
        ),
      ],
      showNextButton: false,
      done: const Text('Done'),
      onDone: () async => store.onDone(context),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10),
        activeSize: const Size(20, 10),
        activeColor: Theme.of(context).colorScheme.primary,
        color: Colors.black26,
        activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }
}
