import 'package:flutter/material.dart';
import 'package:mobile/screens/room_detail_screen.dart';

class RoomsTab extends StatelessWidget {
  const RoomsTab({super.key});

  static const List<Map<String, dynamic>> ambientes = [
    {
      'nome': 'Sala',
      'icon': Icons.weekend_outlined,
      'seguro': true,
      'sensores': 2,
      'dispositivos': 'Sensor de movimento, Sensor de porta',
    },
    {
      'nome': 'Cozinha',
      'icon': Icons.kitchen_outlined,
      'seguro': true,
      'sensores': 1,
      'dispositivos': 'Sensor de fumaça',
    },
    {
      'nome': 'Quarto',
      'icon': Icons.bed_outlined,
      'seguro': true,
      'sensores': 1,
      'dispositivos': 'Sensor de janela',
    },
    {
      'nome': 'Quarto 2',
      'icon': Icons.bed_outlined,
      'seguro': true,
      'sensores': 1,
      'dispositivos': 'Sensor de porta',
    },
    {
      'nome': 'Garagem',
      'icon': Icons.garage_outlined,
      'seguro': false,
      'sensores': 1,
      'dispositivos': 'Sensor de porta da garagem',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final seguros = ambientes.where((a) => a['seguro'] as bool).length;

    return Column(
      children: [
        // ===== HEADER =====
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ambientes',
                style: TextStyle(fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE8EAED))),
              const SizedBox(height: 2),
              Text('$seguros de ${ambientes.length} protegidos',
                style: TextStyle(fontSize: 12,
                  color: seguros == ambientes.length
                      ? const Color(0xFF4DB6AC)
                      : const Color(0xFFFFB74D))),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ===== GRID DE AMBIENTES =====
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemCount: ambientes.length,
            itemBuilder: (context, index) {
              final amb = ambientes[index];
              return _buildRoomCard(
                context,
                nome: amb['nome'] as String,
                icon: amb['icon'] as IconData,
                seguro: amb['seguro'] as bool,
                sensores: amb['sensores'] as int,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRoomCard(
    BuildContext context, {
    required String nome,
    required IconData icon,
    required bool seguro,
    required int sensores,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDetailScreen(
              nome: nome,
              icon: icon,
              seguro: seguro,
              sensores: sensores,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111923),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seguro
                ? const Color(0xFF1E2A38)
                : const Color(0xFFFFB74D).withValues(alpha: 0.4),
            width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 30,
                  color: seguro
                      ? const Color(0xFF4DB6AC)
                      : const Color(0xFFFFB74D)),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: seguro
                        ? const Color(0xFF00E676)
                        : const Color(0xFFFFB74D),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(nome,
              style: const TextStyle(fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE8EAED))),
            const SizedBox(height: 2),
            Text('$sensores sensor${sensores > 1 ? 'es' : ''}',
              style: const TextStyle(fontSize: 11,
                color: Color(0xFF6B7D8C))),
            const SizedBox(height: 4),
            Text(seguro ? 'Seguro' : 'Atenção',
              style: TextStyle(fontSize: 11,
                fontWeight: FontWeight.w500,
                color: seguro
                    ? const Color(0xFF00E676)
                    : const Color(0xFFFFB74D))),
          ],
        ),
      ),
    );
  }
}