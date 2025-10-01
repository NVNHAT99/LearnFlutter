import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/views/login_screen.dart';

class AuthenWrapper extends StatelessWidget {
  const AuthenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (futureConext, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            // final user = FirebaseAuth.instance.currentUser;
            // if (user?.emailVerified ?? false) {
            //   print('you are a verified user.');
            // } else {
            //   return const VerifyEmailScreen();
            // }
            return LoginScreen();
          default:
            return const Text('Loading...');
        }
      },
    );
  }
}
