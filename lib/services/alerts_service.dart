import 'package:flutter/foundation.dart';

class AlertsService {
  AlertsService._();
  static final AlertsService instance = AlertsService._();

  // Começa com 2 não lidos (mesmo valor inicial da aba Alertas)
  final ValueNotifier<int> naoLidos = ValueNotifier<int>(2);

  void atualizarNaoLidos(int valor) {
    naoLidos.value = valor;
  }
}