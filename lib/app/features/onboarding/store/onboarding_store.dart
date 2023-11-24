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
  ObservableMap<String, List<Hobby>> groupedHobbies = ObservableMap();

  @observable
  ObservableList<String> relationshipGoals = ObservableList();

  @observable
  ObservableList<String> politicalViews = ObservableList();

  @observable
  ObservableList<String> bodyTypes = ObservableList();

  @observable
  ObservableList<String> sexes = ObservableList();
  Map<String, String> sexesMap = {'male': 'Men', 'female': 'Women'};

  @observable
  ObservableList<String> selectedPoliticalViewPreferences = ObservableList();

  @observable
  ObservableList<String> selectedBodyTypePreferences = ObservableList();

  @observable
  ObservableList<String> selectedRelationshipGoalPreferences = ObservableList();

  @observable
  ObservableList<String> selectedSexPreferences = ObservableList();

  @observable
  String selectedRelationshipGoal = '';

  @observable
  String selectedPoliticalView = '';

  @action
  void selectRelationshipGoal(String goal) {
    selectedRelationshipGoal = goal;
  }

  @action
  void selectPoliticalView(String view) {
    selectedPoliticalView = view;
  }

  @action
  void setAgeValues(RangeValues values) {
    ageValues = values;
  }

  @action
  void selectPoliticalViewPreference({
    required bool selected,
    required String view,
  }) {
    if (selected) {
      selectedPoliticalViewPreferences.add(view);
    } else {
      selectedPoliticalViewPreferences.remove(view);
    }
  }

  @action
  void selectSexPreference({
    required bool selected,
    required String sex,
  }) {
    if (selected) {
      selectedSexPreferences.add(sex);
    } else {
      selectedSexPreferences.remove(sex);
    }
  }

  @action
  void selectBodyTypePreference({
    required bool selected,
    required String bodyType,
  }) {
    if (selected) {
      selectedBodyTypePreferences.add(bodyType);
    } else {
      selectedBodyTypePreferences.remove(bodyType);
    }
  }

  @action
  void selectRelationshipGoalPreference({
    required bool selected,
    required String goal,
  }) {
    if (selected) {
      selectedRelationshipGoalPreferences.add(goal);
    } else {
      selectedRelationshipGoalPreferences.remove(goal);
    }
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

  Future<void> getHobbies() async {
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
    }
  }

  Future<void> getRelationshipGoals() async {
    final Response response = await dio.get('$server/api/relationship-goals');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final String goal = data[index]['name'];
        relationshipGoals.add(goal);
      }
    }
  }

  Future<void> getPoliticalViews() async {
    final Response response = await dio.get('$server/api/political-views');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final String view = data[index]['name'];
        politicalViews.add(view);
      }
    }
  }

  Future<void> getSexes() async {
    final Response response = await dio.get('$server/api/sexes');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final String view = data[index]['name'];
        sexes.add(view);
      }
    }
  }

  Future<void> getBodyTypes() async {
    final Response response = await dio.get('$server/api/body-types');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final String bodyType = data[index]['name'];
        bodyTypes.add(bodyType);
      }
    }
  }

  Future<void> setPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('minAge', ageValues.start);
    await prefs.setDouble('maxAge', ageValues.end);
    await prefs.setStringList('relationshipGoals', selectedRelationshipGoalPreferences);
    await prefs.setStringList('politicalViews', selectedPoliticalViewPreferences);
    await prefs.setStringList('bodyTypes', selectedPoliticalViewPreferences);
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
