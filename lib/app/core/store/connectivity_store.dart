import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mobx/mobx.dart';

part 'connectivity_store.g.dart';

class ConnectivityStore = ConnectivityStoreBase with _$ConnectivityStore;

abstract class ConnectivityStoreBase with Store {
  @observable
  ObservableStream<ConnectivityResult> connectivityStream = ObservableStream(Connectivity().onConnectivityChanged);
}
