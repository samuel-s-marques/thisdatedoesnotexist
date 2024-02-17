import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:thisdatedoesnotexist/app/core/env/env.dart';
import 'package:thisdatedoesnotexist/app/core/models/base_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/preferences_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/service_return_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/data_service.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/home/services/home_service.dart';

part 'home_store.g.dart';

class HomeStore = HomeStoreBase with _$HomeStore;

abstract class HomeStoreBase with Store {
  HomeService service = Modular.get();
  DataService dataService = Modular.get();
  final String server = Env.server;

  @observable
  int? swipes;

  @computed
  bool get allowSwiping => swipes != null && swipes! > 0;

  @observable
  ObservableList<UserModel> cards = ObservableList();

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
  Future<void> selectPreference({
    required bool selected,
    required BaseModel preference,
    required List<BaseModel> list,
  }) async {
    if (selected) {
      list.add(preference);
    } else {
      list.remove(preference);
    }
  }

  @action
  void setAgeValues(RangeValues values) {
    ageValues = values;
  }

  @action
  Future<void> getAvailableSwipes() async {
    final ServiceReturn response = await service.getAvailableSwipes();

    if (response.success) {
      setSwipes(response.data['available_swipes'] ?? 0);
    }
  }

  Future<bool> getPreferences() async {
    final ServiceReturn response = await service.getPreferences();

    if (response.success) {
      final Preferences preferences = response.data;

      selectedBodyTypePreferences = ObservableList.of(preferences.bodyTypes);
      selectedPoliticalViewPreferences = ObservableList.of(preferences.politicalViews);
      selectedRelationshipGoalPreferences = ObservableList.of(preferences.relationshipGoals);
      selectedReligionPreferences = ObservableList.of(preferences.religions);
      selectedSexPreferences = ObservableList.of(preferences.sexes);
      ageValues = RangeValues(preferences.minAge, preferences.maxAge);

      updateLastSelectedLists();
    }

    return response.success;
  }

  Future<void> getData() async {
    final Future<ServiceReturn> bodyTypesFuture = dataService.getBodyTypes();
    final Future<ServiceReturn> politicalViewsFuture = dataService.getPoliticalViews();
    final Future<ServiceReturn> relationshipGoalsFuture = dataService.getRelationshipGoals();
    final Future<ServiceReturn> religionsFuture = dataService.getReligions();
    final Future<ServiceReturn> sexesFuture = dataService.getSexes();

    final (
      bodyTypesData,
      politicalViewsData,
      relationshipGoalsData,
      religionsData,
      sexesData,
    ) = await (
      bodyTypesFuture,
      politicalViewsFuture,
      relationshipGoalsFuture,
      religionsFuture,
      sexesFuture,
    ).wait;

    if (bodyTypesData.success) {
      final List<dynamic> data = bodyTypesData.data;
      bodyTypes.addAll(data.map((e) => BaseModel.fromMap(e)).toList());
    }

    if (politicalViewsData.success) {
      final List<dynamic> data = politicalViewsData.data;
      politicalViews.addAll(data.map((e) => BaseModel.fromMap(e)).toList());
    }

    if (relationshipGoalsData.success) {
      final List<dynamic> data = relationshipGoalsData.data;
      relationshipGoals.addAll(data.map((e) => BaseModel.fromMap(e)).toList());
    }

    if (religionsData.success) {
      final List<dynamic> data = religionsData.data;
      religions.addAll(data.map((e) => BaseModel.fromMap(e)).toList());
    }

    if (sexesData.success) {
      final List<dynamic> data = sexesData.data;
      sexes.addAll(data.map((e) => BaseModel.fromMap(e)).toList());
    }
  }

  @action
  Future<void> onSwipe(
    int previousIndex,
    int? currentIndex,
    SwiperActivity activity,
    BuildContext context,
  ) async {
    if (swipes == null) {
      return;
    }

    switch (activity) {
      case Swipe():
        if (swipes! > 0) {
          if (activity.direction == AxisDirection.right || activity.direction == AxisDirection.left) {
            try {
              final String direction = activity.direction == AxisDirection.right ? 'right' : 'left';

              final ServiceReturn response = await service.saveSwipe(
                targetId: cards[previousIndex].uid,
                direction: direction,
              );

              if (response.success) {
                setSwipes(swipes! - 1);
              } else {
                context.showSnackBarError(message: 'Failed to save swipe!');
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

    final ServiceReturn response = await service.savePreferences(preferences);

    if (response.success) {
      updateLastSelectedLists();
    }

    return response.success;
  }

  @action
  Future<bool?> getTodayCards() async {
    if (selectedIndex != 0) {
      return null;
    }

    if (!gotPreferences) {
      gotPreferences = await getPreferences();
    }

    if (gotPreferences) {
      final ServiceReturn response = await service.getTodayCards(
        Preferences(
          sexes: selectedSexPreferences,
          relationshipGoals: selectedRelationshipGoalPreferences,
          politicalViews: selectedPoliticalViewPreferences,
          bodyTypes: selectedBodyTypePreferences,
          religions: selectedReligionPreferences,
          minAge: ageValues.start,
          maxAge: ageValues.end,
        ),
      );

      if (response.success) {
        cards = ObservableList.of(
          (response.data as List<dynamic>)
              .map(
                (e) => UserModel.fromMap(
                  e['profile'],
                ),
              )
              .toList(),
        );

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

    if (index == 0) {
      getAvailableSwipes();
    }
  }

  @action
  void setSwipes(int swipes) => this.swipes = swipes;
}
