import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:mobx/mobx.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';
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

  CardSwiperController cardSwiperController = CardSwiperController();

  @observable
  String selectedRelationshipGoalPreference = '';

  @observable
  String selectedPoliticalViewPreference = '';

  @observable
  RangeValues ageValues = const RangeValues(18, 50);

  @observable
  ObservableList<String> relationshipGoals = ObservableList();

  @observable
  ObservableList<String> politicalViews = ObservableList();

  @action
  Future<void> setAgeValues(RangeValues values) async {
    ageValues = values;
    await prefs!.setDouble('minAge', ageValues.start);
    await prefs!.setDouble('maxAge', ageValues.end);
  }

  @action
  Future<void> selectPoliticalViewPreference(String view) async {
    selectedPoliticalViewPreference = view;
    await prefs!.setString('politicalView', selectedPoliticalViewPreference);
  }

  @action
  Future<void> selectRelationshipGoalPreference(String goal) async {
    selectedRelationshipGoalPreference = goal;
    await prefs!.setString('relationshipGoal', selectedRelationshipGoalPreference);
  }

  Future<void> getRelationshipGoals() async {
    final Response response = await dio.get('$server/api/relationship-goals');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final String goal = data[index]['name'];
        relationshipGoals.add(goal);
      }
      relationshipGoals.add('All');
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
      politicalViews.add('All');
    }
  }

  Future<void> getPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    ageValues = RangeValues(
      prefs.getDouble('minAge') ?? 18,
      prefs.getDouble('maxAge') ?? 50,
    );
    selectedPoliticalViewPreference = prefs.getString('politicalView') ?? 'All';
    selectedRelationshipGoalPreference = prefs.getString('relationshipGoal') ?? 'All';
  }

  @action
  Future<bool> onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) async {
    try {
      if (swipes == 0) {
        return false;
      }

      await db.collection('swipes').add({
        'targetId': cards[previousIndex].uuid,
        'userId': authService.getUser().uid,
        'direction': direction.name,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      swipes--;

      await db.collection('users').doc(authService.getUser().uid).set({
        'swipes': swipes,
        'lastSwipe': Timestamp.fromDate(DateTime.now()),
      }, SetOptions(merge: true));

      return true;
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  @action
  Future<List<CharacterModel>> getTodayCards() async {
    String url = '$server/api/characters?min_age=${ageValues.start.round()}&max_age=${ageValues.end.round()}';

    if (selectedPoliticalViewPreference != 'All') {
      url += '&political_view=$selectedPoliticalViewPreference';
    }

    if (selectedRelationshipGoalPreference != 'All') {
      url += '&relationship_goal=$selectedRelationshipGoalPreference';
    }

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
