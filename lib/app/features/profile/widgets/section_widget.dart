import 'package:flutter/cupertino.dart';

class SectionWidget extends StatelessWidget {
  final String title;
  final Widget content;

  const SectionWidget({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        content,
      ],
    );
  }
}
