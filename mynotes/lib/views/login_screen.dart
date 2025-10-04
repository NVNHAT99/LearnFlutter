import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/commonViews/error_dialog_view.dart';
import 'dart:developer' as devtools show log;

import 'package:mynotes/constants/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), backgroundColor: Colors.blue),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email here.',
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Enter your password here.',
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              final nav = Navigator.of(context); // giữ reference trước
              try {
                final userCredential = await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                final user = FirebaseAuth.instance.currentUser;
                devtools.log(userCredential.toString());
                if (user?.emailVerified ?? false) {
                  nav.pushNamedAndRemoveUntil(notesRoute, (route) => false);
                } else {
                  nav.pushNamedAndRemoveUntil(
                    verifyEmailRoute,
                    (route) => false,
                  );
                }
              } on FirebaseException catch (error) {
                if (context.mounted) {
                  if (error.code == 'user-not-found') {
                    devtools.log('User not found');
                    await showErrorDialog(context, 'User not found.');
                  } else if (error.code == 'wrong-password') {
                    devtools.log('Wrong Password');
                    await showErrorDialog(context, 'Wrong Password');
                  } else {
                    devtools.log(error.toString());
                    await showErrorDialog(context, 'Error: ${error.code}');
                  }
                }
              } catch (error) {
                devtools.log(error.toString());
                if (context.mounted) {
                  await showErrorDialog(context, e.toString());
                }
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(registerRoute, (route) => false);
            },
            child: const Text('Not registered yet? Register here.'),
          ),
        ],
      ),
    );
  }
}
