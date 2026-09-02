import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: const Center(
        child: Text(
          'Tela de Login do SmartHome Guardian',
          style: TextStyle(color: AppColors.white, fontSize: 18),
        ),
      ),
    );
  }
}