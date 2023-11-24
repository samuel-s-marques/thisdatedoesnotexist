import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thisdatedoesnotexist/app/core/enum/database_status_enum.dart';
import 'package:thisdatedoesnotexist/app/core/models/hobby_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';
import 'package:thisdatedoesnotexist/app/core/services/database_service.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';

part 'onboarding_store.g.dart';

class OnboardingStore = OnboardingStoreBase with _$OnboardingStore;

abstract class OnboardingStoreBase with Store {
  AuthService authService = AuthService();
  DatabaseService databaseService = DatabaseService();
  String server = const String.fromEnvironment('SERVER');
  final Dio dio = Dio();

  @observable
  UserModel? user;

  @observable
  RangeValues ageValues = const RangeValues(18, 50);

  @observable
  ObservableList<Hobby> selectedHobbies = ObservableList();

  @observable
  String selectedRelationshipGoal = '';

  @observable
  String selectedRelationshipGoalPreference = '';

  @observable
  String selectedPoliticalView = '';

  @observable
  String selectedPoliticalViewPreference = '';

  @action
  void selectRelationshipGoal(String goal) {
    selectedRelationshipGoal = goal;
  }

  @action
  void selectRelationshipGoalPreference(String goal) {
    selectedRelationshipGoalPreference = goal;
  }

  @action
  void selectPoliticalView(String view) {
    selectedPoliticalView = view;
  }

  @action
  void selectPoliticalViewPreference(String view) {
    selectedPoliticalViewPreference = view;
  }

  @action
  void setAgeValues(RangeValues values) {
    ageValues = values;
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
      goals.add('All');

      return goals;
    } else {
      return goals;
    }
  }

  Future<List<String>> getPoliticalViews() async {
    final List<String> views = [];

    final Response response = await dio.get('$server/api/political-views');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final String view = data[index]['name'];
        views.add(view);
      }
      views.add('All');

      return views;
    } else {
      return views;
    }
  }

  Future<void> setPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('minAge', ageValues.start);
    await prefs.setDouble('maxAge', ageValues.end);
    await prefs.setString('relationshipGoal', selectedRelationshipGoalPreference);
    await prefs.setString('politicalView', selectedPoliticalViewPreference);
  }

  Future<void> onDone(BuildContext context) async {
    user = UserModel(
      uid: authService.getUser().uid,
      active: true,
      hobbies: selectedHobbies,
      swipes: 20,
    );

    if (await databaseService.createUser(user!) == DatabaseStatus.successful) {
      await setPreferences();
      await Modular.to.pushReplacementNamed('/home/');
    } else {
      context.showSnackBarError(
        message: 'Something went wrong. Please try again.',
      );
    }
  }
}
