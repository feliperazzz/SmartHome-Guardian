import 'package:flutter/material.dart'; 
import 'screens/login_screen.dart';

void main() {
  runApp(const SmartHomeApp());
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //remove o debug de marca dágua
      title: 'SmartHome Guardian',
      home: LoginScreen(),
    );
  }
}