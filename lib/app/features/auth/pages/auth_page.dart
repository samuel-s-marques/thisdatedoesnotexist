import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/features/auth/store/auth_store.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  AuthStore store = AuthStore();

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}