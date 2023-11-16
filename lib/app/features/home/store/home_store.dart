import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/features/chat/chat_module.dart';
import 'package:thisdatedoesnotexist/app/features/home/models/character_model.dart';
import 'package:thisdatedoesnotexist/app/features/profile/profile_module.dart';

part 'home_store.g.dart';

class HomeStore = HomeStoreBase with _$HomeStore;

abstract class HomeStoreBase with Store {
  List<Widget> pages = [
    const ChatModule(),
    const ProfileModule(),
  ];

  List<CharacterModel> cards = [
    CharacterModel(name: "John", surname: "Doe", age: 18,),
    CharacterModel(name: "Name", surname: "Surname", age: 18,),
    CharacterModel(name: "Example 1", surname: "Example 2", age: 78,),
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

  bool onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    debugPrint(
      'The card $previousIndex was swiped to the ${direction.name}. Now the card $currentIndex is on top',
    );
    return true;
  }

  @observable
  int selectedIndex = 0;

  @action
  void setIndex(int index) {
    selectedIndex = index;
  }
}
