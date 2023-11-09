import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/features/home/pages/home_page.dart';
import 'package:thisdatedoesnotexist/app/features/home/store/home_store.dart';

class HomeModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton((i) => HomeStore());
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => HomePage());
  }
}
