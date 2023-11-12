import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/features/chat/chat_module.dart';
import 'package:thisdatedoesnotexist/app/features/profile/profile_module.dart';

part 'home_store.g.dart';

class HomeStore = HomeStoreBase with _$HomeStore;

abstract class HomeStoreBase with Store {
  List<Widget> pages = [
    const ChatModule(),
    const ProfileModule(),
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

  @observable
  int selectedIndex = 0;

  @action
  void setIndex(int index) {
    selectedIndex = index;
  }
}
