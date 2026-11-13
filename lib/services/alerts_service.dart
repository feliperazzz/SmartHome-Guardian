import 'package:flutter/foundation.dart';

class AlertsService {
  AlertsService._();
  static final AlertsService instance = AlertsService._();

  /// Eventos do usuário logado. Fonte única para a aba Alertas e o sino.
  final ValueNotifier<List<Map<String, dynamic>>> eventos =
      ValueNotifier<List<Map<String, dynamic>>>(const []);

  /// Quantidade de eventos não lidos (derivada de `eventos`).
  final ValueNotifier<int> naoLidos = ValueNotifier<int>(0);

  /// Substitui a lista inteira (usado ao carregar do banco).
  void atualizarEventos(List<Map<String, dynamic>> novos) {
    eventos.value = List.unmodifiable(novos);
    _recalcular();
  }

  /// Chamar quando chegar 'novo_evento' pelo Socket.io.
  void adicionarEventoTempoReal(Map<String, dynamic> evento) {
    final id = _idDe(evento);
    if (id != null && eventos.value.any((e) => _idDe(e) == id)) return;

    eventos.value = List.unmodifiable([evento, ...eventos.value]);
    _recalcular();
  }

  /// Marca um evento como lido localmente (chamar depois do PATCH no banco).
  void marcarComoLido(dynamic id) {
    final alvo = _toInt(id);
    eventos.value = List.unmodifiable(
      eventos.value.map((e) {
        if (_idDe(e) == alvo) return {...e, 'lido': 1};
        return e;
      }).toList(),
    );
    _recalcular();
  }

  /// Chamar no logout para não mostrar eventos do usuário anterior.
  void limpar() {
    eventos.value = List.unmodifiable(<Map<String, dynamic>>[]);
    naoLidos.value = 0;
  }

  /// Compatibilidade com código antigo que ainda chama este método.
  /// Prefira `atualizarEventos` / `marcarComoLido`.
  @Deprecated('Use atualizarEventos ou marcarComoLido')
  void atualizarNaoLidos(int valor) {
    naoLidos.value = valor;
  }

  void _recalcular() {
    naoLidos.value = eventos.value.where((e) => !_lido(e)).length;
  }

  bool _lido(Map<String, dynamic> e) {
    final v = e['lido'];
    return v == true || v == 1 || v == '1';
  }

  int? _idDe(Map<String, dynamic> e) => _toInt(e['id']);

  int? _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '');
  }
}