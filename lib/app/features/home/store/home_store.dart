import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thisdatedoesnotexist/app/core/models/body_type_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/political_view_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/preferences_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/relationship_goal_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/religion_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/sex_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/chat/chat_module.dart';
import 'package:thisdatedoesnotexist/app/features/home/models/character_model.dart';
import 'package:thisdatedoesnotexist/app/features/profile/profile_module.dart';

part 'home_store.g.dart';

class HomeStore = HomeStoreBase with _$HomeStore;

abstract class HomeStoreBase with Store {
  AuthService authService = AuthService();
  User? authenticatedUser;
  final Dio dio = Dio();
  String server = const String.fromEnvironment('SERVER');
  SharedPreferences? prefs;

  @observable
  int swipes = 20;

  List<Widget> pages = [
    const ChatModule(),
    const ProfileModule(),
  ];

  @observable
  ObservableList<CharacterModel> cards = ObservableList();

  List<String> appbars = ['Home', 'Chat', 'Profile'];

  AppinioSwiperController cardSwiperController = AppinioSwiperController();

  @observable
  RangeValues ageValues = const RangeValues(18, 50);

  @observable
  ObservableList<RelationshipGoal> relationshipGoals = ObservableList();

  @observable
  ObservableList<PoliticalView> politicalViews = ObservableList();

  @observable
  ObservableList<BodyType> bodyTypes = ObservableList();

  @observable
  ObservableList<Religion> religions = ObservableList();

  @observable
  ObservableList<Sex> sexes = ObservableList();
  Map<String, String> sexesMap = {'male': 'Men', 'female': 'Women'};

  @observable
  ObservableList<PoliticalView> selectedPoliticalViewPreferences = ObservableList();

  @observable
  ObservableList<BodyType> selectedBodyTypePreferences = ObservableList();

  @observable
  ObservableList<RelationshipGoal> selectedRelationshipGoalPreferences = ObservableList();

  @observable
  ObservableList<Religion> selectedReligionPreferences = ObservableList();

  @observable
  ObservableList<Sex> selectedSexPreferences = ObservableList();

  @action
  Future<void> selectPoliticalViewPreference({
    required bool selected,
    required PoliticalView view,
  }) async {
    if (selected) {
      selectedPoliticalViewPreferences.add(view);
    } else {
      selectedPoliticalViewPreferences.remove(view);
    }
  }

  @action
  Future<void> selectReligionPreference({
    required bool selected,
    required Religion religion,
  }) async {
    if (selected) {
      selectedReligionPreferences.add(religion);
    } else {
      selectedReligionPreferences.remove(religion);
    }
  }

  @action
  Future<void> selectSexPreference({
    required bool selected,
    required Sex sex,
  }) async {
    if (selected) {
      selectedSexPreferences.add(sex);
    } else {
      selectedSexPreferences.remove(sex);
    }
  }

  @action
  Future<void> selectBodyTypePreference({
    required bool selected,
    required BodyType bodyType,
  }) async {
    if (selected) {
      selectedBodyTypePreferences.add(bodyType);
    } else {
      selectedBodyTypePreferences.remove(bodyType);
    }
  }

  @action
  Future<void> selectRelationshipGoalPreference({
    required bool selected,
    required RelationshipGoal goal,
  }) async {
    if (selected) {
      selectedRelationshipGoalPreferences.add(goal);
    } else {
      selectedRelationshipGoalPreferences.remove(goal);
    }
  }

  @action
  void setAgeValues(RangeValues values) {
    ageValues = values;
  }

  Future<bool> getPreferences() async {
    authenticatedUser ??= authService.getUser();
    final Response response = await dio.get('$server/api/preferences/${authenticatedUser?.uid}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;

      final List<dynamic> sexes = data['sexes'] ?? [];
      final List<dynamic> relationshipGoals = data['relationship_goals'] ?? [];
      final List<dynamic> politicalViews = data['political_views'] ?? [];
      final List<dynamic> bodyTypes = data['body_types'] ?? [];
      final List<dynamic> religions = data['religions'] ?? [];
      final double minAge = checkDouble(data['min_age'] ?? 18);
      final double maxAge = checkDouble(data['max_age'] ?? 50);

      selectedRelationshipGoalPreferences = ObservableList.of(relationshipGoals.map((goal) => RelationshipGoal.fromMap(goal)).toList());
      selectedBodyTypePreferences = ObservableList.of(bodyTypes.map((type) => BodyType.fromMap(type)).toList());
      selectedPoliticalViewPreferences = ObservableList.of(politicalViews.map((view) => PoliticalView.fromMap(view)).toList());
      selectedSexPreferences = ObservableList.of(sexes.map((sex) => Sex.fromMap(sex)).toList());
      selectedReligionPreferences = ObservableList.of(religions.map((religion) => Religion.fromMap(religion)).toList());
      ageValues = RangeValues(minAge, maxAge);

      return true;
    }

    return false;
  }

