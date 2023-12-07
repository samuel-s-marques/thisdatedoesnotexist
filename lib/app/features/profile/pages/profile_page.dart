import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/profile/store/profile_store.dart';
import 'package:thisdatedoesnotexist/app/features/profile/widgets/section_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileStore store = ProfileStore();
  Future<void>? _future;

  @override
  void initState() {
    super.initState();

    _future = store.getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        child: FutureBuilder(
          future: _future,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              final UserModel user = snapshot.data;
              final int age = DateTime.now().year - user.birthdayDate!.year;
              final CountryCode country = CountryCode.fromCountryCode(user.country!);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 1.9,
                    width: MediaQuery.of(context).size.width,
                    child: Material(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: const BorderSide(
                          width: 0.5,
                          color: Colors.black26,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: CachedNetworkImage(
                          imageUrl: user.imageUrl != null ? '${store.server}${user.imageUrl}' : '',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${user.name} ${user.surname}',
                        ),
                        const TextSpan(
                          text: ', ',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        TextSpan(
                          text: age.toString(),
                        ),
                      ],
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    runSpacing: 5,
                    children: [
                      Row(
                        children: [
                          Icon(store.genders[user.sex]),
                          const SizedBox(width: 5),
                          Text(
                            store.genderMap[user.sex]!.capitalize(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.straighten_outlined),
                          const SizedBox(width: 5),
                          Text(
                            '${user.height} m, ${user.weight} kg',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.work_outline),
                          const SizedBox(width: 5),
                          Text(
                            user.occupation!.capitalize(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.home_outlined),
                          const SizedBox(width: 5),
                          Text(
                            'Lives in ${country.name} ${countryCodeToEmoji(country.code!)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SectionWidget(
                    title: 'About me',
                    content: Text(
                      user.bio ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SectionWidget(
                    title: 'Hobbies & Interests',
                    content: Wrap(
                      spacing: 5,
                      children: user.hobbies!
                          .map(
                            (hobby) => Chip(
                              label: Text(
                                hobby.name.capitalize(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SectionWidget(
                    title: 'Relationship Goal',
                    content: Text(
                      user.relationshipGoal ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SectionWidget(
                    title: 'Political View',
                    content: Text(
                      user.politicalView ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SectionWidget(
                    title: 'Religion',
                    content: Text(
                      user.religion ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
