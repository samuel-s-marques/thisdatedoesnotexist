import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/home/store/home_store.dart';
import 'package:thisdatedoesnotexist/app/features/home/widgets/card_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeStore store = HomeStore();

  @override
  void dispose() {
    store.cardSwiperController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    UserModel(uid: store.authService.getUser().uid).getSwipes().then((swipes) => store.setSwipes(swipes));
    store.setIndex(0);
    SharedPreferences.getInstance().then((value) => store.prefs = value);
    store.getPoliticalViews();
    store.getRelationshipGoals();
    store.getPreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Observer(
          builder: (_) => AppBar(
            title: Text(store.appbars.elementAt(store.selectedIndex)),
            actions: [
              Builder(builder: (BuildContext context) {
                final String appbarName = store.appbars.elementAt(store.selectedIndex);

                if (appbarName == 'Home') {
                  return IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        showDragHandle: true,
                        useSafeArea: true,
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Filter',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
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
                                    max: 50,
                                    values: store.ageValues,
                                    onChanged: store.setAgeValues,
                                  ),
                                ),
                                const Divider(),
                                const SizedBox(height: 10),
                                const Text('Relationship Goals'),
                                const SizedBox(height: 10),
                                Observer(
                                  builder: (_) => Wrap(
                                    spacing: 5,
                                    children: store.relationshipGoals.map((String goal) {
                                      final bool isSelected = store.selectedRelationshipGoalPreference == goal;

                                      return ChoiceChip(
                                        label: Text(goal.capitalize()),
                                        selected: isSelected,
                                        onSelected: (_) => store.selectRelationshipGoalPreference(goal),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const Divider(),
                                const SizedBox(height: 10),
                                const Text('Political Views'),
                                const SizedBox(height: 10),
                                Observer(
                                  builder: (_) => Wrap(
                                    spacing: 5,
                                    children: store.politicalViews.map((String view) {
                                      final bool isSelected = store.selectedPoliticalViewPreference == view;

                                      return ChoiceChip(
                                        label: Text(view.capitalize()),
                                        selected: isSelected,
                                        onSelected: (_) => store.selectPoliticalViewPreference(view),
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
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  store.cards = snapshot.data;

                  return Column(
                    children: [
                      Flexible(
                        child: CardSwiper(
                          padding: EdgeInsets.zero,
                          cardsCount: store.cards.length,
                          controller: store.cardSwiperController,
                          allowedSwipeDirection: AllowedSwipeDirection.only(left: true, right: true),
                          isLoop: false,
                          onSwipe: store.onSwipe,
                          cardBuilder: (
                            BuildContext context,
                            int index,
                            int percentThresholdX,
                            int percentThresholdY,
                          ) {
                            return CardWidget(character: store.cards[index]);
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: store.selectedIndex,
          onTap: store.setIndex,
        ),
      ),
    );
  }
}
