import 'package:flutter/material.dart';

extension UserExtension on String {
  String toUsername() {
    final List<String> splittedEmail = split('@');
    return splittedEmail[0];
  }
}

extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    IconData? icon,
    Color backgroundColor = Colors.white,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) Icon(icon),
            if (icon != null) const SizedBox(width: 10),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void showSnackBarError({
    required String message,
    IconData icon = Icons.error,
    Color iconColor = Colors.white,
    Color backgroundColor = Colors.red,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void showSnackBarSuccess({
    required String message,
    IconData icon = Icons.check_circle,
    Color iconColor = Colors.white,
    Color backgroundColor = Colors.green,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
