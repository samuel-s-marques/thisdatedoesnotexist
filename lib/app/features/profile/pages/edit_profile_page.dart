import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:thisdatedoesnotexist/app/core/models/base_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/pronoun_model.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/core/widgets/searchable_list_view.dart';
import 'package:thisdatedoesnotexist/app/features/profile/store/profile_store.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ProfileStore store = Modular.get<ProfileStore>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    store.updatedUser = store.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                store.updateUser();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter your name'),
              TextFormField(
                controller: TextEditingController(
                  text: store.user?.name,
                ),
                textCapitalization: TextCapitalization.words,
                onChanged: (value) {
                  if (value.trim().isNotEmpty) {
                    store.updatedUser = store.updatedUser!.copyWith(name: value.trim());
                  }
                },
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
                controller: TextEditingController(
                  text: store.user?.surname,
                ),
                onChanged: (value) {
                  if (value.trim().isNotEmpty) {
                    store.updatedUser = store.updatedUser!.copyWith(surname: value.trim());
                  }
                },
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
              TextField(
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormat('dd/MM/yyyy').format(store.user!.birthDay!),
                ),
                onTap: () => store.selectBirthday(context),
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
                      controller: TextEditingController(
                        text: store.user?.height?.toString() ?? '1.66',
                      ),
                      onChanged: (value) {
                        if (value.trim().isNotEmpty) {
                          final double height = double.parse(value.trim().replaceAll(',', '.'));
                          store.updatedUser = store.updatedUser!.copyWith(height: height);
                        }
                      },
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
                      controller: TextEditingController(
                        text: store.user?.weight?.toString() ?? '60',
                      ),
                      onChanged: (value) {
                        if (value.trim().isNotEmpty) {
                          final double weight = double.parse(value.trim().replaceAll(',', '.'));
                          store.updatedUser = store.updatedUser!.copyWith(weight: weight);
                        }
                      },
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
                controller: TextEditingController(
                  text: store.user?.bio ?? '',
                ),
                maxLength: 500,
                maxLines: null,
                onChanged: (value) {
                  if (value.trim().isNotEmpty) {
                    store.updatedUser = store.updatedUser!.copyWith(bio: value.trim());
                  }
                },
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
                  value: store.user?.sex ?? BaseModel(id: 1, name: 'male'),
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
                  value: store.user?.pronoun ??
                      Pronoun(
                        objectPronoun: 'they',
                        possessiveAdjective: 'their',
                        possessivePronoun: 'theirs',
                        subjectPronoun: 'them',
                        type: 'neutral',
                      ),
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
                  value: store.user?.religion ?? BaseModel(id: 1, name: 'Islam'),
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
                builder: (_) => DropdownButtonFormField<BaseModel>(
                  items: store.relationshipGoals.map((goal) {
                    final String name = goal.name!;

                    return DropdownMenuItem(
                      value: goal,
                      child: Text(name.capitalize()),
                    );
                  }).toList(),
                  value: store.user?.relationshipGoal ?? BaseModel(id: 1, name: 'casual'),
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
                builder: (_) => DropdownButtonFormField<BaseModel>(
                  items: store.politicalViews.map((view) {
                    final String name = view.name!;

                    return DropdownMenuItem(
                      value: view,
                      child: Text(name.capitalize()),
                    );
                  }).toList(),
                  value: store.user?.politicalView ?? BaseModel(id: 1, name: 'Far left'),
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
                  controller: TextEditingController(
                    text: store.user?.occupation?.name ?? 'Select an occupation',
                  ),
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
                initialSelection: store.user?.country ?? 'Brasil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
