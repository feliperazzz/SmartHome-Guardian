  import 'package:flutter/material.dart';

  class RoomDetailScreen extends StatefulWidget {
    final String nome;
    final IconData icon;
    final bool seguro;
    final int sensores;

    const RoomDetailScreen({
      super.key,
      required this.nome,
      required this.icon,
      required this.seguro,
      required this.sensores,
    });

    @override
    State<RoomDetailScreen> createState() => _RoomDetailScreenState();
  }

  class _RoomDetailScreenState extends State<RoomDetailScreen> {
    late bool _ambienteSeguro;

    final List<Map<String, dynamic>> _dispositivos = [
      {
        'nome': 'Sensor de movimento',
        'ativo': true,
        'icone': Icons.directions_walk_outlined,
      },
      {
        'nome': 'Sensor de porta',
        'ativo': true,
        'icone': Icons.door_front_door_outlined,
      },
      {
        'nome': 'Sensor de fumaça',
        'ativo': false,
        'icone': Icons.smoke_free_outlined,
      },
      {
        'nome': 'Câmera do ambiente',
        'ativo': true,
        'icone': Icons.videocam_outlined,
      },
    ];

    @override
    void initState() {
      super.initState();
      _ambienteSeguro = widget.seguro;
    }

    @override
    Widget build(BuildContext context) {
      final ativos = _dispositivos.where((d) => d['ativo'] as bool).length;

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
            SafeArea(
              child: Column(
                children: [
                  // ===== APP BAR CUSTOMIZADA =====
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new,
                            color: Color(0xFFE8EAED), size: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(widget.nome,
                          style: const TextStyle(fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE8EAED))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Column(
                        children: [
                          // ===== STATUS HERO =====
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 24, horizontal: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111923),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: _ambienteSeguro
                                    ? const Color(0xFF4DB6AC)
                                        .withValues(alpha: 0.2)
                                    : const Color(0xFFFFB74D)
                                        .withValues(alpha: 0.3),
                                width: 1),
                            ),
                            child: Column(
                              children: [
                                Icon(widget.icon,
                                  size: 48,
                                  color: _ambienteSeguro
                                      ? const Color(0xFF4DB6AC)
                                      : const Color(0xFFFFB74D)),
                                const SizedBox(height: 12),
                                Text(
                                  _ambienteSeguro
                                      ? 'Ambiente protegido!'
                                      : 'Atenção necessária',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _ambienteSeguro
                                        ? const Color(0xFFE8EAED)
                                        : const Color(0xFFFFB74D))),
                                const SizedBox(height: 4),
                                Text(
                                  '$ativos de ${_dispositivos.length} dispositivos ativos',
                                  style: TextStyle(fontSize: 12,
                                    color: const Color(0xFF8B9DAB)
                                        .withValues(alpha: 0.7))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ===== AÇÃO: PROTEÇÃO DO AMBIENTE =====
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111923),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _ambienteSeguro
                                    ? const Color(0xFF4DB6AC)
                                        .withValues(alpha: 0.3)
                                    : const Color(0xFF1E2A38),
                                width: 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.shield_outlined,
                                      size: 20,
                                      color: _ambienteSeguro
                                          ? const Color(0xFF4DB6AC)
                                          : const Color(0xFF8B9DAB)),
                                    const SizedBox(width: 10),
                                    const Text('Proteção do ambiente',
                                      style: TextStyle(fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFE8EAED))),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    _ambienteSeguro = !_ambienteSeguro;
                                  }),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 44,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: _ambienteSeguro
                                          ? const Color(0xFF4DB6AC)
                                          : const Color(0xFF1E2A38),
                                    ),
                                    child: AnimatedAlign(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      alignment: _ambienteSeguro
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
                          ),
                          const SizedBox(height: 20),

                          // ===== LISTA DE DISPOSITIVOS =====
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Dispositivos (${_dispositivos.length})',
                              style: const TextStyle(fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE8EAED))),
                          ),
                          const SizedBox(height: 14),

                          ..._dispositivos.map((d) {
                            final ativo = d['ativo'] as bool;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF111923),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF1E2A38), width: 1),
                              ),
                              child: Row(
                                children: [
                                  // Ícone
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ativo
                                          ? const Color(0xFF4DB6AC)
                                              .withValues(alpha: 0.12)
                                          : const Color(0xFF1E2A38)
                                              .withValues(alpha: 0.5),
                                    ),
                                    child: Icon(d['icone'] as IconData,
                                      size: 22,
                                      color: ativo
                                          ? const Color(0xFF4DB6AC)
                                          : const Color(0xFF6B7D8C)),
                                  ),
                                  const SizedBox(width: 12),

                                  // Textos
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(d['nome'] as String,
                                          style: TextStyle(fontSize: 14,
                                            fontWeight: ativo
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: ativo
                                                ? const Color(0xFFE8EAED)
                                                : const Color(0xFF8B9DAB))),
                                        const SizedBox(height: 2),
                                        Text(ativo
                                            ? 'Operando normalmente'
                                            : 'Inativo',
                                          style: TextStyle(fontSize: 12,
                                            color: ativo
                                                ? const Color(0xFF00E676)
                                                : const Color(0xFF6B7D8C))),
                                      ],
                                    ),
                                  ),

                                  // Toggle de cada dispositivo
                                  GestureDetector(
                                    onTap: () => setState(() {
                                      d['ativo'] = !ativo;
                                    }),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 44,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        color: ativo
                                            ? const Color(0xFF4DB6AC)
                                            : const Color(0xFF1E2A38),
                                      ),
                                      child: AnimatedAlign(
                                        duration: const Duration(
                                            milliseconds: 200),
                                        alignment: ativo
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
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }