import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/core/constants.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_status_enum.dart';

AppConstants appConstants = AppConstants();

double checkDouble(dynamic value) {
  if (value is String) {
    return double.parse(value);
  } else {
    return value.toDouble();
  }
}

extension UserExtension on String {
  String toUsername() {
    final List<String> splittedEmail = split('@');
    return splittedEmail[0];
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    IconData icon = Icons.info,
    Color backgroundColor = Colors.white,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon),
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

String countryCodeToEmoji(String countryCode) {
  final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
  final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
  return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
}

String countryNameToEmoji(String countryName) {
  if (appConstants.countryNames[countryName] == null) {
    return '';
  }

  return countryCodeToEmoji(appConstants.countryNames[countryName]!);
}

String replaceGender(String text) {
  final Map<String, String> genders = {'male': 'man', 'female': 'woman'};

  return genders[text]!;
}

IconData getGenderIconByName(String sex) {
  final Map<String, IconData> genders = {'male': Icons.male_outlined, 'female': Icons.female_outlined};

  return genders[sex]!;
}

extension MessageStatusExtension on MessageStatus {
  IconData toIconData() {
    final Map<MessageStatus, IconData> icons = {
      MessageStatus.sending: Icons.access_time,
      MessageStatus.sent: Icons.done,
      MessageStatus.read: Icons.done_all,
      MessageStatus.failed: Icons.error,
    };

    return icons[this]!;
  }
}
