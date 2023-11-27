import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:thisdatedoesnotexist/app/core/models/hobby_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/onboarding/store/onboarding_store.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

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
    store.getHobbies();
    store.getPoliticalViews();
    store.getRelationshipGoals();
    store.getBodyTypes();
    store.getSexes();
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      bodyPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      pages: [
        PageViewModel(
          title: 'Discover Your Perfect Match!',
          bodyWidget: const Column(
            children: [
              Text(
                "Welcome to This Date Does Not Exist, where we believe in the power of genuine connections. Whether you're looking for a soulmate, a new friend, or just someone to share common interests with, you're in the right place. Let's get started on your journey to meaningful connections!",
              ),
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
              Observer(
                builder: (_) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: store.groupedHobbies.keys.map((String key) {
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
                            children: store.groupedHobbies[key]!.map((Hobby hobby) {
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
              ),
            ],
          ),
        ),
        PageViewModel(
          title: 'Your Preferences',
          bodyWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Time to set your preferences. What are you looking for? The more we understand you, the better we can match you.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Who would you like to meet?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Observer(
                builder: (_) => Wrap(
                  spacing: 5,
                  children: store.sexes.map((String sex) {
                    final bool isSelected = store.selectedSexPreferences.contains(sex);

                    return FilterChip(
                      label: Text(store.sexesMap[sex]!.capitalize()),
                      selected: isSelected,
                      onSelected: (bool selected) => store.selectSexPreference(
                        selected: selected,
                        sex: sex,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Age range',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
              const Text(
                'Relationship goals',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Observer(
                builder: (_) => Wrap(
                  spacing: 5,
                  children: store.relationshipGoals.map((String goal) {
                    final bool isSelected = store.selectedRelationshipGoalPreferences.contains(goal);

                    return FilterChip(
                      label: Text(goal.capitalize()),
                      selected: isSelected,
                      onSelected: (bool selected) => store.selectRelationshipGoalPreference(
                        selected: selected,
                        goal: goal,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Political Views',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Observer(
                builder: (_) => Wrap(
                  spacing: 5,
                  children: store.politicalViews.map((String view) {
                    final bool isSelected = store.selectedPoliticalViewPreferences.contains(view);

                    return FilterChip(
                      label: Text(view.capitalize()),
                      selected: isSelected,
                      onSelected: (bool selected) => store.selectPoliticalViewPreference(
                        selected: selected,
                        view: view,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Body Types',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Observer(
                builder: (_) => Wrap(
                  spacing: 5,
                  children: store.bodyTypes.map((String bodyType) {
                    final bool isSelected = store.selectedBodyTypePreferences.contains(bodyType);

                    return FilterChip(
                      label: Text(bodyType.capitalize()),
                      selected: isSelected,
                      onSelected: (bool selected) => store.selectBodyTypePreference(
                        selected: selected,
                        bodyType: bodyType,
                      ),
                    );
                  }).toList(),
                ),
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
