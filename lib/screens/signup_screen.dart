import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
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

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _nameHasFocus = false;
  bool _emailHasFocus = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

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
      CurvedAnimation(parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );

    _formOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut)),
    );

    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut)));

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );

    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));

    _nameFocus.addListener(() => setState(() => _nameHasFocus = _nameFocus.hasFocus));
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  bool _validateFields() {
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmError = null;
    });

    bool isValid = true;

    if (_nameController.text.trim().isEmpty) {
      _nameError = 'Informe seu nome';
      isValid = false;
    } else if (_nameController.text.trim().length < 3) {
      _nameError = 'Nome muito curto';
      isValid = false;
    }

    if (_emailController.text.trim().isEmpty) {
      _emailError = 'Informe seu e-mail';
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text.trim())) {
      _emailError = 'E-mail inválido';
      isValid = false;
    }

    if (_passwordController.text.isEmpty) {
      _passwordError = 'Crie uma senha';
      isValid = false;
    } else if (_passwordController.text.length < 6) {
      _passwordError = 'Mínimo de 6 caracteres';
      isValid = false;
    }

    if (_confirmPasswordController.text.isEmpty) {
      _confirmError = 'Confirme sua senha';
      isValid = false;
    } else if (_confirmPasswordController.text != _passwordController.text) {
      _confirmError = 'As senhas não coincidem';
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  void _handleSignup() {
    if (!_validateFields()) return;
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta criada com sucesso!'),
          backgroundColor: Color(0xFF00897B),
        ),
      );
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A1018), Color(0xFF0C1420)],
              ),
            ),
          ),
          // Grid dinâmico
          AnimatedBuilder(
            animation: _gridController,
            builder: (context, child) {
              return CustomPaint(
                painter: DynamicGridPainter(progress: _gridController.value),
                size: MediaQuery.of(context).size,
              );
            },
          ),
          // Conteúdo
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
                      const SizedBox(height: 20),

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
                                  width: 90, height: 90, fit: BoxFit.contain),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // ===== TÍTULO =====
                      FadeTransition(
                        opacity: _logoOpacity,
                        child: const Text('Criar conta',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                            letterSpacing: 0.5, color: Color(0xFFE8EAED))),
                      ),
                      const SizedBox(height: 6),

                      FadeTransition(
                        opacity: _formOpacity,
                        child: const Text('Comece a proteger sua casa hoje',
                          style: TextStyle(color: Color(0xFF8B9DAB),
                            fontSize: 13, letterSpacing: 0.3)),
                      ),
                      const SizedBox(height: 28),

                      // ===== CAMPOS =====
                      FadeTransition(
                        opacity: _formOpacity,
                        child: SlideTransition(
                          position: _formSlide,
                          child: Column(
                            children: [
                              _buildField(
                                controller: _nameController,
                                focusNode: _nameFocus,
                                hasFocus: _nameHasFocus,
                                icon: Icons.person_outline,
                                hint: 'Nome completo',
                                focusedHint: 'João Silva',
                                errorText: _nameError,
                              ),
                              const SizedBox(height: 12),
                              _buildField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                hasFocus: _emailHasFocus,
                                icon: Icons.email_outlined,
                                hint: 'E-mail',
                                focusedHint: 'exemplo@gmail.com',
                                errorText: _emailError,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 12),
                              _buildPasswordField(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                icon: Icons.lock_outline,
                                hint: 'Senha',
                                obscure: _obscurePassword,
                                onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                                errorText: _passwordError,
                              ),
                              const SizedBox(height: 12),
                              _buildPasswordField(
                                controller: _confirmPasswordController,
                                focusNode: _confirmFocus,
                                icon: Icons.lock_outline,
                                hint: 'Confirmar senha',
                                obscure: _obscureConfirm,
                                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                errorText: _confirmError,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ===== BOTÃO CADASTRAR =====
                      FadeTransition(
                        opacity: _buttonOpacity,
                        child: SlideTransition(
                          position: _buttonSlide,
                          child: _buildGradientButton(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ===== DIVISOR =====
                      FadeTransition(
                        opacity: _buttonOpacity,
                        child: Row(
                          children: [
                            Expanded(child: Container(height: 1, color: const Color(0xFF1A2535))),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(Icons.shield_outlined, size: 16, color: Color(0xFF2A3B4D)),
                            ),
                            Expanded(child: Container(height: 1, color: const Color(0xFF1A2535))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ===== VOLTAR PARA LOGIN =====
                      FadeTransition(
                        opacity: _buttonOpacity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Já tem conta? ',
                              style: TextStyle(color: Color(0xFF6B7D8C), fontSize: 13)),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text('Entrar',
                                style: TextStyle(color: Color(0xFF4DB6AC),
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
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

  // ===== CAMPO DE TEXTO =====
  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool hasFocus,
    required IconData icon,
    required String hint,
    required String focusedHint,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: hasFocus
            ? [BoxShadow(color: const Color(0xFF4DB6AC).withValues(alpha: 0.15),
                blurRadius: 8, spreadRadius: 1)]
            : [],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        style: const TextStyle(color: Color(0xFFE8EAED), fontSize: 15),
        decoration: InputDecoration(
          hintText: hasFocus ? focusedHint : hint,
          hintStyle: TextStyle(
            color: hasFocus
                ? const Color(0xFF4DB6AC).withValues(alpha: 0.6)
                : const Color(0xFF5A6B7A),
            fontSize: 14,
          ),
          errorText: errorText,
          errorStyle: const TextStyle(color: Color(0xFFEF5350), fontSize: 12),
          filled: true,
          fillColor: const Color(0xFF111923),
          prefixIcon: Icon(icon, color: const Color(0xFF4DB6AC), size: 20),
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

  // ===== CAMPO DE SENHA =====
  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? errorText,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: focusNode.hasFocus
            ? [BoxShadow(color: const Color(0xFF4DB6AC).withValues(alpha: 0.15),
                blurRadius: 8, spreadRadius: 1)]
            : [],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscure,
        style: const TextStyle(color: Color(0xFFE8EAED), fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF5A6B7A), fontSize: 14),
          errorText: errorText,
          errorStyle: const TextStyle(color: Color(0xFFEF5350), fontSize: 12),
          filled: true,
          fillColor: const Color(0xFF111923),
          prefixIcon: Icon(icon, color: const Color(0xFF4DB6AC), size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: const Color(0xFF4DB6AC), size: 20),
            onPressed: onToggle,
          ),
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

  // ===== BOTÃO GRADIENTE =====
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
            colors: [Color(0xFF00897B), Color(0xFF26A69A), Color(0xFF4DB6AC)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF26A69A).withValues(alpha: 0.25),
              blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _isLoading ? null : _handleSignup,
            child: Center(
              child: _isLoading
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Text('CADASTRAR',
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
class DynamicGridPainter extends CustomPainter {
  final double progress;
  DynamicGridPainter({required this.progress});

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