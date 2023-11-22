import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/core/models/hobby_model.dart';

part 'onboarding_store.g.dart';

class OnboardingStore = OnboardingStoreBase with _$OnboardingStore;

abstract class OnboardingStoreBase with Store {
  String server = const String.fromEnvironment('SERVER');

  @observable
  ObservableList<Hobby> selectedHobbies = ObservableList();

  @action
  void selectHobby() {}

  Future<Map<String, List<Hobby>>> getHobbies() async {
    final Dio dio = Dio();
    final Map<String, List<Hobby>> groupedHobbies = {};

    final Response response = await dio.get('$server/api/hobbies');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final Hobby hobby = Hobby.fromMap(data[index]);

        if (!groupedHobbies.containsKey(hobby.type)) {
          groupedHobbies[hobby.type] = [];
        }

        groupedHobbies[hobby.type]!.add(hobby);
      }

      return groupedHobbies;
    } else {
      return groupedHobbies;
    }
  }
}