  Future<void> getRelationshipGoals() async {
    final Response response = await dio.get('$server/api/relationship-goals');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final RelationshipGoal goal = RelationshipGoal.fromMap(data[index]);
        relationshipGoals.add(goal);
      }
    }
  }

  Future<void> getSexes() async {
    final Response response = await dio.get('$server/api/sexes');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final Sex sex = Sex.fromMap(data[index]);
        sexes.add(sex);
      }
    }
  }

  Future<void> getPoliticalViews() async {
    final Response response = await dio.get('$server/api/political-views');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final PoliticalView view = PoliticalView.fromMap(data[index]);
        politicalViews.add(view);
      }
    }
  }

  Future<void> getBodyTypes() async {
    final Response response = await dio.get('$server/api/body-types');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final BodyType bodyType = BodyType.fromMap(data[index]);
        bodyTypes.add(bodyType);
      }
    }
  }

  Future<void> getReligions() async {
    final Response response = await dio.get('$server/api/religions');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final Religion religion = Religion.fromMap(data[index]);
        religions.add(religion);
      }
    }
  }

  @action
  Future<void> shakeCards() async {
    const double distance = 30;

    await cardSwiperController.animateTo(
      const Offset(-distance, 0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
    await cardSwiperController.animateTo(
      const Offset(distance, 0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    await cardSwiperController.animateTo(
      const Offset(0, 0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @action
  Future<void> onSwipe(
    int previousIndex,
    int? currentIndex,
    SwiperActivity activity,
  ) async {
    authenticatedUser ??= authService.getUser();

    if (swipes > 0) {
      if (activity.direction == AxisDirection.right || activity.direction == AxisDirection.left) {
        try {
          final String direction = activity.direction == AxisDirection.right ? 'right' : 'left';

          await dio.post(
            '$server/api/swipes',
            data: {
              'target_id': cards[previousIndex].uuid,
              'swiper_id': authenticatedUser!.uid,
              'direction': direction,
            },
            options: Options(
              headers: {
                'Authorization': 'Bearer ${await authenticatedUser!.getIdToken()}',
                'Content-Type': 'application/json',
              },
            ),
          );

          swipes--;

          await dio.put(
            '$server/api/users',
            data: {
              'swipes': swipes,
              'last_swipe': DateTime.now().toIso8601String(),
            },
            options: Options(
              headers: {
                'Authorization': 'Bearer ${await authenticatedUser!.getIdToken()}',
                'Content-Type': 'application/json',
              },
            ),
          );
        } catch (exception, stackTrace) {
          await Sentry.captureException(
            exception,
            stackTrace: stackTrace,
          );
        }
      }
    }
  }

  @action
  Future<void> savePreferences() async {
    final Preferences preferences = Preferences(
      sexes: selectedSexPreferences,
      relationshipGoals: selectedRelationshipGoalPreferences,
      politicalViews: selectedPoliticalViewPreferences,
      bodyTypes: selectedBodyTypePreferences,
      religions: selectedReligionPreferences,
      minAge: ageValues.start,
      maxAge: ageValues.end,
    );

    await dio.put(
      '$server/api/preferences/${authenticatedUser?.uid}',
      data: preferences.toMap(),
      options: Options(
        headers: {
          'Authorization': 'Bearer ${await authenticatedUser!.getIdToken()}',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  @action
  Future<bool?> getTodayCards() async {
    if (await getPreferences()) {
      String url = '$server/api/characters?uid=${authenticatedUser?.uid}&min_age=${ageValues.start.round()}&max_age=${ageValues.end.round()}';

      if (selectedPoliticalViewPreferences.isNotEmpty) {
        final List<String?> politicalViews = selectedPoliticalViewPreferences.map((e) => e.name).toList();
        url += '&political_view=${politicalViews.join(',')}';
      }

      if (selectedRelationshipGoalPreferences.isNotEmpty) {
        final List<String?> relationshipGoals = selectedRelationshipGoalPreferences.map((e) => e.name).toList();
        url += '&relationship_goal=${relationshipGoals.join(',')}';
      }

      if (selectedBodyTypePreferences.isNotEmpty) {
        final List<String?> bodytypes = selectedBodyTypePreferences.map((e) => e.name).toList();
        url += '&body_type=${bodytypes.join(',')}';
      }

      if (selectedSexPreferences.isNotEmpty) {
        final List<String?> sexes = selectedSexPreferences.map((e) => e.name).toList();
        url += '&sex=${sexes.join(',')}';
      }

      if (selectedReligionPreferences.isNotEmpty) {
        final List<String?> religions = selectedReligionPreferences.map((e) => e.name).toList();
        url += '&religion=${religions.join(',')}';
      }

      final Response<dynamic> response = await Dio().get(url);

      if (response.statusCode == 200) {
        cards = ObservableList.of((response.data['data'] as List<dynamic>).map((e) => CharacterModel.fromMap(e)).toList());

        if (cards.isEmpty) {
          return false;
        }

        await Future.delayed(const Duration(seconds: 1)).then((_) {
          shakeCards();
        });

        return true;
      } else {
        cards = ObservableList.of([]);

        return null;
      }
    }

    return null;
  }

  @observable
  int selectedIndex = 0;

  @action
  void setIndex(int index) {
    selectedIndex = index;
  }

  @action
  void setSwipes(int swipes) => this.swipes = swipes;
}
