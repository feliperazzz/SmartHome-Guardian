import 'package:flutter/material.dart';
import 'package:mobile/services/alerts_service.dart';
import 'package:mobile/services/api_client.dart';

class AlertsTab extends StatefulWidget {
  const AlertsTab({super.key});

  @override
  State<AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<AlertsTab>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _headerOpacity;
  late final Animation<double> _listOpacity;

  String _filtro = 'todos';
  bool _carregando = true;
  bool _erroConexao = false;

  // ids em andamento, para evitar PATCH duplicado
  final Set<int> _marcandoLido = {};

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
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
    );

    _carregarAlertas();
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  // ===================== CARREGAMENTO =====================

  Future<void> _carregarAlertas({bool mostrarLoading = true}) async {
    if (mostrarLoading && mounted) {
      setState(() {
        _carregando = true;
        _erroConexao = false;
      });
    }

    try {
      final bruto = await ApiClient.listarEventos();
      final lista = _normalizarLista(bruto);
      if (!mounted) return;

      AlertsService.instance.atualizarEventos(lista);
      setState(() => _erroConexao = false);
    } catch (e, s) {
      debugPrint('ALERTAS ERRO AO CARREGAR: $e');
      debugPrint('$s');
      if (!mounted) return;
      setState(() => _erroConexao = true);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  // Aceita List direta ou Map com a lista dentro
  List<Map<String, dynamic>> _normalizarLista(dynamic bruto) {
    List<dynamic> itens;

    if (bruto is List) {
      itens = bruto;
    } else if (bruto is Map && bruto['eventos'] is List) {
      itens = bruto['eventos'] as List;
    } else if (bruto is Map && bruto['data'] is List) {
      itens = bruto['data'] as List;
    } else {
      throw FormatException('Formato inesperado: ${bruto.runtimeType}');
    }

    return itens
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // ===================== HELPERS =====================

  int? _idDe(Map<String, dynamic> ev) {
    final id = ev['id'];
    if (id is int) return id;
    return int.tryParse(id?.toString() ?? '');
  }

  bool _eventoLido(Map<String, dynamic> ev) {
    final lido = ev['lido'];
    return lido == true || lido == 1 || lido == '1';
  }

  String _nomeAmbiente(Map<String, dynamic> ev) {
    final amb = ev['ambiente'];
    if (amb is Map) return (amb['nome'] ?? '').toString();
    return (amb ?? '').toString();
  }

  // Converte UTC do banco para horário local antes de formatar
  String _formatarData(String? criadoEm) {
    final dt = DateTime.tryParse(criadoEm ?? '')?.toLocal();
    if (dt == null) return '';

    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final dia = DateTime(dt.year, dt.month, dt.day);
    final hhmm =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    if (dia == hoje) return 'Hoje, $hhmm';
    if (dia == hoje.subtract(const Duration(days: 1))) return 'Ontem, $hhmm';

    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}, $hhmm';
  }

  IconData _iconeEvento(String tipo) {
    final t = tipo.toLowerCase();
    if (t.contains('movimento')) return Icons.directions_walk_outlined;
    if (t.contains('porta')) return Icons.meeting_room_outlined;
    if (t.contains('invasao') || t.contains('invasão')) {
      return Icons.gpp_bad_outlined;
    }
    if (t.contains('temperatura')) return Icons.device_thermostat_outlined;
    if (t.contains('fumaca') || t.contains('fumaça')) {
      return Icons.smoke_free_outlined;
    }
    return Icons.shield_outlined;
  }

  List<Map<String, dynamic>> _filtrarLista(List<Map<String, dynamic>> lista) {
    if (_filtro == 'todos') return lista;

    if (_filtro == 'seguranca') {
      return lista.where((a) {
        final t = (a['tipo'] ?? '').toString().toLowerCase();
        return t == 'porta_aberta' ||
            t == 'invasao' ||
            t == 'temperatura_elevada';
      }).toList();
    }

    if (_filtro == 'movimento') {
      return lista.where((a) {
        final t = (a['tipo'] ?? '').toString().toLowerCase();
        return t.contains('movimento');
      }).toList();
    }

    return lista;
  }

  // ===================== AÇÕES =====================

  Future<void> _marcarComoLido(Map<String, dynamic> alerta) async {
    final id = _idDe(alerta);
    if (id == null || _eventoLido(alerta)) return;
    if (_marcandoLido.contains(id)) return;

    _marcandoLido.add(id);
    try {
      await ApiClient.marcarComoLido(id);
      AlertsService.instance.marcarComoLido(id);
    } catch (e) {
      debugPrint('ALERTAS ERRO AO MARCAR LIDO: $e');
      if (!mounted) return;
      _mostrarSnack('Não foi possível marcar como lido. Tente novamente.');
    } finally {
      _marcandoLido.remove(id);
    }
  }

  Future<void> _marcarTodosComoLidos(List<Map<String, dynamic>> lista) async {
    final pendentes = lista.where((a) => !_eventoLido(a)).toList();
    for (final alerta in pendentes) {
      await _marcarComoLido(alerta);
    }
  }

  void _mostrarSnack(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: const Color(0xFF111923),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===================== BUILD =====================

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: AlertsService.instance.eventos,
      builder: (context, todos, _) {
        final naoLidos = todos.where((a) => !_eventoLido(a)).length;
        final filtrados = _filtrarLista(todos);

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
                        const Text(
                          'Alertas',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE8EAED),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          naoLidos > 0
                              ? '$naoLidos não lidos'
                              : 'Tudo em ordem',
                          style: TextStyle(
                            fontSize: 12,
                            color: naoLidos > 0
                                ? const Color(0xFFFFB74D)
                                : const Color(0xFF4DB6AC),
                          ),
                        ),
                      ],
                    ),
                    if (naoLidos > 0)
                      GestureDetector(
                        onTap: () => _marcarTodosComoLidos(todos),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111923),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF1E2A38),
                            ),
                          ),
                          child: const Text(
                            'Marcar todos como lidos',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF4DB6AC),
                            ),
                          ),
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

            // ===== LISTA =====
            Expanded(
              child: FadeTransition(
                opacity: _listOpacity,
                child: _conteudo(todos, filtrados),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _conteudo(
    List<Map<String, dynamic>> todos,
    List<Map<String, dynamic>> filtrados,
  ) {
    // Primeiro carregamento, ainda sem dados
    if (_carregando && todos.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            color: Color(0xFF4DB6AC),
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    // Erro sem nenhum dado em memória
    if (_erroConexao && todos.isEmpty) {
      return _buildErro();
    }

    return RefreshIndicator(
      color: const Color(0xFF4DB6AC),
      onRefresh: () => _carregarAlertas(mostrarLoading: false),
      child: filtrados.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(
                  child: Text(
                    'Nenhum alerta neste filtro',
                    style: TextStyle(
                      color: Color(0xFF6B7D8C),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: filtrados.length,
              itemBuilder: (context, index) {
                final alerta = filtrados[index];
                final lido = _eventoLido(alerta);
                final id = _idDe(alerta);

                return Dismissible(
                  key: ValueKey('alerta-${id ?? index}'),
                  direction: DismissDirection.startToEnd,
                  confirmDismiss: (_) async {
                    if (!lido) await _marcarComoLido(alerta);
                    return false; // não remove, só marca como lido
                  },
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4DB6AC).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF4DB6AC),
                      size: 26,
                    ),
                  ),
                  child: _buildAlertaCard(
                    titulo: (alerta['titulo'] ?? 'Evento').toString(),
                    ambiente: _nomeAmbiente(alerta),
                    hora: _formatarData(
                      (alerta['criadoEm'] ?? alerta['criado_em'])?.toString(),
                    ),
                    icone: _iconeEvento((alerta['tipo'] ?? '').toString()),
                    lido: lido,
                    onTap: () => _marcarComoLido(alerta),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildErro() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.cloud_off_rounded,
          size: 40,
          color: Color(0xFFEF5350),
        ),
        const SizedBox(height: 12),
        const Text(
          'Sem conexão com o servidor',
          style: TextStyle(color: Color(0xFF8B9DAB), fontSize: 14),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _carregarAlertas(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF111923),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4DB6AC).withValues(alpha: 0.4),
              ),
            ),
            child: const Text(
              'Tentar novamente',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4DB6AC),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===================== CHIP DE FILTRO =====================

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
          color: isSelected ? const Color(0xFF4DB6AC) : const Color(0xFF111923),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4DB6AC) : const Color(0xFF1E2A38),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? const Color(0xFF0A1018)
                : const Color(0xFF8B9DAB),
          ),
        ),
      ),
    );
  }

  // ===================== CARD DE ALERTA =====================

  Widget _buildAlertaCard({
    required String titulo,
    required String ambiente,
    required String hora,
    required IconData icone,
    required bool lido,
    required VoidCallback onTap,
  }) {
    final subtitulo = ambiente.isEmpty ? hora : '$ambiente • $hora';

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
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: !lido
                    ? const Color(0xFFFFB74D).withValues(alpha: 0.12)
                    : const Color(0xFF1E2A38).withValues(alpha: 0.5),
              ),
              child: Icon(
                icone,
                size: 22,
                color: !lido ? const Color(0xFFFFB74D) : const Color(0xFF6B7D8C),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          titulo,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                lido ? FontWeight.w400 : FontWeight.w600,
                            color: lido
                                ? const Color(0xFF8B9DAB)
                                : const Color(0xFFE8EAED),
                          ),
                        ),
                      ),
                      if (!lido)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB74D)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'NOVO',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFFB74D),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7D8C),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}