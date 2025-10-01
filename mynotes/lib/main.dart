import 'package:flutter/material.dart';
import 'package:mynotes/views/authen_wrapper_view.dart';
import 'package:mynotes/views/login_screen.dart';
import 'package:mynotes/views/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthenWrapper(),
      routes: {
        '/login/': (context) => const LoginScreen(),
        '/register/': (context) => const RegisterScreen(),
      },
    );
  }
}
