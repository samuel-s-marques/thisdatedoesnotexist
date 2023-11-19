import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Observer(
          builder: (_) => AppBar(
            title: Text(store.appbars.keys.elementAt(store.selectedIndex)),
            actions: store.appbars.values.elementAt(store.selectedIndex),
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
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
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
