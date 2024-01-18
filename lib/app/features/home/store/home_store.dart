import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thisdatedoesnotexist/app/core/models/base_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/preferences_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';
import 'package:thisdatedoesnotexist/app/core/services/dio_service.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/chat/chat_module.dart';
import 'package:thisdatedoesnotexist/app/features/profile/profile_module.dart';

part 'home_store.g.dart';

class HomeStore = HomeStoreBase with _$HomeStore;

abstract class HomeStoreBase with Store {
  AuthService authService = AuthService();
  User? authenticatedUser;
  final DioService dio = DioService();
  String server = const String.fromEnvironment('SERVER');
  SharedPreferences? prefs;

  @observable
  int swipes = 20;

  List<Widget> pages = [
    const ChatModule(),
    const ProfileModule(),
  ];

  @observable
  ObservableList<UserModel> cards = ObservableList();

  AppinioSwiperController cardSwiperController = AppinioSwiperController();

  @observable
  RangeValues ageValues = const RangeValues(18, 70);

  @observable
  ObservableList<BaseModel> relationshipGoals = ObservableList();

  @observable
  ObservableList<BaseModel> politicalViews = ObservableList();

  @observable
  ObservableList<BaseModel> bodyTypes = ObservableList();

  @observable
  ObservableList<BaseModel> religions = ObservableList();

  @observable
  ObservableList<BaseModel> sexes = ObservableList();
  Map<String, String> sexesMap = {'male': 'Men', 'female': 'Women'};

  @observable
  ObservableList<BaseModel> selectedPoliticalViewPreferences = ObservableList();

  @observable
  ObservableList<BaseModel> selectedBodyTypePreferences = ObservableList();

  @observable
  ObservableList<BaseModel> selectedRelationshipGoalPreferences = ObservableList();

  @observable
  ObservableList<BaseModel> selectedReligionPreferences = ObservableList();

  @observable
  ObservableList<BaseModel> selectedSexPreferences = ObservableList();

  @observable
  RangeValues lastSelectedAgeValues = const RangeValues(18, 70);

  @observable
  ObservableList<BaseModel> lastSelectedSexPreferences = ObservableList();

  @observable
  ObservableList<BaseModel> lastSelectedReligionPreferences = ObservableList();

  @observable
  ObservableList<BaseModel> lastSelectedRelationshipGoalPreferences = ObservableList();

  @observable
  ObservableList<BaseModel> lastSelectedBodyTypePreferences = ObservableList();

  @observable
  ObservableList<BaseModel> lastSelectedPoliticalViewPreferences = ObservableList();

  @computed
  bool get hasChanges {
    return _listChanged(selectedSexPreferences, lastSelectedSexPreferences) ||
        _listChanged(selectedReligionPreferences, lastSelectedReligionPreferences) ||
        _listChanged(selectedRelationshipGoalPreferences, lastSelectedRelationshipGoalPreferences) ||
        _listChanged(selectedBodyTypePreferences, lastSelectedBodyTypePreferences) ||
        _listChanged(selectedPoliticalViewPreferences, lastSelectedPoliticalViewPreferences) ||
        ageValues != lastSelectedAgeValues;
  }

  bool _listChanged(List<BaseModel> currentList, List<BaseModel> lastList) {
    if (currentList.length != lastList.length) {
      return true;
    }

    for (int index = 0; index < currentList.length; index++) {
      if (currentList[index] != lastList[index]) {
        return true;
      }
    }

    return false;
  }

  @action
  void updateLastSelectedLists() {
    lastSelectedSexPreferences = ObservableList.of(selectedSexPreferences);
    lastSelectedReligionPreferences = ObservableList.of(selectedReligionPreferences);
    lastSelectedRelationshipGoalPreferences = ObservableList.of(selectedRelationshipGoalPreferences);
    lastSelectedBodyTypePreferences = ObservableList.of(selectedBodyTypePreferences);
    lastSelectedPoliticalViewPreferences = ObservableList.of(selectedPoliticalViewPreferences);
    lastSelectedAgeValues = ageValues;
  }

  @observable
  bool gotPreferences = false;

