import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/core/models/base_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
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
  AppinioSwiperController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller = AppinioSwiperController();
    store.getAvailableSwipes();
    store.setIndex(0);
    store.getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
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
                              onPressed: () async {
                                if (store.hasChanges) {
                                  if (await store.savePreferences()) {
                                    setState(() {});
                                    Navigator.pop(context);
                                  }
                                }
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
                                onSelected: (bool selected) => store.selectPreference(
                                  selected: selected,
                                  list: store.selectedSexPreferences,
                                  preference: sex,
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
                                onSelected: (bool selected) => store.selectPreference(
                                  selected: selected,
                                  list: store.selectedRelationshipGoalPreferences,
                                  preference: goal,
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
                                onSelected: (bool selected) => store.selectPreference(
                                  selected: selected,
                                  list: store.selectedPoliticalViewPreferences,
                                  preference: view,
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
                                onSelected: (bool selected) => store.selectPreference(
                                  selected: selected,
                                  list: store.selectedReligionPreferences,
                                  preference: religion,
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
                                onSelected: (bool selected) => store.selectPreference(
                                  selected: selected,
                                  list: store.selectedBodyTypePreferences,
                                  preference: bodyType,
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
      ),
      body: Observer(
        builder: (_) => 
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
                        child: Observer(
                          builder: (_) => AppinioSwiper(
                            cardCount: store.cards.length,
                            swipeOptions: const SwipeOptions.only(
                              left: true,
                              right: true,
                            ),
                            isDisabled: !store.allowSwiping,
                            allowUnSwipe: false,
                            allowUnlimitedUnSwipe: false,
                            backgroundCardCount: 0,
                            onSwipeEnd: (int index, int direction, SwiperActivity activity) => store.onSwipe(index, direction, activity, context),
                            controller: controller,
                            cardBuilder: (BuildContext context, int index) {
                              final UserModel character = store.cards[index];

                              return CardWidget(
                                homeStore: store,
                                character: character,
                                imageUrl: '${store.server}/uploads/characters/${character.uid}.png',
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Observer(
                            builder: (_) => IconButton(
                              onPressed: !store.allowSwiping ? null : () => controller!.swipeLeft(),
                              color: Colors.white,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              icon: const Icon(Icons.close),
                            ),
                          ),
                          Observer(
                            builder: (_) => IconButton(
                              onPressed: !store.allowSwiping ? null : () => controller!.swipeRight(),
                              color: Colors.white,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              icon: const Icon(Icons.check),
                            ),
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
      ),
    );
  }
}
