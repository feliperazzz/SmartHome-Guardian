import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:mobile/services/alerts_service.dart';
=======
>>>>>>> 3f01e8d6dcced2c2092341912116da1b2675cc18

class AlertsTab extends StatefulWidget {
  const AlertsTab({super.key});

  @override
  State<AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<AlertsTab>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _headerOpacity;
  late Animation<double> _listOpacity;

  String _filtro = 'todos';

  // ===== DADOS MOCKADOS =====
  final List<Map<String, dynamic>> _alertas = [
    {
      'titulo': 'Porta aberta',
      'ambiente': 'Garagem',
      'hora': 'Hoje, 09:15',
      'tipo': 'seguranca',
      'lido': false,
      'icone': Icons.door_front_door_outlined,
    },
    {
      'titulo': 'Movimento detectado',
      'ambiente': 'Quintal',
      'hora': 'Hoje, 08:42',
      'tipo': 'movimento',
      'lido': false,
      'icone': Icons.directions_walk_outlined,
    },
    {
      'titulo': 'Sensor de fumaça verificado',
      'ambiente': 'Cozinha',
      'hora': 'Ontem, 21:30',
      'tipo': 'seguranca',
      'lido': true,
      'icone': Icons.smoke_free_outlined,
    },
    {
      'titulo': 'Movimento detectado',
      'ambiente': 'Sala',
      'hora': 'Ontem, 18:05',
      'tipo': 'movimento',
      'lido': true,
      'icone': Icons.directions_walk_outlined,
    },
    {
      'titulo': 'Porta aberta',
      'ambiente': 'Quarto 2',
      'hora': 'Ontem, 14:50',
      'tipo': 'seguranca',
      'lido': true,
      'icone': Icons.door_front_door_outlined,
    },
  ];

  List<Map<String, dynamic>> get _alertasFiltrados {
    if (_filtro == 'todos') return _alertas;
    return _alertas.where((a) => a['tipo'] == _filtro).toList();
  }

  int get _naoLidos => _alertas.where((a) => !(a['lido'] as bool)).length;

  void _marcarComoLido(int indexFiltrado) {
    final alerta = _alertasFiltrados[indexFiltrado];
    final originalIndex = _alertas.indexOf(alerta);
    setState(() => _alertas[originalIndex]['lido'] = true);
<<<<<<< HEAD
    // Sincroniza com o card da Home
    AlertsService.instance.atualizarNaoLidos(_naoLidos);
=======
>>>>>>> 3f01e8d6dcced2c2092341912116da1b2675cc18
  }

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
=======

>>>>>>> 3f01e8d6dcced2c2092341912116da1b2675cc18
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
<<<<<<< HEAD
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _listOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
=======
      CurvedAnimation(parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );

    _listOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
>>>>>>> 3f01e8d6dcced2c2092341912116da1b2675cc18
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ===== HEADER =====
        FadeTransition(
          opacity: _headerOpacity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Alertas',
                      style: TextStyle(fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE8EAED))),
                    const SizedBox(height: 2),
                    Text(_naoLidos > 0
                        ? '$_naoLidos não lidos'
                        : 'Tudo em ordem',
                      style: TextStyle(fontSize: 12,
                        color: _naoLidos > 0
                            ? const Color(0xFFFFB74D)
                            : const Color(0xFF4DB6AC))),
                  ],
                ),
                if (_naoLidos > 0)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        for (var alerta in _alertas) {
                          alerta['lido'] = true;
                        }
                      });
<<<<<<< HEAD
                      // Sincroniza com o card da Home
                      AlertsService.instance.atualizarNaoLidos(0);
=======
>>>>>>> 3f01e8d6dcced2c2092341912116da1b2675cc18
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111923),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF1E2A38), width: 1),
                      ),
                      child: const Text('Marcar todos como lidos',
                        style: TextStyle(fontSize: 11,
                          color: Color(0xFF4DB6AC))),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ===== FILTROS =====
        FadeTransition(
          opacity: _headerOpacity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildFiltroChip(label: 'Todos', value: 'todos'),
                const SizedBox(width: 8),
                _buildFiltroChip(label: 'Segurança', value: 'seguranca'),
                const SizedBox(width: 8),
                _buildFiltroChip(label: 'Movimento', value: 'movimento'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ===== LISTA DE ALERTAS =====
        Expanded(
          child: FadeTransition(
            opacity: _listOpacity,
            child: _alertasFiltrados.isEmpty
                ? const Center(
                    child: Text('Nenhum alerta neste filtro',
<<<<<<< HEAD
                      style: TextStyle(
                        color: Color(0xFF6B7D8C), fontSize: 14)),
=======
                      style: TextStyle(color: Color(0xFF6B7D8C), fontSize: 14)),
>>>>>>> 3f01e8d6dcced2c2092341912116da1b2675cc18
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: _alertasFiltrados.length,
                    itemBuilder: (context, index) {
                      final alerta = _alertasFiltrados[index];
                      return _buildAlertaCard(
                        titulo: alerta['titulo'] as String,
                        ambiente: alerta['ambiente'] as String,
                        hora: alerta['hora'] as String,
                        icone: alerta['icone'] as IconData,
                        lido: alerta['lido'] as bool,
                        onTap: () => _marcarComoLido(index),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  // ===== CHIP DE FILTRO =====
  Widget _buildFiltroChip({
    required String label,
    required String value,
  }) {
    final isSelected = _filtro == value;
    return GestureDetector(
      onTap: () => setState(() => _filtro = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4DB6AC)
              : const Color(0xFF111923),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4DB6AC)
                : const Color(0xFF1E2A38),
            width: 1),
        ),
        child: Text(label,
          style: TextStyle(fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? const Color(0xFF0A1018)
                : const Color(0xFF8B9DAB))),
      ),
    );
  }

  // ===== CARD DE ALERTA =====
  Widget _buildAlertaCard({
    required String titulo,
    required String ambiente,
    required String hora,
    required IconData icone,
    required bool lido,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: lido ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111923),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: !lido
                ? const Color(0xFFFFB74D).withValues(alpha: 0.4)
                : const Color(0xFF1E2A38),
            width: 1),
        ),
        child: Row(
          children: [
            // Ícone
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: !lido
                    ? const Color(0xFFFFB74D).withValues(alpha: 0.12)
                    : const Color(0xFF1E2A38).withValues(alpha: 0.5),
              ),
              child: Icon(icone, size: 22,
                color: !lido
                    ? const Color(0xFFFFB74D)
                    : const Color(0xFF6B7D8C)),
            ),
            const SizedBox(width: 12),

            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(titulo,
                          style: TextStyle(fontSize: 14,
                            fontWeight: lido
                                ? FontWeight.w400
                                : FontWeight.w600,
                            color: lido
                                ? const Color(0xFF8B9DAB)
                                : const Color(0xFFE8EAED))),
                      ),
                      if (!lido)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
<<<<<<< HEAD
                            color: const Color(0xFFFFB74D)
                                .withValues(alpha: 0.15),
=======
                            color: const Color(0xFFFFB74D).withValues(alpha: 0.15),
>>>>>>> 3f01e8d6dcced2c2092341912116da1b2675cc18
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('NOVO',
                            style: TextStyle(fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFFB74D))),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('$ambiente • $hora',
                    style: const TextStyle(fontSize: 12,
                      color: Color(0xFF6B7D8C))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}