  @action
  Future<void> selectPoliticalViewPreference({
    required bool selected,
    required BaseModel view,
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
    required BaseModel religion,
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
    required BaseModel sex,
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
    required BaseModel bodyType,
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
    required BaseModel goal,
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
    final Response<dynamic> response = await dio.get('$server/api/preferences/${authenticatedUser?.uid}', options: DioOptions());

    if (response.statusCode == 200) {
      final Map<dynamic, dynamic> data = response.data;

      final List<dynamic> sexes = data['sexes'] ?? [];
      final List<dynamic> relationshipGoals = data['relationship_goals'] ?? [];
      final List<dynamic> politicalViews = data['political_views'] ?? [];
      final List<dynamic> bodyTypes = data['body_types'] ?? [];
      final List<dynamic> religions = data['religions'] ?? [];
      final double minAge = checkDouble(data['min_age'] ?? 18);
      final double maxAge = checkDouble(data['max_age'] ?? 70);

      selectedRelationshipGoalPreferences = ObservableList.of(relationshipGoals.map((goal) => BaseModel.fromMap(goal)).toList());
      selectedBodyTypePreferences = ObservableList.of(bodyTypes.map((type) => BaseModel.fromMap(type)).toList());
      selectedPoliticalViewPreferences = ObservableList.of(politicalViews.map((view) => BaseModel.fromMap(view)).toList());
      selectedSexPreferences = ObservableList.of(sexes.map((sex) => BaseModel.fromMap(sex)).toList());
      selectedReligionPreferences = ObservableList.of(religions.map((religion) => BaseModel.fromMap(religion)).toList());
      ageValues = RangeValues(minAge, maxAge);

      updateLastSelectedLists();

      return true;
    }

    return false;
  }

  Future<void> getRelationshipGoals() async {
    final Response<dynamic> response = await dio.get('$server/api/relationship-goals', options: DioOptions());

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final BaseModel goal = BaseModel.fromMap(data[index]);
        relationshipGoals.add(goal);
      }
    }
  }

  Future<void> getSexes() async {
    final Response<dynamic> response = await dio.get('$server/api/sexes', options: DioOptions());

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final BaseModel sex = BaseModel.fromMap(data[index]);
        sexes.add(sex);
      }
    }
  }

  Future<void> getPoliticalViews() async {
    final Response<dynamic> response = await dio.get('$server/api/political-views', options: DioOptions());

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final BaseModel view = BaseModel.fromMap(data[index]);
        politicalViews.add(view);
      }
    }
  }

  Future<void> getBodyTypes() async {
    final Response<dynamic> response = await dio.get('$server/api/body-types', options: DioOptions());

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final BaseModel bodyType = BaseModel.fromMap(data[index]);
        bodyTypes.add(bodyType);
      }
    }
  }

  Future<void> getReligions() async {
    final Response<dynamic> response = await dio.get('$server/api/religions', options: DioOptions());

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final BaseModel religion = BaseModel.fromMap(data[index]);
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
    BuildContext context,
  ) async {
    authenticatedUser ??= authService.getUser();

    switch (activity) {
      case Swipe():
        if (swipes > 0) {
          if (activity.direction == AxisDirection.right || activity.direction == AxisDirection.left) {
            try {
              final String direction = activity.direction == AxisDirection.right ? 'right' : 'left';

              final Response<dynamic> response = await dio.post(
                '$server/api/swipes',
                data: {
                  'target_id': cards[previousIndex].uid,
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

              if (response.statusCode == 200) {
                swipes--;

                if (currentIndex != null && currentIndex == cards.length - 2) {
                  if (meta['current_page'] == meta['last_page']) {
                    return;
                  }

                  currentPage++;
                  await getTodayCards();
                }
              } else {
                context.showSnackBarError(message: response.data['error']);
              }
            } catch (exception, stackTrace) {
              await Sentry.captureException(
                exception,
                stackTrace: stackTrace,
              );
            }
          }
        }
        break;
      default:
    }
  }

  @action
  Future<bool> savePreferences() async {
    final Preferences preferences = Preferences(
      sexes: selectedSexPreferences,
      relationshipGoals: selectedRelationshipGoalPreferences,
      politicalViews: selectedPoliticalViewPreferences,
      bodyTypes: selectedBodyTypePreferences,
      religions: selectedReligionPreferences,
      minAge: ageValues.start,
      maxAge: ageValues.end,
    );

    final Response<dynamic> response = await dio.put(
      '$server/api/preferences/${authenticatedUser?.uid}',
      data: preferences.toMap(),
      options: Options(
        headers: {
          'Authorization': 'Bearer ${await authenticatedUser!.getIdToken()}',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      updateLastSelectedLists();
      return true;
    }

    return false;
  }

  @observable
  int currentPage = 1;

  @observable
  ObservableMap<String, dynamic> meta = ObservableMap();

  @action
  Future<bool?> getTodayCards() async {
    if (selectedIndex != 0) {
      currentPage = 1;
      return null;
    }

    if (!gotPreferences) {
      gotPreferences = await getPreferences();
    }

    if (gotPreferences) {
      String url = '$server/api/characters?uid=${authenticatedUser?.uid}&min_age=${ageValues.start.round()}&max_age=${ageValues.end.round()}&page=$currentPage';

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

      final Response<dynamic> response = await dio.get(
        url,
        options: DioOptions(
          cache: false,
        ),
      );

      if (response.statusCode == 200) {
        cards = ObservableList.of((response.data['data'] as List<dynamic>).map((e) => UserModel.fromMap(e['profile'])).toList());
        meta = ObservableMap.of(response.data['meta']);

        if (cards.isEmpty) {
          return false;
        }

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
