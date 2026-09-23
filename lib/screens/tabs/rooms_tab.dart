import 'package:flutter/material.dart';
import 'package:mobile/screens/room_detail_screen.dart';
import 'package:mobile/services/system_service.dart';

class RoomsTab extends StatefulWidget {
  const RoomsTab({super.key});

  @override
  State<RoomsTab> createState() => _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab> {
  // ===== DADOS DOS AMBIENTES =====
  final List<Map<String, dynamic>> _ambientes = [
    {'nome': 'Sala', 'icon': Icons.weekend_outlined, 'seguro': true, 'sensores': 2},
    {'nome': 'Cozinha', 'icon': Icons.kitchen_outlined, 'seguro': true, 'sensores': 1},
    {'nome': 'Quarto', 'icon': Icons.bed_outlined, 'seguro': true, 'sensores': 1},
    {'nome': 'Quarto 2', 'icon': Icons.bed_outlined, 'seguro': true, 'sensores': 1},
    {'nome': 'Garagem', 'icon': Icons.garage_outlined, 'seguro': false, 'sensores': 1},
  ];

  int get _protegidos => _ambientes.where((a) => a['seguro'] == true).length;

  // ===== ABRIR DETALHE E SINCRONIZAR DE VOLTA =====
  Future<void> _abrirDetalhe(int index) async {
    final ambiente = _ambientes[index];

    final resultado = await Navigator.push<Map>(
      context,
      MaterialPageRoute(
        builder: (context) => RoomDetailScreen(
          nome: ambiente['nome'] as String,
          icon: ambiente['icon'] as IconData,
          seguro: ambiente['seguro'] as bool,
          sensores: ambiente['sensores'] as int,
        ),
      ),
    );

    if (resultado != null && mounted) {
      setState(() {
        ambiente['seguro'] = resultado['seguro'] ?? ambiente['seguro'];
        ambiente['sensores'] = resultado['sensores'] ?? ambiente['sensores'];
      });
      // Mantém o contador de sensores da Home em sincronia
      final totalSensores = _ambientes.fold<int>(
        0, (soma, a) => soma + (a['sensores'] as int));
      SystemService.instance.atualizarSensores(totalSensores);
      SystemService.instance
          .atualizarAmbientes(_ambientes.where((a) => a['seguro'] == true).length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ===== HEADER =====
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ambientes',
                    style: TextStyle(fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE8EAED))),
                  const SizedBox(height: 2),
                  Text('$_protegidos de ${_ambientes.length} protegidos',
                    style: TextStyle(fontSize: 12,
                      color: _protegidos == _ambientes.length
                          ? const Color(0xFF4DB6AC)
                          : const Color(0xFFFFB74D))),
                ],
              ),
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
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: _ambientes.length,
            itemBuilder: (context, index) {
              final ambiente = _ambientes[index];
              final seguro = ambiente['seguro'] as bool;
              final sensores = ambiente['sensores'] as int;

              return GestureDetector(
                onTap: () => _abrirDetalhe(index),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111923),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: seguro
                          ? const Color(0xFF4DB6AC).withValues(alpha: 0.3)
                          : const Color(0xFFFFB74D).withValues(alpha: 0.4),
                      width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(ambiente['icon'] as IconData,
                            size: 26, color: const Color(0xFF4DB6AC)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: seguro
                                  ? const Color(0xFF4DB6AC)
                                      .withValues(alpha: 0.12)
                                  : const Color(0xFFFFB74D)
                                      .withValues(alpha: 0.15),
                            ),
                            child: Text(
                              seguro ? 'Seguro' : 'Atenção',
                              style: TextStyle(fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: seguro
                                    ? const Color(0xFF4DB6AC)
                                    : const Color(0xFFFFB74D))),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(ambiente['nome'] as String,
                        style: const TextStyle(fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE8EAED))),
                      const SizedBox(height: 4),
                      Text(
                        '$sensores sensor${sensores == 1 ? '' : 'es'}',
                        style: const TextStyle(fontSize: 12,
                          color: Color(0xFF6B7D8C))),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}