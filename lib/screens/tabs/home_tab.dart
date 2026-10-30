import 'package:flutter/material.dart';
import 'package:mobile/services/system_service.dart';
import 'package:mobile/services/alerts_service.dart';
import 'package:mobile/services/user_service.dart';
// ===== ALTERAÇÃO: API CLIENT (dados reais do backend) =====
import 'package:mobile/services/api_client.dart';

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

  // ===== ALTERAÇÃO: dados REAIS do backend (antes eram fixos) =====
  List<Map<String, dynamic>> _ambientes = [];
  List<Map<String, dynamic>> _eventos = [];
  bool _carregando = true;
  bool _erroConexao = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  // ===== ALTERAÇÃO PRINCIPAL: carrega ambientes + eventos do banco =====
  Future<void> _carregarDados() async {
    setState(() {
      _carregando = true;
      _erroConexao = false;
    });
    try {
      final ambientes = await ApiClient.listarAmbientes();
      final eventos = await ApiClient.listarEventos();
      final pendentes = await ApiClient.listarPendentes();

      if (!mounted) return;
      setState(() {
        _ambientes = List<Map<String, dynamic>>.from(ambientes);
        _eventos = List<Map<String, dynamic>>.from(eventos);
      });
      // Sincroniza o badge do sino com o banco (dados reais!)
      AlertsService.instance.atualizarNaoLidos(pendentes.length);
    } catch (_) {
      if (!mounted) return;
      setState(() => _erroConexao = true);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  // ===== ALTERAÇÃO: ícone por nome do ambiente (fallback inteligente) =====
  IconData _iconeAmbiente(String nome) {
    final n = nome.toLowerCase();
    if (n.contains('sala')) return Icons.weekend_outlined;
    if (n.contains('cozinha')) return Icons.kitchen_outlined;
    if (n.contains('quarto')) return Icons.bed_outlined;
    if (n.contains('garagem')) return Icons.garage_outlined;
    if (n.contains('quintal') || n.contains('area') || n.contains('área')) {
      return Icons.deck_outlined;
    }
    return Icons.home_outlined;
  }

  // ===== ALTERAÇÃO: ícone por tipo do evento =====
  IconData _iconeEvento(String tipo) {
    final t = tipo.toLowerCase();
    if (t.contains('movimento')) return Icons.directions_walk_outlined;
    if (t.contains('porta')) return Icons.meeting_room_outlined;
    if (t.contains('fumaca') || t.contains('fumaça')) {
      return Icons.smoke_free_outlined;
    }
    return Icons.shield_outlined;
  }

  // ===== ALTERAÇÃO: formata a data do banco ("Hoje, 09:15") =====
  String _formatarData(String? criadoEm) {
    final dt = DateTime.tryParse(criadoEm ?? '');
    if (dt == null) return '';
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final dia = DateTime(dt.year, dt.month, dt.day);
    final hhmm =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (dia == hoje) return 'Hoje, $hhmm';
    if (dia == hoje.subtract(const Duration(days: 1))) return 'Ontem, $hhmm';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}, $hhmm';
  }

  // ===== ALTERAÇÃO: extrai o nome do ambiente do evento (aceita os 2 formatos) =====
  String _nomeAmbienteDoEvento(Map<String, dynamic> ev) {
    final amb = ev['ambiente'];
    if (amb is Map) return (amb['nome'] ?? '').toString();
    return (amb ?? '').toString();
  }

  // ===== ALTERAÇÃO: lê o campo "lido" (aceita 0/1, true/false, "0"/"1") =====
  bool _eventoLido(Map<String, dynamic> ev) {
    final lido = ev['lido'];
    return lido == true || lido == 1 || lido == '1';
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF4DB6AC),
      backgroundColor: const Color(0xFF111923),
      // ===== ALTERAÇÃO: puxar pra baixo recarrega os dados do banco =====
      onRefresh: _carregarDados,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder<String>(
                  valueListenable: UserService.instance.nome,
                  builder: (context, nome, _) {
                    final primeiro = nome.split(' ').first;
                    return Text(
                      'Olá, $primeiro!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE8EAED),
                      ),
                    );
                  },
                ),
                GestureDetector(
                  onTap: widget.onAbrirAlertas,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF111923),
                      border: Border.all(
                        color: const Color(0xFF1E2A38),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      size: 20,
                      color: Color(0xFF4DB6AC),
                    ),
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
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 20,
                        color: Color(0xFFEF5350),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Sem comunicação com a residência',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEF5350),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // ===== ALTERAÇÃO: BANNER DE ERRO DE CONEXÃO COM O SERVIDOR =====
            if (_erroConexao)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF5350).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFEF5350).withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cloud_off_rounded,
                        size: 20, color: Color(0xFFEF5350)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Sem conexão com o servidor — puxe para baixo para tentar de novo',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEF5350),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ===== HERO: SEGURO ↔ VULNERÁVEL (B1) =====
            ValueListenableBuilder<bool>(
              valueListenable: SystemService.instance.sistemaArmado,
              builder: (context, armado, _) {
                final Color cor =
                    armado ? const Color(0xFF4DB6AC) : const Color(0xFFEF5350);
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111923),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: cor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cor.withValues(alpha: 0.15),
                        blurRadius: 16,
                      ),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: armado ? const Color(0xFFE8EAED) : cor,
                        ),
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
                  // Card 2: Alertas Recentes (B5 — agora com dados REAIS do banco)
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
                                width: 1,
                              ),
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
                                const Text(
                                  'Alertas Recentes',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B7D8C),
                                  ),
                                ),
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
                  // Card 4: Controle do Sistema (estado local por enquanto)
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
                              width: 1,
                            ),
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
                                armado
                                    ? 'Sistema Armado'
                                    : 'Sistema Desarmado',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: armado
                                      ? const Color(0xFF4DB6AC)
                                      : const Color(0xFFEF5350),
                                ),
                              ),
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
                const Text(
                  'Ambientes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE8EAED),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onVerTodos,
                  child: const Row(
                    children: [
                      Text(
                        'Ver todos',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4DB6AC),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Color(0xFF4DB6AC),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ===== ALTERAÇÃO: AMBIENTES REAIS DO BANCO =====
            SizedBox(
              height: 110,
              child: _carregando
                  ? const Center(
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          color: Color(0xFF4DB6AC),
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  : _ambientes.isEmpty
                      ? Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF111923),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF1E2A38),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Nenhum ambiente cadastrado ainda',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7D8C),
                            ),
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _ambientes.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final ambiente = _ambientes[index];
                            final nomeAmb =
                                (ambiente['nome'] ?? '').toString();
                            return Container(
                              width: 88,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF111923),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF1E2A38),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    _iconeAmbiente(nomeAmb),
                                    size: 26,
                                    color: const Color(0xFF4DB6AC),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    nomeAmb,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFE8EAED),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF4DB6AC),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 20),

            // ===== NOTIFICAÇÕES RECENTES (B5 — agora do BANCO!) =====
            const Text(
              'Notificações Recentes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE8EAED),
              ),
            ),
            const SizedBox(height: 12),

            if (_carregando)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Color(0xFF4DB6AC),
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              )
            else if (_eventos.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF111923),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1E2A38), width: 1),
                ),
                child: const Text(
                  'Nenhum evento registrado ainda',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7D8C)),
                ),
              )
            else
              // Os 3 eventos mais recentes do banco
              ..._eventos.take(3).map((ev) {
                final titulo = (ev['titulo'] ?? 'Evento').toString();
                final tipo = (ev['tipo'] ?? '').toString();
                final lido = _eventoLido(ev);
                return _buildNotificacao(
                  icone: _iconeEvento(tipo),
                  titulo: titulo,
                  horario: _formatarData(ev['criadoEm'] ?? ev['criado_em']),
                  ambiente: _nomeAmbienteDoEvento(ev),
                  lido: lido,
                );
              }),
          ],
        ),
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
          Text(
            valor,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: cor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            titulo,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7D8C)),
          ),
        ],
      ),
    );
  }

  // ===== ALTERAÇÃO: notificação com dados reais (ambiente + estado lido) =====
  Widget _buildNotificacao({
    required IconData icone,
    required String titulo,
    required String horario,
    required String ambiente,
    required bool lido,
  }) {
    final subtitulo = ambiente.isEmpty ? horario : '$ambiente • $horario';
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lido
                    ? const Color(0xFF1E2A38)
                    : const Color(0xFFFFB74D).withValues(alpha: 0.12),
              ),
              child: Icon(
                icone,
                size: 18,
                color: lido
                    ? const Color(0xFF6B7D8C)
                    : const Color(0xFFFFB74D),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          lido ? FontWeight.w400 : FontWeight.w600,
                      color: lido
                          ? const Color(0xFF8B9DAB)
                          : const Color(0xFFE8EAED),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF6B7D8C)),
                  ),
                ],
              ),
            ),
            if (!lido)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFB74D),
                ),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                size: 16, color: Color(0xFF6B7D8C)),
          ],
        ),
      ),
    );
  }
}