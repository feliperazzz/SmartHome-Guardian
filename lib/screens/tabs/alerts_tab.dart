import 'package:flutter/material.dart';
// ===== ALTERAÇÃO: API CLIENT (dados reais) — removido o import antigo do alerts_service =====
import 'package:mobile/services/alerts_service.dart';
import 'package:mobile/services/api_client.dart';

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

  // ===== ALTERAÇÃO: dados REAIS do banco (antes eram mockados) =====
  List<Map<String, dynamic>> _alertas = [];
  bool _carregando = true;
  bool _erroConexao = false;
  // guarda os ids que estão sendo marcados como lido (evita PATCH duplicado)
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

  // ===== ALTERAÇÃO PRINCIPAL: carrega os eventos do banco =====
  Future<void> _carregarAlertas() async {
    setState(() {
      _carregando = true;
      _erroConexao = false;
    });
    try {
      final eventos = await ApiClient.listarEventos();
      if (!mounted) return;
      setState(() {
        _alertas = List<Map<String, dynamic>>.from(eventos);
      });
      _sincronizarBadge();
    } catch (_) {
      if (!mounted) return;
      setState(() => _erroConexao = true);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  // ===== ALTERAÇÃO: badge do sino sempre igual ao banco =====
  void _sincronizarBadge() {
    final pendentes =
        _alertas.where((a) => !_eventoLido(a)).length;
    AlertsService.instance.atualizarNaoLidos(pendentes);
  }

  // ===== ALTERAÇÃO: lê o campo "lido" (aceita 0/1, true/false, "0"/"1") =====
  bool _eventoLido(Map<String, dynamic> ev) {
    final lido = ev['lido'];
    return lido == true || lido == 1 || lido == '1';
  }

  // ===== ALTERAÇÃO: extrai o nome do ambiente (aceita os 2 formatos) =====
  String _nomeAmbiente(Map<String, dynamic> ev) {
    final amb = ev['ambiente'];
    if (amb is Map) return (amb['nome'] ?? '').toString();
    return (amb ?? '').toString();
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

  // ===== ALTERAÇÃO: ícone por tipo do evento =====
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

  // ===== CORREÇÃO: filtra por GRUPOS (antes comparava com a string
  // "seguranca", que não existe no banco → filtro sempre vazio) =====
  List<Map<String, dynamic>> get _alertasFiltrados {
    if (_filtro == 'todos') return _alertas;
    if (_filtro == 'seguranca') {
      return _alertas.where((a) {
        final t = (a['tipo'] ?? '').toString().toLowerCase();
        return t == 'porta_aberta' ||
            t == 'invasao' ||
            t == 'temperatura_elevada';
      }).toList();
    }
    return _alertas
        .where((a) => (a['tipo'] ?? '').toString().toLowerCase() == _filtro)
        .toList();
  }

  int get _naoLidos => _alertas.where((a) => !_eventoLido(a)).length;

  // ===== ALTERAÇÃO PRINCIPAL: marca como lido GRAVANDO NO BANCO =====
  Future<void> _marcarComoLido(Map<String, dynamic> alerta) async {
    final id = alerta['id'];
    if (id == null) return;
    final idInt = id is int ? id : int.tryParse(id.toString());
    if (idInt == null || _eventoLido(alerta)) return;
    if (_marcandoLido.contains(idInt)) return; // já está em andamento

    _marcandoLido.add(idInt);
    try {
      // grava no banco: PATCH /api/eventos/:id/lido
      await ApiClient.marcarComoLido(idInt);
      if (!mounted) return;
      setState(() => alerta['lido'] = 1);
      _sincronizarBadge();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível marcar como lido. Tente novamente.'),
          backgroundColor: Color(0xFF111923),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      _marcandoLido.remove(idInt);
    }
  }

  // ===== ALTERAÇÃO: marca TODOS como lidos, gravando no banco =====
  Future<void> _marcarTodosComoLidos() async {
    final pendentes =
        _alertas.where((a) => !_eventoLido(a)).toList();
    if (pendentes.isEmpty) return;

    setState(() => _carregando = true);
    try {
      for (final alerta in pendentes) {
        final id = alerta['id'];
        final idInt = id is int ? id : int.tryParse(id.toString());
        if (idInt != null) {
          await ApiClient.marcarComoLido(idInt);
          alerta['lido'] = 1;
        }
      }
      if (!mounted) return;
      setState(() {});
      AlertsService.instance.atualizarNaoLidos(0);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alguns alertas não puderam ser marcados.'),
          backgroundColor: Color(0xFF111923),
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _carregarAlertas(); // re-sincroniza com o que o banco realmente tem
    }
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
                    onTap: _marcarTodosComoLidos,
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
            child: _carregando
                ? const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: Color(0xFF4DB6AC),
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : _erroConexao
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off_rounded,
                              size: 40, color: Color(0xFFEF5350)),
                          const SizedBox(height: 12),
                          const Text(
                            'Sem conexão com o servidor',
                            style: TextStyle(
                                color: Color(0xFF8B9DAB), fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _carregarAlertas,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF111923),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF4DB6AC)
                                      .withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: const Text('Tentar novamente',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4DB6AC),
                                )),
                            ),
                          ),
                        ],
                      )
                    : _alertasFiltrados.isEmpty
                        ? const Center(
                            child: Text('Nenhum alerta neste filtro',
                              style: TextStyle(
                                color: Color(0xFF6B7D8C), fontSize: 14)),
                          )
                        : ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount: _alertasFiltrados.length,
                            itemBuilder: (context, index) {
                              final alerta = _alertasFiltrados[index];
                              final lido = _eventoLido(alerta);
                              // ===== BLOCO E: SWIPE PARA MARCAR COMO LIDO =====
                              return Dismissible(
                                key: ObjectKey(alerta),
                                direction: DismissDirection.startToEnd,
                                confirmDismiss: (direction) async {
                                  if (!lido) {
                                    await _marcarComoLido(alerta);
                                  }
                                  return false; // não remove: só marca como lido
                                },
                                background: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4DB6AC)
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.check_circle_outline,
                                      color: Color(0xFF4DB6AC), size: 26),
                                ),
                                child: _buildAlertaCard(
                                  titulo:
                                      (alerta['titulo'] ?? 'Evento').toString(),
                                  ambiente: _nomeAmbiente(alerta),
                                  hora: _formatarData(
                                      alerta['criadoEm'] ??
                                          alerta['criado_em']),
                                  icone: _iconeEvento(
                                      (alerta['tipo'] ?? '').toString()),
                                  lido: lido,
                                  onTap: () => _marcarComoLido(alerta),
                                ),
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
    final subtitulo =
        ambiente.isEmpty ? hora : '$ambiente • $hora';
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
                            color: const Color(0xFFFFB74D)
                                .withValues(alpha: 0.15),
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
                  Text(subtitulo,
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