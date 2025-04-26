import 'package:flutter/material.dart';
import 'package:tibebnet/screens/auth/login_screen.dart';
import 'package:tibebnet/screens/auth/signup_screen.dart';
import 'package:tibebnet/screens/profile/ProfilePage.dart';
import "package:tibebnet/screens/post/PostPage.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Color(0XFF201A30)),
      home: const Postpage(),
    );
  }
}
