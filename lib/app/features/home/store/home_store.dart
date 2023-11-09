import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/features/chat/chat_module.dart';
import 'package:thisdatedoesnotexist/app/features/profile/profile_module.dart';

part 'home_store.g.dart';

class HomeStore = HomeStoreBase with _$HomeStore;

abstract class HomeStoreBase with Store {
  List<Widget> pages = [
    ChatModule(),
    ProfileModule(),
  ];

  Map<String, Widget> appbars = {
    'Home': IconButton(
      onPressed: () {},
      icon: Icon(Icons.tune),
    ),
    'Chat': IconButton(
      onPressed: () {},
      icon: Icon(Icons.search),
    ),
    'Profile': IconButton(
      onPressed: () {},
      icon: Icon(Icons.settings),
    ),
  };

  @observable
  int selectedIndex = 0;

  @action
  void setIndex(int index) {
    selectedIndex = index;
  }
}
