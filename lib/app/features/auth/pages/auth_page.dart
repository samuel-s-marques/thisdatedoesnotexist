import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thisdatedoesnotexist/app/features/auth/store/auth_store.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  AuthStore store = AuthStore();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
                TextFormField(
                  controller: store.passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required.';
                    }

                    return null;
                  },
                ),
                if (store.isSignUp)
                  TextFormField(
                    controller: store.repeatPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Confirm password'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirm Password is required.';
                      }

                      if (value != store.passwordController.text) {
                        return 'Passwords do not match.';
                      }

                      return null;
                    },
                  ),
                Observer(
                  builder: (_) => ElevatedButton(
                    onPressed: () {
                      if (!store.isLoading) {
                        if (store.isSignUp) {
                          store.signUp(context);
                        } else {
                          store.signIn(context);
                        }
                      }
                    },
                    child: store.isLoading
                        ? const CircularProgressIndicator()
                        : store.isSignUp
                            ? const Text('Sign up')
                            : const Text('Sign In'),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Expanded(
                      child: Divider(
                        endIndent: 20,
                      ),
                    ),
                    Text('Or'),
                    Expanded(
                      child: Divider(
                        indent: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () => store.signInWithGoogle(context),
                    icon: SvgPicture.asset('assets/icons/google.svg'),
                    label: const Text(
                      'Sign up with Google',
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15),
        child: Observer(
          builder: (_) => Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(store.isSignUp ? 'Already have an account?' : 'Don\'t have an account?'),
              TextButton(
                onPressed: () => store.toggleIsSignUp(),
                child: Text(store.isSignUp ? 'Sign in' : 'Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
