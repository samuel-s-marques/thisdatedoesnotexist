import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/features/profile/store/profile_store.dart';
import 'package:thisdatedoesnotexist/app/features/profile/widgets/section_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileStore store = ProfileStore();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO: Add profile image
            Placeholder(
              fallbackWidth: double.infinity,
            ),
            // TODO: Add profile name
            Text('Name Surname'),
            SectionWidget(
              title: 'Bio',
              content: Text('data'),
            ),
            SectionWidget(
              title: 'Interests',
              content: Text('data'),
            ),
            SectionWidget(
              title: 'Hobbies',
              content: Text('data'),
            ),
            SectionWidget(
              title: 'Relationship Goals',
              content: Text('data'),
            ),
          ],
        ),
      ),
    );
  }
}
