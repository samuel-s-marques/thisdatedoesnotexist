import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/core/widgets/widget_module.dart';
import 'package:thisdatedoesnotexist/app/features/chat/pages/chat_list_page.dart';
import 'package:thisdatedoesnotexist/app/features/chat/pages/chat_page.dart';
import 'package:thisdatedoesnotexist/app/features/chat/store/chat_store.dart';

class ChatModule extends WidgetModule {
  const ChatModule({super.key});

  @override
  void binds(Injector i) {
    i.addLazySingleton((i) => ChatStore());
  }

  @override
  Widget get view => const ChatListPage();

  @override
  void routes(r) {
    r.child('/', child: (context) => const ChatPage());
  }
}
