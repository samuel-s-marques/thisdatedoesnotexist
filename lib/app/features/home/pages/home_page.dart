import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/core/models/base_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/store/connectivity_store.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/home/store/home_store.dart';
import 'package:thisdatedoesnotexist/app/features/home/widgets/card_widget.dart';
import 'package:thisdatedoesnotexist/app/features/notification/store/notification_store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeStore store = HomeStore();
  NotificationStore notificationStore = Modular.get<NotificationStore>();
  ConnectivityStore connectivityStore = Modular.get<ConnectivityStore>();

  @override
  void dispose() {
    store.cardSwiperController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    UserModel(uid: store.authService.getUser().uid).getSwipes().then((swipes) => store.setSwipes(swipes));

    store.setIndex(0);
    store.getReligions();
    store.getPoliticalViews();
    store.getRelationshipGoals();
    store.getBodyTypes();
    store.getSexes();
  }

  @override
  Widget build(BuildContext context) {
    return ReactionBuilder(
      builder: (context) {
        return reaction((_) => connectivityStore.connectivityStream.value, (result) {
          if (result == ConnectivityResult.none) {
            context.showSnackBarError(message: "You don't have internet connection.");
          } else {
            context.showSnackBarSuccess(message: 'You have internet connection.');
          }
        }, delay: 3000);
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Observer(
            builder: (_) => AppBar(
              title: Text(store.appbars.elementAt(store.selectedIndex)),
              actions: [
                Builder(builder: (BuildContext context) {
                  final String appbarName = store.appbars.elementAt(store.selectedIndex);

                  if (appbarName == 'Home') {
                    return Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              showDragHandle: true,
                              useSafeArea: true,
                              enableDrag: true,
                              builder: (BuildContext context) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                                  child: ListView(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Filter',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              store.savePreferences().then((_) {
                                                setState(() {});
                                                Navigator.pop(context);
                                              });
                                            },
                                            style: TextButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(25),
                                                side: BorderSide(
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                              ),
                                            ),
                                            child: const Text('Apply'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'Who would you like to meet?',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Observer(
                                        builder: (_) => Wrap(
                                          spacing: 5,
                                          children: store.sexes.map((BaseModel sex) {
                                            final bool isSelected = store.selectedSexPreferences.contains(sex);

                                            return FilterChip(
                                              label: Text(store.sexesMap[sex.name]!.capitalize()),
                                              selected: isSelected,
                                              onSelected: (bool selected) => store.selectSexPreference(
                                                selected: selected,
                                                sex: sex,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      const Divider(),
                                      const SizedBox(height: 15),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Age range'),
                                          Observer(
                                            builder: (_) => Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: store.ageValues.start.round().toString(),
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const TextSpan(
                                                    text: ' - ',
                                                  ),
                                                  TextSpan(
                                                    text: store.ageValues.end.round().toString(),
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Observer(
                                        builder: (_) => RangeSlider(
                                          min: 18,
                                          max: 70,
                                          values: store.ageValues,
                                          onChanged: store.setAgeValues,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      const Divider(),
                                      const SizedBox(height: 15),
                                      const Text('Relationship goals'),
                                      const SizedBox(height: 10),
                                      Observer(
                                        builder: (_) => Wrap(
                                          spacing: 5,
                                          children: store.relationshipGoals.map((BaseModel goal) {
                                            final bool isSelected = store.selectedRelationshipGoalPreferences.contains(goal);

                                            return FilterChip(
                                              label: Text(goal.name!.capitalize()),
                                              selected: isSelected,
                                              onSelected: (bool selected) => store.selectRelationshipGoalPreference(
                                                selected: selected,
                                                goal: goal,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      const Divider(),
                                      const SizedBox(height: 15),
                                      const Text('Political Views'),
                                      const SizedBox(height: 10),
                                      Observer(
                                        builder: (_) => Wrap(
                                          spacing: 5,
                                          children: store.politicalViews.map((BaseModel view) {
                                            final bool isSelected = store.selectedPoliticalViewPreferences.contains(view);

                                            return FilterChip(
                                              label: Text(view.name!.capitalize()),
                                              selected: isSelected,
                                              onSelected: (bool selected) => store.selectPoliticalViewPreference(
                                                selected: selected,
                                                view: view,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      const Divider(),
                                      const SizedBox(height: 15),
                                      const Text('Religions'),
                                      const SizedBox(height: 10),
                                      Observer(
                                        builder: (_) => Wrap(
                                          spacing: 5,
                                          children: store.religions.map((BaseModel religion) {
                                            final bool isSelected = store.selectedReligionPreferences.contains(religion);

                                            return FilterChip(
                                              label: Text(religion.name!.capitalize()),
                                              selected: isSelected,
                                              onSelected: (bool selected) => store.selectReligionPreference(
                                                selected: selected,
                                                religion: religion,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      const Divider(),
                                      const SizedBox(height: 15),
                                      const Text('Body Types'),
                                      const SizedBox(height: 10),
                                      Observer(
                                        builder: (_) => Wrap(
                                          spacing: 5,
                                          children: store.bodyTypes.map((BaseModel bodyType) {
                                            final bool isSelected = store.selectedBodyTypePreferences.contains(bodyType);

                                            return FilterChip(
                                              label: Text(bodyType.name!.capitalize()),
                                              selected: isSelected,
                                              onSelected: (bool selected) => store.selectBodyTypePreference(
                                                selected: selected,
                                                bodyType: bodyType,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.tune),
                        ),
                        const SizedBox(width: 10),
                        Observer(
                          builder: (_) => IconButton(
                            onPressed: () => Modular.to.pushNamed('/notifications/'),
                            icon: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                const Icon(
                                  Icons.notifications_outlined,
                                ),
                                if (notificationStore.hasNotifications)
                                  Container(
                                    height: 6,
                                    width: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (appbarName == 'Chat') {
                    return IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search),
                    );
                  } else if (appbarName == 'Profile') {
                    return Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pushNamed(context, '/settings/'),
                          icon: const Icon(Icons.settings),
                        ),
                      ],
                    );
                  } else {
                    return const SizedBox();
                  }
                })
              ],
            ),
          ),
        ),
        body: Observer(
          builder: (_) => [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              child: FutureBuilder(
                future: store.getTodayCards(),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data == false) {
                      return const Center(
                        child: Text('No more cards for today!'),
                      );
                    }

                    return Column(
                      children: [
                        Flexible(
                          child: AppinioSwiper(
                            cardCount: store.cards.length,
                            swipeOptions: const SwipeOptions.only(
                              left: true,
                              right: true,
                            ),
                            allowUnSwipe: false,
                            allowUnlimitedUnSwipe: false,
                            backgroundCardCount: 0,
                            onSwipeEnd: store.onSwipe,
                            controller: store.cardSwiperController,
                            cardBuilder: (BuildContext context, int index) {
                              final UserModel character = store.cards[index];

                              return CardWidget(
                                homeStore: store,
                                dio: store.dio,
                                character: character,
                                imageUrl: '${store.server}/uploads/characters/${character.uid}.png',
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: () => store.cardSwiperController.swipeLeft(),
                              color: Colors.white,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              icon: const Icon(Icons.close),
                            ),
                            IconButton(
                              onPressed: () => store.cardSwiperController.swipeRight(),
                              color: Colors.white,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              icon: const Icon(Icons.check),
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            ...store.pages
          ].elementAt(store.selectedIndex),
        ),
        bottomNavigationBar: Observer(
          builder: (_) => BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    const Icon(Icons.home),
                    if (notificationStore.hasNotifications && store.selectedIndex != 0)
                      Container(
                        height: 6,
                        width: 6,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble),
                label: 'Chat',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: store.selectedIndex,
            onTap: store.setIndex,
          ),
        ),
      ),
    );
  }
}
