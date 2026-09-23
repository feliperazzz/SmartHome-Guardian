import 'package:flutter/material.dart';
import 'package:mobile/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _gridController;
  late AnimationController _floatController;
  late AnimationController _entranceController;
  late AnimationController _exitController;

  late Animation<double> _floatAnimation;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _titleOpacity;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _loaderOpacity;
  late Animation<double> _exitOpacity;
  late Animation<Offset> _exitSlide;

  @override
  void initState() {
    super.initState();

    // Grid animado de fundo (mesma identidade do signup)
    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Logo flutuando suavemente
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Entrada em sequência: logo → título → subtítulo → loader
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
      ),
    );

    _loaderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    // Saída: tudo desliza pra cima e desaparece
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _exitSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.15),
    ).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _startSequence();
  }

  // ===== SEQUÊNCIA: entra → espera → sai → navega pro login =====
  Future<void> _startSequence() async {
    _entranceController.forward();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    await _exitController.forward();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _gridController.dispose();
    _floatController.dispose();
    _entranceController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo com o mesmo gradiente das outras telas
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A1018), Color(0xFF0C1420)],
              ),
            ),
          ),
          // Grid animado de fundo
          AnimatedBuilder(
            animation: _gridController,
            builder: (context, child) {
              return CustomPaint(
                painter: SplashGridPainter(progress: _gridController.value),
                size: MediaQuery.of(context).size,
              );
            },
          ),
          // Conteúdo central
          SafeArea(
            child: FadeTransition(
              opacity: _exitOpacity,
              child: SlideTransition(
                position: _exitSlide,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ===== LOGO =====
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _floatController,
                          _entranceController,
                        ]),
                        builder: (context, child) {
                          return Opacity(
                            opacity: _logoOpacity.value,
                            child: Transform.translate(
                              offset: Offset(0, _floatAnimation.value),
                              child: Transform.scale(
                                scale: _logoScale.value,
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
                      const SizedBox(height: 20),
                      // ===== NOME DO APP =====
                      FadeTransition(
                        opacity: _titleOpacity,
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
                      // ===== SLOGAN =====
                      FadeTransition(
                        opacity: _subtitleOpacity,
                        child: const Text(
                          'Sua casa, sempre protegida',
                          style: TextStyle(
                            fontSize: 13,
                            letterSpacing: 0.3,
                            color: Color(0xFF8B9DAB),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      // ===== LOADER =====
                      FadeTransition(
                        opacity: _loaderOpacity,
                        child: const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: Color(0xFF4DB6AC),
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
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
}

// ===== GRID PAINTER DA SPLASH =====
class SplashGridPainter extends CustomPainter {
  final double progress;
  SplashGridPainter({required this.progress});

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