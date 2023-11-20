import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:mobx/mobx.dart';

part 'onboarding_store.g.dart';

class OnboardingStore = OnboardingStoreBase with _$OnboardingStore;

abstract class OnboardingStoreBase with Store {
  @observable
  ObservableList<PageViewModel> pages = ObservableList.of([
    PageViewModel(
      title: 'Page one',
      bodyWidget: Column(
        children: [
          Text("Page one"),
        ],
      ),
    ),
    PageViewModel(
      title: 'Page two',
      bodyWidget: Column(
        children: [
          Text("Page two"),
        ],
      ),
    ),
  ]);
}
