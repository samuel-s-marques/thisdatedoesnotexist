import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    this.titleStyle,
    this.subtitle,
    this.onTap,
    this.leading,
    this.trailing,
  });
  final String title;
  final TextStyle? titleStyle;
  final String? subtitle;
  final GestureTapCallback? onTap;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                leading!,
              ],
            )
          : null,
      trailing: trailing,
      title: Text(
        title,
        style: titleStyle,
      ),
      contentPadding: EdgeInsets.zero,
      subtitle: subtitle != null ? Text(subtitle!) : null,
      onTap: onTap,
    );
  }
}
