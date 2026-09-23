import 'package:flutter/material.dart';
import 'tabs/home_tab.dart';
import 'tabs/alerts_tab.dart';
import 'tabs/rooms_tab.dart';
import 'tabs/profile_tab.dart';

class DashboardScreen extends StatefulWidget {
<<<<<<< HEAD
  final String nome;
  final String email;

  const DashboardScreen({
    super.key,
    this.nome = 'Rafael',
    this.email = 'rafael@email.com',
  });
=======
  const DashboardScreen({super.key});
>>>>>>> 3f01e8d6dcced2c2092341912116da1b2675cc18

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _gridController;
  late AnimationController _entranceController;

  late Animation<double> _contentOpacity;
  late Animation<double> _navOpacity;

  int _currentTab = 0;

  @override
  void initState() {
    super.initState();

    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _navOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _gridController.dispose();
    _entranceController.dispose();
    super.dispose();
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
                colors: [Color(0xFF0A1018), Color(0xFF0C1420)],
              ),
            ),
          ),

          // ===== GRID DINÂMICO =====
          AnimatedBuilder(
            animation: _gridController,
            builder: (context, child) {
              return CustomPaint(
                painter: DashboardGridPainter(progress: _gridController.value),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          // ===== CONTEÚDO DAS ABAS =====
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: FadeTransition(
                    opacity: _contentOpacity,
                    child: IndexedStack(
                      index: _currentTab,
<<<<<<< HEAD
                      children: [
                        HomeTab(
                          nome: widget.nome,
                          onVerTodos: () => setState(() => _currentTab = 2),
                          onAbrirAlertas: () => setState(() => _currentTab = 1),
                        ),
                        const AlertsTab(),
                        const RoomsTab(),
                        ProfileTab(nome: widget.nome, email: widget.email),
=======
                      children: const [
                        HomeTab(),
                        AlertsTab(),
                        RoomsTab(),
                        ProfileTab(),
>>>>>>> 3f01e8d6dcced2c2092341912116da1b2675cc18
                      ],
                    ),
                  ),
                ),

                // ===== BOTTOM NAVIGATION =====
                FadeTransition(
                  opacity: _navOpacity,
                  child: _buildBottomNav(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111923),
        border: Border(
          top: BorderSide(color: const Color(0xFF1E2A38), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavTab(icon: Icons.home_outlined,
                activeIcon: Icons.home, label: 'Home', index: 0),
              _buildNavTab(icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications, label: 'Alertas', index: 1),
              _buildNavTab(icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view, label: 'Ambientes', index: 2),
              _buildNavTab(icon: Icons.person_outline,
                activeIcon: Icons.person, label: 'Perfil', index: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavTab({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon,
              size: 24,
              color: isActive
                  ? const Color(0xFF4DB6AC)
                  : const Color(0xFF6B7D8C)),
            const SizedBox(height: 4),
            Text(label,
              style: TextStyle(fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? const Color(0xFF4DB6AC)
                    : const Color(0xFF6B7D8C))),
          ],
        ),
      ),
    );
  }
}

// ===== GRID PAINTER (mantido igual) =====
class DashboardGridPainter extends CustomPainter {
  final double progress;
  DashboardGridPainter({required this.progress});

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
          ..color = const Color(0xFF4DB6AC)
              .withValues(alpha: 0.12 * intensity)
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
              .withValues(alpha: 0.12 * intensity)
          ..strokeWidth = 1.0 + intensity;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), glowLine);
      }
    }

    final double crossX = (scanX / spacing).floor() * spacing;
    final double crossY = (scanY / spacing).floor() * spacing;
    if (crossX >= 0 && crossX < size.width && crossY >= 0 && crossY < size.height) {
      final Paint dotPaint = Paint()
        ..color = const Color(0xFF4DB6AC).withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(crossX, crossY), 3, dotPaint);
      final Paint corePaint = Paint()..color = const Color(0xFF80CBC4);
      canvas.drawCircle(Offset(crossX, crossY), 1.5, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}