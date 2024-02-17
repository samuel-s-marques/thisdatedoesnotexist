import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:feedback/feedback.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:thisdatedoesnotexist/app/core/env/env.dart';
import 'package:thisdatedoesnotexist/app/core/models/service_return_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/cache_service.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/settings/services/settings_service.dart';

part 'settings_store.g.dart';

class SettingsStore = SettingsStoreBase with _$SettingsStore;

abstract class SettingsStoreBase with Store {
  String server = Env.server;
  final DateFormat dateFormat = DateFormat('HH:mm:ss dd/MM/yyyy');
  final SettingsService service = Modular.get();

  // TODO: move to JSON file
  Map<String, String> faq = {
    'What is this app?':
        '"This Date Does Not Exist" is a conceptual project designed for a portfolio. It introduces a unique digital experience where users interact with AI-generated characters in a chat and matchmaking environment. The project showcases the fusion of cutting-edge technology to create personalized and engaging interactions.',
    'What are the key features of the project?':
        "The project includes AI characters, generated through the character-forge package, with distinct names, bios, nicknames, hobbies, and interests. It utilizes sophisticated AI to power lifelike dialogues and emulate human conversation. The matchmaking algorithm employs advanced machine learning techniques to identify commonalities between users and AI characters. Additionally, AI-generated photos using Stable Diffusion enhance the realism of the characters' profiles.",
    'How do users engage with AI characters?':
        "Users engage with AI characters in a chat-like environment. The AI characters are designed to emulate real people, and users interact with them as they would with human counterparts. The AI's ability to produce lifelike dialogues creates an immersive experience.",
    'What are the potential use cases for this project?':
        "While initially designed for personal and portfolio purposes, the project has broader implications. It can serve as an experimental platform for studying user-AI interactions and testing the boundaries of AI's ability to replicate human connection. Additionally, it may inspire future projects that leverage AI to create personalized and meaningful experiences.",
    'How are ethical considerations addressed in this project?':
        'Although the project is not intended for commercial use, ethical considerations and user privacy are top priorities. Clear communication with users about the nature of AI characters is emphasized to maintain trust. The project sets a standard for responsible, user-centric AI experiences.',
    'What is the significance of AI-generated photos in the project?':
        "AI-generated photos using Stable Diffusion add an extra layer of authenticity to the characters' profiles, enhancing realism. This contributes to the overall goal of creating a more immersive and engaging user experience.",
  };

  @observable
  String searchFaqQuery = '';

  @observable
  ObservableList<MapEntry<String, String>> filteredFaq = ObservableList();

  @action
  void searchFaq(String query) {
    searchFaqQuery = query;
    filteredFaq.clear();

    if (searchFaqQuery.isEmpty) {
      filteredFaq.clear();
    } else {
      faq.forEach((key, value) {
        if (key.toLowerCase().contains(searchFaqQuery.toLowerCase()) || value.toLowerCase().contains(searchFaqQuery.toLowerCase())) {
          filteredFaq.add(MapEntry(key, value));
        }
      });
    }
  }

  @action
  Future<void> saveFeedback(UserFeedback feedback, BuildContext context) async {
    try {
      final Directory directory = await path_provider.getTemporaryDirectory();
      final Uint8List screenshot = feedback.screenshot;
      await File('${directory.path}/screenshot.png').writeAsBytes(screenshot);

      final ServiceReturn response = await service.saveFeedback(
        text: feedback.text,
        screenshot: await MultipartFile.fromFile(
          '${directory.path}/screenshot.png',
          filename: 'screenshot.png',
        ),
      );

      if (response.success) {
        context.showSnackBarSuccess(message: 'Feedback sent successfully.');
      } else {
        context.showSnackBarError(message: 'Error in server while sending feedback. Try again later.');
      }
    } catch (e) {
      context.showSnackBarError(message: 'Error sending feedback. Try again later.');
    }
  }

  @action
  Future<void> deleteAccount(BuildContext context) async {
    final ServiceReturn response = await service.deleteAccount();

    if (response.success) {
      await Navigator.pushReplacementNamed(context, '/login/');
      await CacheService().clearData();
      context.showSnackBarSuccess(message: 'Account deleted successfully.');
    } else {
      context.showSnackBarError(message: 'Error deleting account. Try again later.');
    }
  }

  @action
  Future<void> logOut(BuildContext context) async {
    final ServiceReturn response = await service.logOut();

    if (response.success) {
      await Navigator.pushReplacementNamed(context, '/login/');
      await CacheService().clearData();
      context.showSnackBarSuccess(message: 'Logged out successfully.');
    } else {
      context.showSnackBarError(message: 'Error logging out. Try again later.');
    }
  }

  @action
  Future<dynamic> getReportedCharacters() async {
    final ServiceReturn response = await service.getReportedCharacters();

    if (response.success) {
      return response.data;
    }

    return null;
  }

  @action
  Future<dynamic> getAccountStatus() async {
    final ServiceReturn response = await service.getReportedCharacters();

    if (response.success) {
      return response.data;
    }

    return null;
  }

  User? getUser() => service.getUser();
}
