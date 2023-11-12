import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/features/profile/widgets/section_widget.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> content;

  const SettingsSection({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return SectionWidget(
      title: title,
      content: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: NeverScrollableScrollPhysics(),
        children: content,
      ),
    );
  }
}
