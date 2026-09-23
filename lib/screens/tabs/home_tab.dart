import 'package:flutter/material.dart';
import 'package:mobile/services/system_service.dart';
import 'package:mobile/services/alerts_service.dart';

class HomeTab extends StatefulWidget {
  final String nome;
  final VoidCallback? onVerTodos;
  final VoidCallback? onAbrirAlertas;

  const HomeTab({
    super.key,
    required this.nome,
    this.onVerTodos,
    this.onAbrirAlertas,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String get _primeiroNome => widget.nome.split(' ').first;

  final List<Map<String, dynamic>> _ambientes = const [
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Olá, $_primeiroNome!',
                style: const TextStyle(fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE8EAED))),
              GestureDetector(
                onTap: widget.onAbrirAlertas,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF111923),
                    border: Border.all(
                      color: const Color(0xFF1E2A38), width: 1),
                  ),
                  child: const Icon(Icons.notifications_outlined,
                    size: 20, color: Color(0xFF4DB6AC)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ===== BANNER SEM COMUNICAÇÃO (B2) =====
          ValueListenableBuilder<bool>(
            valueListenable: SystemService.instance.semComunicacao,
            builder: (context, semComunicacao, _) {
              if (!semComunicacao) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF5350).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFEF5350).withValues(alpha: 0.4),
                    width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off_rounded,
                      size: 20, color: Color(0xFFEF5350)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Sem comunicação com a residência',
                        style: TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEF5350))),
                    ),
                  ],
                ),
              );
            },
          ),

          // ===== HERO: SEGURO ↔ VULNERÁVEL (B1) =====
          ValueListenableBuilder<bool>(
            valueListenable: SystemService.instance.sistemaArmado,
            builder: (context, armado, _) {
              final Color cor = armado
                  ? const Color(0xFF4DB6AC)
                  : const Color(0xFFEF5350);
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF111923),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cor.withValues(alpha: 0.4),
                    width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: cor.withValues(alpha: 0.15),
                      blurRadius: 16),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      armado
                          ? Icons.verified_user_outlined
                          : Icons.gpp_bad_outlined,
                      size: 56,
                      color: cor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      armado
                          ? 'Sua residência está segura!'
                          : 'Residência vulnerável',
                      style: TextStyle(fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: armado
                            ? const Color(0xFFE8EAED)
                            : cor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // ===== LINHA 1 DE CARDS =====
          IntrinsicHeight(
            child: Row(
              children: [
                // Card 1: Sensores Ativos (B3)
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: SystemService.instance.sensoresAtivos,
                    builder: (context, sensores, _) {
                      final ativo = sensores > 0;
                      return _buildStatusCard(
                        titulo: 'Sensores Ativos',
                        valor: '$sensores',
                        cor: ativo
                            ? const Color(0xFF4DB6AC)
                            : const Color(0xFF3A4B5C),
                        icone: Icons.sensors_outlined,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Card 2: Alertas Recentes (B5 — interativo)
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: AlertsService.instance.naoLidos,
                    builder: (context, naoLidos, _) {
                      return GestureDetector(
                        onTap: widget.onAbrirAlertas,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111923),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: naoLidos > 0
                                  ? const Color(0xFFFFB74D)
                                      .withValues(alpha: 0.4)
                                  : const Color(0xFF1E2A38),
                              width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                naoLidos > 0
                                    ? Icons.warning_amber_outlined
                                    : Icons.check_circle_outline,
                                size: 22,
                                color: naoLidos > 0
                                    ? const Color(0xFFFFB74D)
                                    : const Color(0xFF4DB6AC),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                naoLidos == 0
                                    ? 'Tudo em ordem'
                                    : '$naoLidos novo${naoLidos > 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: naoLidos > 0
                                      ? const Color(0xFFFFB74D)
                                      : const Color(0xFF4DB6AC),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text('Alertas Recentes',
                                style: TextStyle(fontSize: 11,
                                  color: Color(0xFF6B7D8C))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ===== LINHA 2 DE CARDS =====
          IntrinsicHeight(
            child: Row(
              children: [
                // Card 3: Ambientes Seguros (B3)
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: SystemService.instance.ambientesSeguros,
                    builder: (context, ambientes, _) {
                      final ativo = ambientes > 0;
                      return _buildStatusCard(
                        titulo: 'Ambientes Seguros',
                        valor: '$ambientes',
                        cor: ativo
                            ? const Color(0xFF4DB6AC)
                            : const Color(0xFF3A4B5C),
                        icone: Icons.home_outlined,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Card 4: Controle do Sistema (comanda o estado global)
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: SystemService.instance.sistemaArmado,
                    builder: (context, armado, _) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111923),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: armado
                                ? const Color(0xFF4DB6AC)
                                    .withValues(alpha: 0.4)
                                : const Color(0xFFEF5350)
                                    .withValues(alpha: 0.4),
                            width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              armado
                                  ? Icons.shield_outlined
                                  : Icons.shield_moon_outlined,
                              size: 22,
                              color: armado
                                  ? const Color(0xFF4DB6AC)
                                  : const Color(0xFFEF5350),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                if (armado) {
                                  SystemService.instance.desarmar();
                                } else {
                                  SystemService.instance.armar();
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 44,
                                height: 24,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: armado
                                      ? const Color(0xFF4DB6AC)
                                      : const Color(0xFF1E2A38),
                                ),
                                child: AnimatedAlign(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  alignment: armado
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
                            const SizedBox(height: 6),
                            Text(
                              armado ? 'Sistema Armado' : 'Sistema Desarmado',
                              style: TextStyle(fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: armado
                                    ? const Color(0xFF4DB6AC)
                                    : const Color(0xFFEF5350))),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ===== SEÇÃO AMBIENTES + "VER TODOS" (B4) =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ambientes',
                style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE8EAED))),
              GestureDetector(
                onTap: widget.onVerTodos,
                child: const Row(
                  children: [
                    Text('Ver todos',
                      style: TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4DB6AC))),
                    Icon(Icons.chevron_right, size: 16,
                      color: Color(0xFF4DB6AC)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _ambientes.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final ambiente = _ambientes[index];
                final seguro = ambiente['seguro'] as bool;
                return Container(
                  width: 88,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111923),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF1E2A38), width: 1),
                  ),
                  child: Column(
                    children: [
                      Icon(ambiente['icon'] as IconData,
                        size: 26, color: const Color(0xFF4DB6AC)),
                      const SizedBox(height: 6),
                      Text(ambiente['nome'] as String,
                        style: const TextStyle(fontSize: 12,
                          color: Color(0xFFE8EAED))),
                      const SizedBox(height: 4),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: seguro
                              ? const Color(0xFF4DB6AC)
                              : const Color(0xFFFFB74D),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // ===== NOTIFICAÇÕES RECENTES (B5 — interativas) =====
          const Text('Notificações Recentes',
            style: TextStyle(fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE8EAED))),
          const SizedBox(height: 12),
          _buildNotificacao(
            icone: Icons.meeting_room_outlined,
            titulo: 'Porta da frente aberta',
            horario: 'às 14:32',
          ),
          _buildNotificacao(
            icone: Icons.directions_walk_outlined,
            titulo: 'Movimento detectado - quintal',
            horario: 'às 13:15',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required String titulo,
    required String valor,
    required Color cor,
    required IconData icone,
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
          Icon(icone, size: 22, color: cor),
          const SizedBox(height: 10),
          Text(valor,
            style: TextStyle(fontSize: 20,
              fontWeight: FontWeight.w700, color: cor)),
          const SizedBox(height: 2),
          Text(titulo,
            style: const TextStyle(fontSize: 11,
              color: Color(0xFF6B7D8C))),
        ],
      ),
    );
  }

  Widget _buildNotificacao({
    required IconData icone,
    required String titulo,
    required String horario,
  }) {
    return GestureDetector(
      onTap: widget.onAbrirAlertas,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111923),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E2A38), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1E2A38),
              ),
              child: Icon(icone, size: 18, color: const Color(0xFF4DB6AC)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(titulo,
                style: const TextStyle(fontSize: 13,
                  color: Color(0xFFE8EAED))),
            ),
            Text(horario,
              style: const TextStyle(fontSize: 11,
                color: Color(0xFF6B7D8C))),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 16,
              color: Color(0xFF6B7D8C)),
          ],
        ),
      ),
    );
  }
}