import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
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
        child: Observer(
          builder: (_) => FutureBuilder(
            future: _future,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                final UserModel user = snapshot.data;
                final int age = DateTime.now().year - user.birthdayDate!.year;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 1.7,
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
                    Text('${user.name} ${user.surname}, $age'),
                    Wrap(
                      children: [
                        Row(
                          children: [
                            Icon(store.genders[user.sex]),
                            Text(store.genderMap[user.sex]!.capitalize()),
                          ],
                        ),
                      ],
                    ),
                    SectionWidget(
                      title: 'About me',
                      content: Text(user.bio ?? ''),
                    ),
                    SectionWidget(
                      title: 'Hobbies & Interests',
                      content: Wrap(
                        spacing: 5,
                        children: user.hobbies!
                            .map(
                              (hobby) => Chip(
                                label: Text(
                                  hobby.name.capitalize(),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    SectionWidget(
                      title: 'Relationship Goal',
                      content: Text(user.relationshipGoal ?? ''),
                    ),
                    SectionWidget(
                      title: 'Political View',
                      content: Text(user.politicalView ?? ''),
                    ),
                    SectionWidget(
                      title: 'Religion',
                      content: Text(user.religion ?? ''),
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
      ),
    );
  }
}
