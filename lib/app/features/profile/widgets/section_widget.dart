import 'package:flutter/cupertino.dart';

class SectionWidget extends StatelessWidget {
  final String title;
  final Widget content;
  final EdgeInsetsGeometry? padding;

  const SectionWidget({
    super.key,
    required this.title,
    required this.content,
    this.padding = const EdgeInsets.only(bottom: 10),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          content,
        ],
      ),
    );
  }
}
