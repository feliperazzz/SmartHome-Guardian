import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _sistemaArmado = true;

  final List<Map<String, dynamic>> _ambientes = [
    {'nome': 'Sala', 'icon': Icons.weekend_outlined, 'seguro': true},
    {'nome': 'Cozinha', 'icon': Icons.kitchen_outlined, 'seguro': true},
    {'nome': 'Quarto', 'icon': Icons.bed_outlined, 'seguro': true},
    {'nome': 'Quarto 2', 'icon': Icons.bed_outlined, 'seguro': true},
    {'nome': 'Garagem', 'icon': Icons.garage_outlined, 'seguro': false},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          // ===== HEADER =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Olá, Felipe!',
                    style: TextStyle(fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE8EAED))),
                  const SizedBox(height: 2),
                  Text(_sistemaArmado ? 'Sistema armado' : 'Sistema desarmado',
                    style: TextStyle(fontSize: 12,
                      color: _sistemaArmado
                          ? const Color(0xFF4DB6AC)
                          : const Color(0xFF8B9DAB))),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111923),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1E2A38), width: 1),
                  ),
                  child: const Icon(Icons.settings_outlined,
                    color: Color(0xFF4DB6AC), size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ===== STATUS HERO =====
          _buildStatusHero(),
          const SizedBox(height: 20),

          // ===== 4 CARDS DE STATUS =====
          _buildStatusGrid(),
          const SizedBox(height: 24),

          // ===== AMBIENTES =====
          _buildAmbientesSection(),
        ],
      ),
    );
  }

  Widget _buildStatusHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF111923),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF4DB6AC).withValues(alpha: 0.2),
          width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4DB6AC).withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 0),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4DB6AC).withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.verified_user_outlined,
              size: 40, color: Color(0xFF4DB6AC)),
          ),
          const SizedBox(height: 12),
          const Text('Sua residência está segura!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
              color: Color(0xFFE8EAED))),
          const SizedBox(height: 4),
          Text('Última verificação: agora mesmo',
            style: TextStyle(fontSize: 12,
              color: const Color(0xFF8B9DAB).withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  Widget _buildStatusGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatusCard(
              title: 'Sensores Ativos',
              value: '5',
              icon: Icons.sensors_outlined,
              valueColor: const Color(0xFF4DB6AC),
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildStatusCard(
              title: 'Alertas Recentes',
              value: 'Porta aberta',
              subtitle: 'Garagem',
              icon: Icons.warning_amber_outlined,
              valueColor: const Color(0xFFFFB74D),
              isSmallValue: true,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatusCard(
              title: 'Ambientes Seguros',
              value: '5',
              icon: Icons.home_outlined,
              valueColor: const Color(0xFF4DB6AC),
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildToggleCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String value,
    required IconData icon,
    required Color valueColor,
    String? subtitle,
    bool isSmallValue = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111923),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2A38), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 20, color: valueColor),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: valueColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: valueColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(title,
            style: const TextStyle(fontSize: 11,
              color: Color(0xFF8B9DAB), fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value,
            style: TextStyle(
              fontSize: isSmallValue ? 14 : 24,
              fontWeight: FontWeight.w700,
              color: valueColor)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle,
              style: TextStyle(fontSize: 11,
                color: valueColor.withValues(alpha: 0.7))),
          ],
        ],
      ),
    );
  }

  Widget _buildToggleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111923),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _sistemaArmado
              ? const Color(0xFF4DB6AC).withValues(alpha: 0.3)
              : const Color(0xFF1E2A38),
          width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.power_settings_new_outlined,
            size: 20,
            color: _sistemaArmado
                ? const Color(0xFF4DB6AC)
                : const Color(0xFF8B9DAB)),
          const SizedBox(height: 10),
          const Text('Controle do Sistema',
            style: TextStyle(fontSize: 11,
              color: Color(0xFF8B9DAB), fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_sistemaArmado ? 'Armado' : 'Desarmado',
                style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _sistemaArmado
                      ? const Color(0xFF4DB6AC)
                      : const Color(0xFF8B9DAB))),
              GestureDetector(
                onTap: () {
                  setState(() => _sistemaArmado = !_sistemaArmado);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _sistemaArmado
                        ? const Color(0xFF4DB6AC)
                        : const Color(0xFF1E2A38),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: _sistemaArmado
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Ambientes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                color: Color(0xFFE8EAED))),
            GestureDetector(
              onTap: () {},
              child: const Text('Ver todos',
                style: TextStyle(fontSize: 12,
                  color: Color(0xFF4DB6AC), fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _ambientes.length,
            itemBuilder: (context, index) {
              final amb = _ambientes[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == _ambientes.length - 1 ? 0 : 12),
                child: _buildAmbienteCard(
                  nome: amb['nome'] as String,
                  icon: amb['icon'] as IconData,
                  seguro: amb['seguro'] as bool,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAmbienteCard({
    required String nome,
    required IconData icon,
    required bool seguro,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111923),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: seguro
              ? const Color(0xFF1E2A38)
              : const Color(0xFFFFB74D).withValues(alpha: 0.3),
          width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28,
            color: seguro ? const Color(0xFF4DB6AC) : const Color(0xFFFFB74D)),
          const SizedBox(height: 8),
          Text(nome,
            style: const TextStyle(fontSize: 13,
              color: Color(0xFFE8EAED), fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: seguro ? const Color(0xFF00E676) : const Color(0xFFFFB74D),
                ),
              ),
              const SizedBox(width: 4),
              Text(seguro ? 'Seguro' : 'Alerta',
                style: TextStyle(fontSize: 10,
                  color: seguro
                      ? const Color(0xFF00E676)
                      : const Color(0xFFFFB74D))),
            ],
          ),
        ],
      ),
    );
  }
}