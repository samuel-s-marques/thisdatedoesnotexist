import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';
import 'package:thisdatedoesnotexist/app/features/chat/chat_module.dart';
import 'package:thisdatedoesnotexist/app/features/home/models/character_model.dart';
import 'package:thisdatedoesnotexist/app/features/profile/profile_module.dart';

part 'home_store.g.dart';

class HomeStore = HomeStoreBase with _$HomeStore;

abstract class HomeStoreBase with Store {
  FirebaseFirestore db = FirebaseFirestore.instance;
  AuthService authService = AuthService();
  String server = const String.fromEnvironment('SERVER');

  @observable
  int swipes = 20;

  List<Widget> pages = [
    const ChatModule(),
    const ProfileModule(),
  ];

  @observable
  List<CharacterModel> cards = [];

  Map<String, List<Widget>> appbars = {
    'Home': [
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.tune),
      )
    ],
    'Chat': [
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.search),
      )
    ],
    'Profile': [
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.edit),
      ),
      IconButton(
        onPressed: () => Modular.to.pushNamed('/settings/'),
        icon: const Icon(Icons.settings),
      ),
    ]
  };

  CardSwiperController cardSwiperController = CardSwiperController();

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
    final Response<dynamic> response = await Dio().get(
      '$server/api/character?sex=female&minAge=18&maxAge=21&user=${authService.getUser().uid}',
    );

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
