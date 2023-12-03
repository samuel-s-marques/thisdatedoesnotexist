import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thisdatedoesnotexist/app/core/models/body_type_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/political_view_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/relationship_goal_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/sex_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';
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
  ObservableList<Sex> sexes = ObservableList();
  Map<String, String> sexesMap = {'male': 'Men', 'female': 'Women'};

  @observable
  ObservableList<PoliticalView> selectedPoliticalViewPreferences = ObservableList();

  @observable
  ObservableList<BodyType> selectedBodyTypePreferences = ObservableList();

  @observable
  ObservableList<RelationshipGoal> selectedRelationshipGoalPreferences = ObservableList();

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

      selectedRelationshipGoalPreferences = ObservableList.of(relationshipGoals.map((goal) => RelationshipGoal.fromMap(goal)).toList());
      selectedBodyTypePreferences = ObservableList.of(bodyTypes.map((type) => BodyType.fromMap(type)).toList());
      selectedPoliticalViewPreferences = ObservableList.of(politicalViews.map((view) => PoliticalView.fromMap(view)).toList());
      selectedSexPreferences = ObservableList.of(sexes.map((sex) => Sex.fromMap(sex)).toList());
      ageValues = RangeValues(data['min_age'] ?? 18, data['max_age'] ?? 50);

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

  @action
  Future<bool?> getTodayCards() async {
    if (await getPreferences()) {
      String url = '$server/api/characters?min_age=${ageValues.start.round()}&max_age=${ageValues.end.round()}';

      if (selectedPoliticalViewPreferences.isNotEmpty) {
        url += '&political_view=${selectedPoliticalViewPreferences.join(',')}';
      }

      if (selectedRelationshipGoalPreferences.isNotEmpty) {
        url += '&relationship_goal=${selectedRelationshipGoalPreferences.join(',')}';
      }

      if (selectedBodyTypePreferences.isNotEmpty) {
        url += '&body_type=${selectedBodyTypePreferences.join(',')}';
      }

      if (selectedSexPreferences.isNotEmpty) {
        url += '&sex=${selectedSexPreferences.join(',')}';
      }

      final Response<dynamic> response = await Dio().get(url);

      if (response.statusCode == 200) {
        cards = ObservableList.of((response.data['data'] as List<dynamic>).map((e) => CharacterModel.fromMap(e)).toList());

        /*
        await Future.delayed(const Duration(seconds: 1)).then((_) {
          shakeCards();
        });
        */

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
