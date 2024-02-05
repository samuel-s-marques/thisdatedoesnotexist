import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/features/auth/store/auth_store.dart';

class CheckAuthPage extends StatefulWidget {
  const CheckAuthPage({super.key});

  @override
  State<CheckAuthPage> createState() => _CheckAuthPageState();
}

class _CheckAuthPageState extends State<CheckAuthPage> {
  final AuthStore store = AuthStore();
  
  @override
  void initState() {
    super.initState();
    store.checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
