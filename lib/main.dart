import 'package:flutter/material.dart';
import 'package:mobile/screens/login_screen.dart';

void main() {
  runApp(const SmartHomeGuardian());
}

class SmartHomeGuardian extends StatelessWidget {
  const SmartHomeGuardian({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home Guardian',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}