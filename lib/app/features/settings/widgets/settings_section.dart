import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/core/widgets/section_widget.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.content,
  });
  final String title;
  final List<Widget> content;

  @override
  Widget build(BuildContext context) {
    return SectionWidget(
      title: title,
      content: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        children: content,
      ),
    );
  }
}
