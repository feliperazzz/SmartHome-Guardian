import 'package:flutter/material.dart';
import 'package:mobile/screens/splash_screen.dart';
import 'package:mobile/services/device_service.dart';

Future<void> main() async {
  // Garante que o Flutter inicializou antes de acessar o armazenamento local
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega os sensores/dispositivos salvos da sessão anterior
  await DeviceService.instance.carregar();

  runApp(const SmartHomeGuardian());
}

class SmartHomeGuardian extends StatelessWidget {
  const SmartHomeGuardian({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home Guardian',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // ===== ALINHAMENTO À IDENTIDADE VISUAL DO APP =====
        scaffoldBackgroundColor: Colors.transparent,
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4DB6AC), // teal de destaque do app
          brightness: Brightness.dark,
        ),
        // ===== DIALOGS (modal do Sair, etc.) no padrão visual =====
        dialogTheme: const DialogThemeData(
          backgroundColor: Color(0xFF111923),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          titleTextStyle: TextStyle(
            color: Color(0xFFE8EAED),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          contentTextStyle: TextStyle(
            color: Color(0xFF8B9DAB),
            fontSize: 14,
          ),
        ),
        // ===== INPUTS nativos com tema escuro coerente =====
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF111923),
          hintStyle: const TextStyle(color: Color(0xFF5A6B7A), fontSize: 14),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF1E2A38), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF1E2A38), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFF4DB6AC), width: 1.5),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}