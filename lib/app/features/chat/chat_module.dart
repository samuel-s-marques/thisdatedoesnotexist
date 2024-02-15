import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/core/services/report_service.dart';
import 'package:thisdatedoesnotexist/app/core/services/websocket_service.dart';
import 'package:thisdatedoesnotexist/app/features/chat/pages/chat_page.dart';
import 'package:thisdatedoesnotexist/app/features/chat/services/chat_service.dart';
import 'package:thisdatedoesnotexist/app/features/chat/store/chat_store.dart';

class ChatModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton<ChatService>(ChatServiceImpl.new);
    i.addSingleton<ReportService>(ReportServiceImpl.new);
    i.addSingleton<WebsocketService>(WebsocketServiceImpl.new);
    i.addLazySingleton((i) => ChatStore());
  }

  @override
  void routes(r) {
    r.child(
      '/:id',
      child: (context) => ChatPage(
        id: r.args.params['id'],
      ),
    );
  }
}
