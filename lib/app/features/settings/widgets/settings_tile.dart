import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final GestureTapCallback? onTap;
  final Widget? leading;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.leading,
    this.trailing,
  });

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
      title: Text(title),
      contentPadding: EdgeInsets.zero,
      subtitle: subtitle != null ? Text(subtitle!) : null,
      onTap: onTap,
    );
  }
}
