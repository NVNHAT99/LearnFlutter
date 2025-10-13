import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/views/email_verify_view.dart';
import 'package:mynotes/views/login_screen.dart';
import 'package:mynotes/views/notes/notes_view.dart';

class AuthenWrapper extends StatelessWidget {
  const AuthenWrapper({super.key});

  Future<User?> _getCurrentUser() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload(); // ép sync từ server
      return FirebaseAuth.instance.currentUser; // lấy lại user mới
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getCurrentUser(),
      builder: (futureConext, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;

            if (user != null) {
              if (user.emailVerified) {
                return const NotesView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return LoginScreen();
            }
          default:
            return const Text('Loading...');
        }
      },
    );
  }
}
