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

  Future<List<Hobby>> getHobbies() async {
    final Dio dio = Dio();
    final List<Hobby> hobbies = [];

    final Response response = await dio.get('$server/api/hobbies');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final String name = data[index]['name'];
        final String type = data[index]['type'];

        hobbies.add(Hobby(name: name, type: type));
      }

      return hobbies;
    } else {
      return hobbies;
    }
  }
}
