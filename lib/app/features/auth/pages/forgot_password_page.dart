import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:thisdatedoesnotexist/app/features/auth/store/auth_store.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  AuthStore store = AuthStore();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    store.emailController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    store.emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        child: Form(
          key: formKey,
          child: Observer(
            builder: (_) => Wrap(
              runSpacing: 15,
              children: [
                TextFormField(
                  controller: store.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'E-mail is required.';
                    }

                    final RegExp emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailPattern.hasMatch(value)) {
                      return 'A valid email address is required';
                    }

                    return null;
                  },
                ),
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: Observer(
                    builder: (_) => ElevatedButton(
                      onPressed: () {
                        if (!store.isLoading && formKey.currentState!.validate()) {
                          store.forgotPassword(context);
                        }
                      },
                      child: store.isLoading ? const CircularProgressIndicator() : const Text('Send reset password e-mail'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
