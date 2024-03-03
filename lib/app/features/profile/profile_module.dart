import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/features/profile/pages/edit_profile_page.dart';
import 'package:thisdatedoesnotexist/app/features/profile/store/profile_store.dart';

class ProfileModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton((i) => ProfileStore());
  }

  @override
  void routes(r) {
    r.child('/edit', child: (context) => EditProfilePage());
  }
}
