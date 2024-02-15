import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/chat/pages/chat_list_page.dart';
import 'package:thisdatedoesnotexist/app/features/home/pages/home_page.dart';
import 'package:thisdatedoesnotexist/app/features/profile/pages/profile_page.dart';
import 'package:thisdatedoesnotexist/app/features/start/store/start_store.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  StartStore store = Modular.get<StartStore>();

  @override
  Widget build(BuildContext context) {
    return ReactionBuilder(
      builder: (context) {
        return reaction((_) => store.connectivity.connectivityStream.value, (result) {
          if (result == ConnectivityResult.none) {
            context.showSnackBarError(message: "You don't have internet connection. Please, check your connection and try again.");
          }
        }, delay: 3000);
      },
      child: Scaffold(
        body: Observer(
          builder: (_) => IndexedStack(
            index: store.currentPageIndex,
            children: const [
              HomePage(),
              ChatListPage(),
              ProfilePage(),
            ],
          ),
        ),
        bottomNavigationBar: Observer(
          builder: (_) => BottomNavigationBar(
            currentIndex: store.currentPageIndex,
            onTap: (int index) {
              store.currentPageIndex = index;
            },
            items: [
              BottomNavigationBarItem(
                icon: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    const Icon(Icons.home),
                    if (store.notification.hasNotifications)
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
          ),
        ),
      ),
    );
  }
}
