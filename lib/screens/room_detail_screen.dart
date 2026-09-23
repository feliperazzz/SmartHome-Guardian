import 'package:flutter/material.dart';
import 'package:mobile/services/system_service.dart';

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

  // ===== DISPOSITIVOS DO AMBIENTE =====
  final List<Map<String, dynamic>> _dispositivos = [];

  @override
  void initState() {
    super.initState();
    _ambienteSeguro = widget.seguro;

    // Gera a lista inicial de dispositivos baseada no total de sensores
    final tiposPadrao = [
      {'nome': 'Câmera', 'icone': Icons.videocam_outlined},
      {'nome': 'Sensor de fumaça', 'icone': Icons.smoke_free_outlined},
      {'nome': 'Sensor de movimento', 'icone': Icons.directions_walk_outlined},
    ];
    for (int i = 0; i < widget.sensores; i++) {
      final tipo = tiposPadrao[i % tiposPadrao.length];
      _dispositivos.add({
        'nome': tipo['nome'] as String,
        'icone': tipo['icone'] as IconData,
        'ativo': true,
      });
    }
  }

  // ===== ADICIONAR NOVO SENSOR (C3) =====
  void _adicionarSensor() {
    final controller = TextEditingController();
    final tipos = [
      {'nome': 'Câmera', 'icone': Icons.videocam_outlined},
      {'nome': 'Sensor de fumaça', 'icone': Icons.smoke_free_outlined},
      {'nome': 'Sensor de movimento', 'icone': Icons.directions_walk_outlined},
      {'nome': 'Sensor de porta', 'icone': Icons.door_sliding_outlined},
      {'nome': 'Sensor de janela', 'icone': Icons.window_outlined},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111923),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        int tipoSelecionado = 0;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Adicionar sensor',
                    style: TextStyle(fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE8EAED))),
                  const SizedBox(height: 4),
                  const Text('Escolha o tipo do novo sensor',
                    style: TextStyle(fontSize: 13,
                      color: Color(0xFF8B9DAB))),
                  const SizedBox(height: 16),
                  // Campo de nome personalizado
                  TextField(
                    controller: controller,
                    style: const TextStyle(color: Color(0xFFE8EAED),
                      fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Nome do sensor (opcional)',
                      hintStyle: const TextStyle(
                        color: Color(0xFF5A6B7A), fontSize: 14),
                      prefixIcon: const Icon(Icons.sensors_outlined,
                        size: 20, color: Color(0xFF4DB6AC)),
                      filled: true,
                      fillColor: const Color(0xFF0A1018),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF1E2A38), width: 1)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF1E2A38), width: 1)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF4DB6AC), width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Seleção de tipo
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: tipos.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final selecionado = tipoSelecionado == index;
                        return GestureDetector(
                          onTap: () =>
                              setModalState(() => tipoSelecionado = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: selecionado
                                  ? const Color(0xFF4DB6AC)
                                  : const Color(0xFF1E2A38),
                            ),
                            child: Row(
                              children: [
                                Icon(tipos[index]['icone'] as IconData,
                                  size: 16,
                                  color: selecionado
                                      ? const Color(0xFF0A1018)
                                      : const Color(0xFF8B9DAB)),
                                const SizedBox(width: 6),
                                Text(tipos[index]['nome'] as String,
                                  style: TextStyle(fontSize: 12,
                                    color: selecionado
                                        ? const Color(0xFF0A1018)
                                        : const Color(0xFF8B9DAB))),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Botão confirmar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF00897B),
                            Color(0xFF4DB6AC),
                          ],
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            final nomeTipado = controller.text.trim();
                            Navigator.pop(context, {
                              'nome': nomeTipado.isNotEmpty
                                  ? nomeTipado
                                  : tipos[tipoSelecionado]['nome'] as String,
                              'icone': tipos[tipoSelecionado]['icone'],
                            });
                          },
                          child: const Center(
                            child: Text('ADICIONAR SENSOR',
                              style: TextStyle(color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    ).then((resultado) {
      if (resultado != null && resultado is Map) {
        setState(() {
          _dispositivos.add({
            'nome': resultado['nome'] as String,
            'icone': resultado['icone'] as IconData,
            'ativo': true,
          });
        });
      }
    });
  }

  // ===== REMOVER SENSOR =====
  void _removerSensor(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111923),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Remover sensor',
          style: TextStyle(color: Color(0xFFE8EAED), fontSize: 18)),
        content: Text(
            'Remover "${_dispositivos[index]['nome']}" deste ambiente?',
          style: const TextStyle(color: Color(0xFF8B9DAB), fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
              style: TextStyle(color: Color(0xFF8B9DAB))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _dispositivos.removeAt(index));
            },
            child: const Text('Remover',
              style: TextStyle(color: Color(0xFFEF5350))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int ativos =
        _dispositivos.where((d) => d['ativo'] == true).length;

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
                // ===== HEADER =====
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(8, 8, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context, {
                          'seguro': _ambienteSeguro,
                          'sensores': _dispositivos.length,
                        }),
                        icon: const Icon(Icons.arrow_back_ios_new,
                          color: Color(0xFFE8EAED), size: 20),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              const Color(0xFF4DB6AC).withValues(alpha: 0.12),
                        ),
                        child: Icon(widget.icon,
                          size: 22, color: const Color(0xFF4DB6AC)),
                      ),
                      const SizedBox(width: 10),
                      Text(widget.nome,
                        style: const TextStyle(fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE8EAED))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        // ===== HERO DO AMBIENTE =====
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111923),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _ambienteSeguro
                                  ? const Color(0xFF4DB6AC)
                                      .withValues(alpha: 0.4)
                                  : const Color(0xFFFFB74D)
                                      .withValues(alpha: 0.4),
                              width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: _ambienteSeguro
                                    ? const Color(0xFF4DB6AC)
                                        .withValues(alpha: 0.15)
                                    : const Color(0xFFFFB74D)
                                        .withValues(alpha: 0.15),
                                blurRadius: 16),
                            ],
                          ),
                          child: Column(
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  _ambienteSeguro
                                      ? Icons.verified_user_outlined
                                      : Icons.warning_amber_outlined,
                                  key: ValueKey(_ambienteSeguro),
                                  size: 56,
                                  color: _ambienteSeguro
                                      ? const Color(0xFF4DB6AC)
                                      : const Color(0xFFFFB74D),
                                ),
                              ),
                              const SizedBox(height: 12),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  _ambienteSeguro
                                      ? 'Ambiente protegido!'
                                      : 'Atenção neste ambiente',
                                  key: ValueKey(_ambienteSeguro),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _ambienteSeguro
                                        ? const Color(0xFFE8EAED)
                                        : const Color(0xFFFFB74D),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$ativos de ${_dispositivos.length} dispositivos ativos',
                                style: const TextStyle(fontSize: 12,
                                  color: Color(0xFF8B9DAB)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ===== TOGGLE PROTEÇÃO DO AMBIENTE (C1 CORRIGIDO) =====
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111923),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF1E2A38), width: 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF4DB6AC)
                                      .withValues(alpha: 0.12),
                                ),
                                child: const Icon(Icons.shield_outlined,
                                  size: 20, color: Color(0xFF4DB6AC)),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Proteção do ambiente',
                                      style: TextStyle(fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFE8EAED))),
                                    SizedBox(height: 2),
                                    Text(
                                        'Monitoramento ativo neste comodo',
                                      style: TextStyle(fontSize: 12,
                                        color: Color(0xFF6B7D8C))),
                                  ],
                                ),
                              ),
                              // ===== TOGGLE CORRIGIDO =====
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _ambienteSeguro = !_ambienteSeguro;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  width: 44,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(12),
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
                        const SizedBox(height: 16),

                        // ===== TÍTULO DISPOSITIVOS + ADICIONAR (C3) =====
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Dispositivos',
                              style: TextStyle(fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE8EAED))),
                            GestureDetector(
                              onTap: _adicionarSensor,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color(0xFF4DB6AC)
                                      .withValues(alpha: 0.12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.add, size: 16,
                                      color: Color(0xFF4DB6AC)),
                                    SizedBox(width: 4),
                                    Text('Adicionar',
                                      style: TextStyle(fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF4DB6AC))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ===== LISTA DE DISPOSITIVOS (C2 CORRIGIDO) =====
                        ..._dispositivos.asMap().entries.map((entry) {
                          final index = entry.key;
                          final dispositivo = entry.value;
                          final ativo = dispositivo['ativo'] as bool;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111923),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF1E2A38), width: 1),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ativo
                                        ? const Color(0xFF4DB6AC)
                                            .withValues(alpha: 0.12)
                                        : const Color(0xFF1E2A38),
                                  ),
                                  child: Icon(
                                      dispositivo['icone'] as IconData,
                                    size: 20,
                                    color: ativo
                                        ? const Color(0xFF4DB6AC)
                                        : const Color(0xFF6B7D8C)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          dispositivo['nome'] as String,
                                        style: TextStyle(fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: ativo
                                              ? const Color(0xFFE8EAED)
                                              : const Color(0xFF8B9DAB))),
                                      const SizedBox(height: 2),
                                      Text(
                                          ativo
                                              ? 'Ativo'
                                              : 'Desativado',
                                        style: TextStyle(fontSize: 12,
                                          color: ativo
                                              ? const Color(0xFF4DB6AC)
                                              : const Color(0xFF6B7D8C))),
                                    ],
                                  ),
                                ),
                                // Ícone de remover
                                GestureDetector(
                                  onTap: () => _removerSensor(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(Icons.delete_outline,
                                      size: 18,
                                      color: Color(0xFF6B7D8C)),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // ===== TOGGLE DO DISPOSITIVO (CORRIGIDO) =====
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      dispositivo['ativo'] = !ativo;
                                    });
                                  },
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
                                        margin:
                                            const EdgeInsets.all(2),
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

                        const SizedBox(height: 8),
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