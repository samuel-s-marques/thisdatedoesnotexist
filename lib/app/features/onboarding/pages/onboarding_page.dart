import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:thisdatedoesnotexist/app/core/models/base_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/hobby_model.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/core/widgets/searchable_list_view.dart';
import 'package:thisdatedoesnotexist/app/features/onboarding/store/onboarding_store.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final OnboardingStore store = OnboardingStore();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    store.getData();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: IntroductionScreen(
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
            title: 'Show yourself',
            bodyWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Upload a photo of yourself!'),
                const SizedBox(height: 15),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 1.7,
                  width: MediaQuery.of(context).size.width,
                  child: Observer(
                    builder: (_) => Material(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(
                          width: store.allowProfileImage != null ? 2.5 : 0.5,
                          color: store.allowProfileImage != null
                              ? store.allowProfileImage == true
                                  ? Colors.green
                                  : Colors.red
                              : Colors.black26,
                        ),
                      ),
                      child: InkWell(
                        onTap: () async => store.pickProfileImage(context),
                        borderRadius: BorderRadius.circular(24),
                        child: Observer(
                          builder: (_) {
                            if (store.profileImagePath != null) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.file(
                                  File(store.profileImagePath!),
                                  fit: BoxFit.cover,
                                ),
                              );
                            } else {
                              return const Icon(
                                Icons.add,
                                color: Colors.black26,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          PageViewModel(
            title: 'Tell us about yourself',
            bodyWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    "Hey there! We're thrilled to have you join our community. To make your experience personalized and enjoyable, we'd love to learn a bit more about you. Just a few quick details, and you'll be all set!"),
                const SizedBox(height: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Enter your name'),
                    TextFormField(
                      controller: store.nameController,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your name.';
                        }

                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Your name',
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('Enter your surname'),
                    TextFormField(
                      controller: store.surnameController,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your surname.';
                        }

                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Your surname',
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('Your birthday'),
                    Observer(
                      builder: (_) => TextField(
                        readOnly: true,
                        controller: store.birthdayController,
                        onTap: () => store.selectBirthday(context),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Your height'),
                        Text('Your weight'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: store.heightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              suffixText: 'm',
                            ),
                            inputFormatters: [store.heightMask],
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your height.';
                              }

                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: store.weightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              suffixText: 'kg',
                            ),
                            inputFormatters: [store.weightMask],
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your weight.';
                              }

                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text('Enter your bio'),
                    TextFormField(
                      controller: store.bioController,
                      maxLength: 500,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Your bio',
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('Enter your sex'),
                    Observer(
                      builder: (_) => DropdownButtonFormField(
                        items: store.sexes.map((sex) {
                          final String name = store.singularSexesMap[sex.name]!;

                          return DropdownMenuItem(
                            value: sex,
                            child: Text(name),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Please enter your sex.';
                          }

                          return null;
                        },
                        onChanged: (sex) => store.selectSex(sex!),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('Select your pronouns'),
                    Observer(
                      builder: (_) => DropdownButtonFormField(
                        items: store.pronouns.map((pronoun) {
                          return DropdownMenuItem(
                            value: pronoun,
                            child: Text('${pronoun.subjectPronoun}/${pronoun.objectPronoun}'),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Please pick your pronouns.';
                          }

                          return null;
                        },
                        onChanged: (pronoun) => store.setPronouns(pronoun!),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('Enter your religion'),
                    Observer(
                      builder: (_) => DropdownButtonFormField(
                        items: store.religions.map((religion) {
                          final String name = religion.name!;

                          return DropdownMenuItem(
                            value: religion,
                            child: Text(name.capitalize()),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Please enter your religion.';
                          }

                          return null;
                        },
                        onChanged: (religion) => store.selectReligion(religion!),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('Enter your relationship goal'),
                    Observer(
                      builder: (_) => DropdownButtonFormField(
                        items: store.relationshipGoals.map((goal) {
                          final String name = goal.name!;

                          return DropdownMenuItem(
                            value: goal,
                            child: Text(name.capitalize()),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Please enter your relationship goal.';
                          }

                          return null;
                        },
                        onChanged: (goal) => store.selectRelationshipGoal(goal!),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('Enter your political view'),
                    Observer(
                      builder: (_) => DropdownButtonFormField(
                        items: store.politicalViews.map((view) {
                          final String name = view.name!;

                          return DropdownMenuItem(
                            value: view,
                            child: Text(name.capitalize()),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Please enter your political view.';
                          }

                          return null;
                        },
                        onChanged: (view) => store.selectPoliticalView(view!),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('Select your occupation'),
                    Observer(
                      builder: (_) => TextFormField(
                        readOnly: true,
                        controller: store.occupationController,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Select an occupation'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: SearchableListView(
                                  items: store.occupations,
                                  onSearch: (searchTerm) {},
                                  onSelectedItem: store.selectOccupation,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('Enter your country'),
                    CountryCodePicker(
                      onChanged: (CountryCode countryCode) => store.selectCountry(countryCode.code!),
                      showCountryOnly: true,
                      padding: EdgeInsets.zero,
                      showOnlyCountryWhenClosed: true,
                      showFlagMain: true,
                      showFlagDialog: true,
                      alignLeft: true,
                    ),
                  ],
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
                    children: store.sexes.map((BaseModel sex) {
                      final bool isSelected = store.selectedSexPreferences.contains(sex);

                      return FilterChip(
                        label: Text(store.pluralSexesMap[sex.name]!),
                        selected: isSelected,
                        onSelected: (bool selected) => store.selectPreference(
                          selected: selected,
                          list: store.selectedSexPreferences,
                          preference: sex,
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
                    max: 70,
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
                    children: store.relationshipGoals.map((BaseModel goal) {
                      final bool isSelected = store.selectedRelationshipGoalPreferences.contains(goal);

                      return FilterChip(
                        label: Text(goal.name!.capitalize()),
                        selected: isSelected,
                        onSelected: (bool selected) => store.selectPreference(
                          selected: selected,
                          list: store.selectedRelationshipGoalPreferences,
                          preference: goal,
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
                    children: store.politicalViews.map((BaseModel view) {
                      final bool isSelected = store.selectedPoliticalViewPreferences.contains(view);

                      return FilterChip(
                        label: Text(view.name!.capitalize()),
                        selected: isSelected,
                        onSelected: (bool selected) => store.selectPreference(
                          selected: selected,
                          list: store.selectedPoliticalViewPreferences,
                          preference: view,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Religions',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Observer(
                  builder: (_) => Wrap(
                    spacing: 5,
                    children: store.religions.map((BaseModel religion) {
                      final bool isSelected = store.selectedReligionPreferences.contains(religion);

                      return FilterChip(
                        label: Text(religion.name!.capitalize()),
                        selected: isSelected,
                        onSelected: (bool selected) => store.selectPreference(
                          selected: selected,
                          list: store.selectedReligionPreferences,
                          preference: religion,
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
                    children: store.bodyTypes.map((BaseModel bodyType) {
                      final bool isSelected = store.selectedBodyTypePreferences.contains(bodyType);

                      return FilterChip(
                        label: Text(bodyType.name!.capitalize()),
                        selected: isSelected,
                        onSelected: (bool selected) => store.selectPreference(
                          selected: selected,
                          list: store.selectedBodyTypePreferences,
                          preference: bodyType,
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
            bodyWidget: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("You're oficially a part of ThisDateDoesNotExist!"),
                SizedBox(height: 30),
                Text(
                  "Congratulations! You're now part of a community that values connection and authenticity. Your personalized matches are just a heartbeat away. Swipe, chat, and discover the magic of ThisDateDoesNotExist!",
                ),
              ],
            ),
          ),
        ],
        showNextButton: false,
        done: const Text('Done'),
        onDone: () async {
          if (formKey.currentState!.validate() && store.profileImagePath != null && store.allowProfileImage == true) {
            await store.onDone(context);
          } else {
            context.showSnackBarError(message: 'Please fill all the fields.');
          }
        },
        dotsFlex: 2,
        dotsDecorator: DotsDecorator(
          size: const Size.square(10),
          activeSize: const Size(20, 10),
          activeColor: Theme.of(context).colorScheme.primary,
          color: Colors.black26,
          activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
      ),
    );
  }
}
