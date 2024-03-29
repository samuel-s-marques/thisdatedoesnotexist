import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/core/widgets/section_widget.dart';
import 'package:thisdatedoesnotexist/app/features/profile/store/profile_store.dart';

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
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings/'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
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
              final int age = user.age!;
              final CountryCode country = CountryCode.fromCountryCode(user.country!);
              final String subjectPronoun = user.pronoun!.subjectPronoun!;
              final String objectPronoun = user.pronoun!.objectPronoun!;

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
                  const SizedBox(height: 20),
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
                  if (user.status != 'normal')
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: user.status == 'banned' ? Colors.red : Colors.yellow,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            'This user was ${user.status} for ${user.statusReason}. ${user.statusUntil != null ? 'It will expire on ${DateFormat('HH:mm:ss dd/MM/yyyy').format(user.statusUntil!)}.' : ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: user.status == 'banned' ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  Wrap(
                    runSpacing: 5,
                    children: [
                      Row(
                        children: [
                          Icon(getGenderIconByName(user.sex!)),
                          const SizedBox(width: 5),
                          Text(
                            replaceGender(user.sex!).capitalize(),
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
                          const Icon(Icons.campaign_outlined),
                          const SizedBox(width: 5),
                          Text(
                            'Uses $subjectPronoun/$objectPronoun pronouns',
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
                  SectionWidget(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    title: 'About me',
                    content: Text(
                      user.bio?.trim() ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  SectionWidget(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    title: 'Hobbies & Interests',
                    content: Wrap(
                      spacing: 5,
                      children: user.hobbies!
                          .map(
                            (hobby) => Chip(
                              padding: EdgeInsets.zero,
                              label: Text(
                                hobby.name.capitalize(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  SectionWidget(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    title: 'Relationship Goal',
                    content: Text(
                      user.relationshipGoal?.name!.capitalize() ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  SectionWidget(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    title: 'Political View',
                    content: Text(
                      user.politicalView?.capitalize() ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  SectionWidget(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    title: 'Religion',
                    content: Text(
                      user.religion?.capitalize() ?? '',
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
