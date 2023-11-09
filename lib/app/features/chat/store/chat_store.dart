import 'package:mobx/mobx.dart';

part 'chat_store.g.dart';

class ChatStore = ChatStoreBase with _$ChatStore;

abstract class ChatStoreBase with Store {}