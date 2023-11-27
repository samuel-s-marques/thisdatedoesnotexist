import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';
import 'package:thisdatedoesnotexist/app/core/services/database_service.dart';
import 'package:thisdatedoesnotexist/app/features/chat/chat_module.dart';
import 'package:thisdatedoesnotexist/app/features/home/models/character_model.dart';
import 'package:thisdatedoesnotexist/app/features/profile/profile_module.dart';

part 'home_store.g.dart';

class HomeStore = HomeStoreBase with _$HomeStore;

abstract class HomeStoreBase with Store {
  FirebaseFirestore db = FirebaseFirestore.instance;
  AuthService authService = AuthService();
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
  List<CharacterModel> cards = [];

  List<String> appbars = ['Home', 'Chat', 'Profile'];

  AppinioSwiperController cardSwiperController = AppinioSwiperController();

  @observable
  RangeValues ageValues = const RangeValues(18, 50);

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

  @action
  Future<void> selectPoliticalViewPreference({
    required bool selected,
    required String view,
  }) async {
    if (selected) {
      selectedPoliticalViewPreferences.add(view);
    } else {
      selectedPoliticalViewPreferences.remove(view);
    }

    await prefs!.setStringList('politicalViews', selectedPoliticalViewPreferences);
  }

  @action
  Future<void> selectSexPreference({
    required bool selected,
    required String sex,
  }) async {
    if (selected) {
      selectedSexPreferences.add(sex);
    } else {
      selectedSexPreferences.remove(sex);
    }

    await prefs!.setStringList('sexesPreferences', selectedSexPreferences);
  }

  @action
  Future<void> selectBodyTypePreference({
    required bool selected,
    required String bodyType,
  }) async {
    if (selected) {
      selectedBodyTypePreferences.add(bodyType);
    } else {
      selectedBodyTypePreferences.remove(bodyType);
    }

    await prefs!.setStringList('bodyTypes', selectedBodyTypePreferences);
  }

  @action
  Future<void> selectRelationshipGoalPreference({
    required bool selected,
    required String goal,
  }) async {
    if (selected) {
      selectedRelationshipGoalPreferences.add(goal);
    } else {
      selectedRelationshipGoalPreferences.remove(goal);
    }

    await prefs!.setStringList('relationshipGoals', selectedRelationshipGoalPreferences);
  }

  @action
  void setAgeValues(RangeValues values) {
    ageValues = values;
  }

  Future<void> getPreferences() async {
    final DatabaseService databaseService = DatabaseService();
    final UserModel user = await databaseService.getUser();

    if (user.preferences != null) {
      selectedSexPreferences = ObservableList.of(user.preferences?.sexes ?? []);
      selectedPoliticalViewPreferences = ObservableList.of(user.preferences?.politicalViews ?? []);
      selectedBodyTypePreferences = ObservableList.of(user.preferences?.bodyTypes ?? []);
      selectedRelationshipGoalPreferences = ObservableList.of(user.preferences?.relationshipGoals ?? []);
      ageValues = RangeValues(user.preferences?.minAge ?? 18, user.preferences?.maxAge ?? 50);
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
    if (activity.direction == AxisDirection.right || activity.direction == AxisDirection.left) {
      try {
        await db.collection('swipes').add({
          'targetId': cards[previousIndex].uuid,
          'userId': authService.getUser().uid,
          'direction': activity.direction == AxisDirection.right ? 'right' : 'left',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });

        swipes--;

        await db.collection('users').doc(authService.getUser().uid).set({
          'swipes': swipes,
          'lastSwipe': Timestamp.fromDate(DateTime.now()),
        }, SetOptions(merge: true));
      } catch (exception, stackTrace) {
        await Sentry.captureException(
          exception,
          stackTrace: stackTrace,
        );
      }
    }
  }

  @action
  Future<List<CharacterModel>> getTodayCards() async {
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

    print(url);

    final Response<dynamic> response = await Dio().get(url);

    if (response.statusCode == 200) {
      return (response.data['data'] as List<dynamic>).map((e) => CharacterModel.fromMap(e)).toList();
    } else {
      return [];
    }
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
