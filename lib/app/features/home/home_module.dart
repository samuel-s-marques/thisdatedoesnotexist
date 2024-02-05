import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/core/services/data_service.dart';
import 'package:thisdatedoesnotexist/app/features/home/pages/home_page.dart';
import 'package:thisdatedoesnotexist/app/features/home/services/home_service.dart';
import 'package:thisdatedoesnotexist/app/features/home/store/home_store.dart';

class HomeModule extends Module {
  @override
  void binds(i) {
    i.addSingleton<HomeService>(HomeServiceImpl.new);
    i.addSingleton<DataService>(DataServiceImpl.new);
    i.addLazySingleton((i) => HomeStore());
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const HomePage());
  }
}
