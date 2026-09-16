import 'package:flutter/material.dart';
import 'package:mobile/screens/signup_screen.dart';
import 'package:mobile/screens/forgot_password_screen.dart';
import 'package:mobile/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _gridController;
  late AnimationController _floatController;
  late AnimationController _breathController;
  late AnimationController _entranceController;

  late Animation<double> _floatAnimation;
  late Animation<double> _breathAnimation;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _formOpacity;
  late Animation<Offset> _formSlide;
  late Animation<double> _buttonOpacity;
  late Animation<Offset> _buttonSlide;
  late Animation<double> _bioOpacity;
  late Animation<Offset> _bioSlide;

  bool _obscurePassword = true;
  bool _isLoading = false;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _emailHasFocus = false;
  bool _passwordHasFocus = false;

  @override
  void initState() {
    super.initState();

    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _breathAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _formOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _bioOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );

    _bioSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );

    _emailFocusNode.addListener(() {
      setState(() => _emailHasFocus = _emailFocusNode.hasFocus);
    });

    _passwordFocusNode.addListener(() {
      setState(() => _passwordHasFocus = _passwordFocusNode.hasFocus);
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _gridController.dispose();
    _floatController.dispose();
    _breathController.dispose();
    _entranceController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ===== FUNDO =====
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A1018),
                  Color(0xFF0C1420),
                ],
              ),
            ),
          ),

          // ===== GRID DINÂMICO =====
          AnimatedBuilder(
            animation: _gridController,
            builder: (context, child) {
              return CustomPaint(
                painter: DynamicGridPainter(
                  progress: _gridController.value,
                ),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          // ===== CONTEÚDO =====
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),

                      // ===== LOGO FLUTUANDO + BREATHING =====
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _floatController,
                          _breathController,
                          _entranceController,
                        ]),
                        builder: (context, child) {
                          return Opacity(
                            opacity: _logoOpacity.value,
                            child: Transform.translate(
                              offset: Offset(0, _floatAnimation.value),
                              child: Transform.scale(
                                scale: _logoScale.value * _breathAnimation.value,
                                child: Image.asset(
                                  'assets/logoSHG.png',
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // ===== TÍTULO =====
                      FadeTransition(
                        opacity: _logoOpacity,
                        child: const Text(
                          'Smart Home Guardian',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: Color(0xFFE8EAED),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // ===== SUBTÍTULO =====
                      FadeTransition(
                        opacity: _formOpacity,
                        child: const Text(
                          'Segurança inteligente para sua casa',
                          style: TextStyle(
                            color: Color(0xFF8B9DAB),
                            fontSize: 13,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ===== CAMPO DE E-MAIL =====
                      FadeTransition(
                        opacity: _formOpacity,
                        child: SlideTransition(
                          position: _formSlide,
                          child: _buildEmailField(),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ===== CAMPO DE SENHA =====
                      FadeTransition(
                        opacity: _formOpacity,
                        child: SlideTransition(
                          position: _formSlide,
                          child: _buildPasswordField(),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ===== BOTÃO ENTRAR =====
                      FadeTransition(
                        opacity: _buttonOpacity,
                        child: SlideTransition(
                          position: _buttonSlide,
                          child: _buildGradientButton(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ===== BOTÃO BIOMETRIA =====
                      FadeTransition(
                        opacity: _bioOpacity,
                        child: SlideTransition(
                          position: _bioSlide,
                          child: _buildBiometricButton(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ===== ESQUECI MINHA SENHA =====
                      FadeTransition(
                        opacity: _bioOpacity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Esqueci minha senha',
                            style: TextStyle(
                              color: Color(0xFF4DB6AC),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ===== DIVISOR =====
                      FadeTransition(
                        opacity: _bioOpacity,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: const Color(0xFF1A2535),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(
                                Icons.shield_outlined,
                                size: 16,
                                color: Color(0xFF2A3B4D),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: const Color(0xFF1A2535),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ===== CADASTRE-SE =====
                      FadeTransition(
                        opacity: _bioOpacity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Não tem conta? ',
                              style: TextStyle(
                                color: Color(0xFF6B7D8C),
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SignupScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Cadastre-se',
                                style: TextStyle(
                                  color: Color(0xFF4DB6AC),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== CAMPO DE E-MAIL =====
  Widget _buildEmailField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: _emailHasFocus
            ? [
                BoxShadow(
                  color: const Color(0xFF4DB6AC).withValues(alpha: 0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: TextField(
        focusNode: _emailFocusNode,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Color(0xFFE8EAED), fontSize: 15),
        decoration: InputDecoration(
          hintText: _emailHasFocus ? 'exemplo@gmail.com' : 'E-mail',
          hintStyle: TextStyle(
            color: _emailHasFocus
                ? const Color(0xFF4DB6AC).withValues(alpha: 0.6)
                : const Color(0xFF5A6B7A),
            fontSize: 14,
          ),
          filled: true,
          fillColor: const Color(0xFF111923),
          prefixIcon: const Icon(Icons.email_outlined,
              color: Color(0xFF4DB6AC), size: 20),
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
            borderSide: const BorderSide(color: Color(0xFF4DB6AC), width: 1.5),
          ),
        ),
      ),
    );
  }

  // ===== CAMPO DE SENHA =====
  Widget _buildPasswordField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: _passwordHasFocus
            ? [
                BoxShadow(
                  color: const Color(0xFF4DB6AC).withValues(alpha: 0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: TextField(
        focusNode: _passwordFocusNode,
        obscureText: _obscurePassword,
        style: const TextStyle(color: Color(0xFFE8EAED), fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Senha',
          hintStyle: const TextStyle(color: Color(0xFF5A6B7A), fontSize: 14),
          filled: true,
          fillColor: const Color(0xFF111923),
          prefixIcon: const Icon(Icons.lock_outline,
              color: Color(0xFF4DB6AC), size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF4DB6AC),
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
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
            borderSide: const BorderSide(color: Color(0xFF4DB6AC), width: 1.5),
          ),
        ),
      ),
    );
  }

  // ===== BOTÃO ENTRAR =====
  Widget _buildGradientButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF00897B),
              Color(0xFF26A69A),
              Color(0xFF4DB6AC),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF26A69A).withValues(alpha: 0.25),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _isLoading ? null : _handleLogin,
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'ENTRAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== BOTÃO BIOMETRIA =====
  Widget _buildBiometricButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF111923),
          border: Border.all(
            color: const Color(0xFF2A3B4D),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {},
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fingerprint,
                  size: 24,
                  color: Color(0xFF4DB6AC),
                ),
                SizedBox(width: 10),
                Text(
                  'Entrar com biometria',
                  style: TextStyle(
                    color: Color(0xFFB0BEC5),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===== PAINTER: GRID DINÂMICO COM LUZ VIAJANTE =====
class DynamicGridPainter extends CustomPainter {
  final double progress;

  DynamicGridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 35.0;

    final Paint linePaint = Paint()
      ..color = const Color(0xFF1A2535).withValues(alpha: 0.6)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final double scanX = size.width * progress;
    final double scanY = size.height * progress;
    final double bandWidth = 120.0;

    for (double x = 0; x < size.width; x += spacing) {
      final double distance = (x - scanX).abs();
      if (distance < bandWidth) {
        final double intensity = 1.0 - (distance / bandWidth);
        final Paint glowLine = Paint()
          ..color = const Color(0xFF4DB6AC)
              .withValues(alpha: 0.15 * intensity)
          ..strokeWidth = 1.0 + intensity;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), glowLine);
      }
    }
    for (double y = 0; y < size.height; y += spacing) {
      final double distance = (y - scanY).abs();
      if (distance < bandWidth) {
        final double intensity = 1.0 - (distance / bandWidth);
        final Paint glowLine = Paint()
          ..color = const Color(0xFF4DB6AC)
              .withValues(alpha: 0.15 * intensity)
          ..strokeWidth = 1.0 + intensity;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), glowLine);
      }
    }

    final double crossX = (scanX / spacing).floor() * spacing;
    final double crossY = (scanY / spacing).floor() * spacing;
    if (crossX >= 0 &&
        crossX < size.width &&
        crossY >= 0 &&
        crossY < size.height) {
      final Paint dotPaint = Paint()
        ..color = const Color(0xFF4DB6AC).withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(crossX, crossY), 3, dotPaint);
      final Paint corePaint = Paint()..color = const Color(0xFF80CBC4);
      canvas.drawCircle(Offset(crossX, crossY), 1.5, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}