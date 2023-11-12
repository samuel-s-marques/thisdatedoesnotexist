import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/core/widgets/widget_module.dart';
import 'package:thisdatedoesnotexist/app/features/profile/pages/profile_page.dart';
import 'package:thisdatedoesnotexist/app/features/profile/store/profile_store.dart';

class ProfileModule extends WidgetModule {
  const ProfileModule({super.key});

  @override
  void binds(Injector i) {
    i.addLazySingleton((i) => ProfileStore());
  }

  @override
  Widget get view => const ProfilePage();
}
