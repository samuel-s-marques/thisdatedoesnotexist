import 'package:cloud_firestore/cloud_firestore.dart';
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

  List<Widget> pages = [
    const ChatModule(),
    const ProfileModule(),
  ];

  List<CharacterModel> cards = [
    CharacterModel(
      uuid: 'uuid-1',
      name: 'John',
      surname: 'Doe',
      age: 18,
    ),
    CharacterModel(
      uuid: 'uuid-2',
      name: 'Name',
      surname: 'Surname',
      age: 18,
    ),
    CharacterModel(
      uuid: 'uuid-3',
      name: 'Example 1',
      surname: 'Example 2',
      age: 78,
    ),
  ];

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

  Future<bool> onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) async {
    try {
      await db.collection('swipes').add({
        'targetId': cards[previousIndex].uuid,
        'userId': authService.getUser().uid,
        'direction': direction.name,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  @observable
  int selectedIndex = 0;

  @action
  void setIndex(int index) {
    selectedIndex = index;
  }
}
