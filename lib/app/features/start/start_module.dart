import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/features/chat/pages/chat_list_page.dart';
import 'package:thisdatedoesnotexist/app/features/home/pages/home_page.dart';
import 'package:thisdatedoesnotexist/app/features/profile/pages/profile_page.dart';
import 'package:thisdatedoesnotexist/app/features/start/pages/start_page.dart';
import 'package:thisdatedoesnotexist/app/features/start/store/start_store.dart';

class StartModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton((i) => StartStore());
  }

  @override
  void routes(r) {
    r.child(
      '/',
      child: (context) => const StartPage(),
      children: [
        ChildRoute('/home', child: (context) => const HomePage()),
        ChildRoute('/chat', child: (context) => const ChatListPage()),
        ChildRoute('/profile', child: (context) => const ProfilePage()),
      ],
    );
  }
}
