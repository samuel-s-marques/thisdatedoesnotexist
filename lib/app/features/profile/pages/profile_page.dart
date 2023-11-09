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
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO: Add profile images with carrousel
            Placeholder(
              fallbackWidth: double.infinity,
              fallbackHeight: 400,
            ),
            // TODO: Add profile name
            Text('Name Surname'),
            SectionWidget(
              title: 'Bio',
              content: Text('data'),
            )
          ],
        ),
      ),
    );
  }
}
