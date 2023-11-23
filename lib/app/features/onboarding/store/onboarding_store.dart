import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/core/models/hobby_model.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';

part 'onboarding_store.g.dart';

class OnboardingStore = OnboardingStoreBase with _$OnboardingStore;

abstract class OnboardingStoreBase with Store {
  String server = const String.fromEnvironment('SERVER');
  RangeValues ageValues = const RangeValues(18, 50);
  final Dio dio = Dio();

  @observable
  ObservableList<Hobby> selectedHobbies = ObservableList();

  @observable
  String selectedGoal = '';

  @action
  void selectGoal(String goal) {
    selectedGoal = goal;
  }

  @action
  void selectHobby({
    required bool selected,
    required Hobby hobby,
    required BuildContext context,
  }) {
    if (selected) {
      if (selectedHobbies.length < 4) {
        selectedHobbies.add(hobby);
      } else {
        context.showSnackBarError(
          message: 'You can only select up to 4 hobbies.',
        );
      }
    } else {
      selectedHobbies.remove(hobby);
    }
  }

  Future<Map<String, List<Hobby>>> getHobbies() async {
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

  Future<List<String>> getRelationshipGoals() async {
    final List<String> goals = [];

    final Response response = await dio.get('$server/api/relationship-goals');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final String goal = data[index]['name'];
        goals.add(goal);
      }

      return goals;
    } else {
      return goals;
    }
  }
}
