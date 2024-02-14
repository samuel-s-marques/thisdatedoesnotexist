import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/core/store/connectivity_store.dart';
import 'package:thisdatedoesnotexist/app/features/notification/store/notification_store.dart';

part 'start_store.g.dart';

class StartStore = StartStoreBase with _$StartStore;

abstract class StartStoreBase with Store implements Disposable{
  final ConnectivityStore connectivity = Modular.get<ConnectivityStore>();
  final NotificationStore notification = Modular.get<NotificationStore>();

  @observable
  int currentPageIndex = 0;
}
