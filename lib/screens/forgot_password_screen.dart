
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
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

  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();
  bool _emailHasFocus = false;
  bool _isLoading = false;
  bool _emailSent = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();

    _gridController = AnimationController(
      vsync: this, duration: const Duration(seconds: 6))..repeat();

    _floatController = AnimationController(
      vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    _breathController = AnimationController(
      vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);

    _breathAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut));

    _entranceController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400));

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)));

    _formOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut)));

    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.25), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut)));

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));

    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.4), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));

    _emailFocus.addListener(() => setState(() => _emailHasFocus = _emailFocus.hasFocus));

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
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _handleSend() {
    setState(() => _emailError = null);

    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = 'Informe seu e-mail');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text.trim())) {
      setState(() => _emailError = 'E-mail inválido');
      return;
    }

    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A1018), Color(0xFF0C1420)],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _gridController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ForgotGridPainter(progress: _gridController.value),
                size: MediaQuery.of(context).size,
              );
            },
          ),
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
                    children: [
                      const SizedBox(height: 30),

                      // ===== LOGO =====
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _floatController, _breathController, _entranceController,
                        ]),
                        builder: (context, child) {
                          return Opacity(
                            opacity: _logoOpacity.value,
                            child: Transform.translate(
                              offset: Offset(0, _floatAnimation.value),
                              child: Transform.scale(
                                scale: _logoScale.value * _breathAnimation.value,
                                child: Image.asset('assets/logoSHG.png',
                                  width: 100, height: 100, fit: BoxFit.contain),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // ===== TÍTULO =====
                      FadeTransition(
                        opacity: _logoOpacity,
                        child: const Text('Recuperar senha',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                            letterSpacing: 0.5, color: Color(0xFFE8EAED))),
                      ),
                      const SizedBox(height: 6),

                      FadeTransition(
                        opacity: _formOpacity,
                        child: const Text(
                          'Digite seu e-mail para receber as instruções',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF8B9DAB),
                            fontSize: 13, letterSpacing: 0.3)),
                      ),
                      const SizedBox(height: 32),

                      // ===== CAMPO OU CONFIRMAÇÃO =====
                      if (!_emailSent) ...[
                        FadeTransition(
                          opacity: _formOpacity,
                          child: SlideTransition(
                            position: _formSlide,
                            child: _buildEmailField(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ===== BOTÃO ENVIAR =====
                        FadeTransition(
                          opacity: _buttonOpacity,
                          child: SlideTransition(
                            position: _buttonSlide,
                            child: _buildSendButton(),
                          ),
                        ),
                      ] else ...[
                        // ===== CONFIRMAÇÃO =====
                        FadeTransition(
                          opacity: _formOpacity,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111923),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF4DB6AC).withValues(alpha: 0.2),
                                width: 1),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.mark_email_read_outlined,
                                  size: 48, color: Color(0xFF4DB6AC)),
                                const SizedBox(height: 16),
                                const Text('E-mail enviado!',
                                  style: TextStyle(color: Color(0xFFE8EAED),
                                    fontSize: 18, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Text(
                                  'Enviamos instruções para\n${_emailController.text.trim()}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Color(0xFF8B9DAB),
                                    fontSize: 13)),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF00897B), Color(0xFF4DB6AC)]),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(14),
                                        onTap: () => Navigator.pop(context),
                                        child: const Center(
                                          child: Text('VOLTAR PARA LOGIN',
                                            style: TextStyle(color: Colors.white,
                                              fontSize: 14, fontWeight: FontWeight.w700,
                                              letterSpacing: 1.5)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),

                      // ===== VOLTAR =====
                      FadeTransition(
                        opacity: _buttonOpacity,
                        child: TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, size: 18,
                            color: Color(0xFF4DB6AC)),
                          label: const Text('Voltar para login',
                            style: TextStyle(color: Color(0xFF4DB6AC),
                              fontSize: 13, fontWeight: FontWeight.w500)),
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

  Widget _buildEmailField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: _emailHasFocus
            ? [BoxShadow(color: const Color(0xFF4DB6AC).withValues(alpha: 0.15),
                blurRadius: 8, spreadRadius: 1)]
            : [],
      ),
      child: TextField(
        controller: _emailController,
        focusNode: _emailFocus,
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
          errorText: _emailError,
          errorStyle: const TextStyle(color: Color(0xFFEF5350), fontSize: 12),
          filled: true,
          fillColor: const Color(0xFF111923),
          prefixIcon:
              const Icon(Icons.email_outlined, color: Color(0xFF4DB6AC), size: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF00897B), Color(0xFF26A69A), Color(0xFF4DB6AC)],
          ),
          boxShadow: [
            BoxShadow(color: const Color(0xFF26A69A).withValues(alpha: 0.25),
              blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _isLoading ? null : _handleSend,
            child: Center(
              child: _isLoading
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Text('ENVIAR',
                    style: TextStyle(color: Colors.white, fontSize: 15,
                      fontWeight: FontWeight.w700, letterSpacing: 2)),
            ),
          ),
        ),
      ),
    );
  }
}

// ===== GRID PAINTER =====
class _ForgotGridPainter extends CustomPainter {
  final double progress;
  _ForgotGridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 35.0;
    final linePaint = Paint()
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
          ..color = const Color(0xFF4DB6AC).withValues(alpha: 0.15 * intensity)
          ..strokeWidth = 1.0 + intensity;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), glowLine);
      }
    }
    for (double y = 0; y < size.height; y += spacing) {
      final double distance = (y - scanY).abs();
      if (distance < bandWidth) {
        final double intensity = 1.0 - (distance / bandWidth);
        final Paint glowLine = Paint()
          ..color = const Color(0xFF4DB6AC).withValues(alpha: 0.15 * intensity)
          ..strokeWidth = 1.0 + intensity;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), glowLine);
      }
    }

    final double crossX = (scanX / spacing).floor() * spacing;
    final double crossY = (scanY / spacing).floor() * spacing;
    if (crossX >= 0 && crossX < size.width && crossY >= 0 && crossY < size.height) {
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