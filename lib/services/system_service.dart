import 'package:flutter/foundation.dart';

class SystemService {
  SystemService._();
  static final SystemService instance = SystemService._();

  // ===== ESTADO GLOBAL DO SISTEMA =====

  // Sistema armado (true) ou desarmado (false)
  final ValueNotifier<bool> sistemaArmado = ValueNotifier<bool>(true);

  // Sem comunicação com a residência (ativa quando desarma)
  final ValueNotifier<bool> semComunicacao = ValueNotifier<bool>(false);

  // Sensores ativos (0 quando desarmado)
  final ValueNotifier<int> sensoresAtivos = ValueNotifier<int>(5);

  // Ambientes seguros (0 quando desarmado)
  final ValueNotifier<int> ambientesSeguros = ValueNotifier<int>(5);

  // ===== AÇÕES =====

  /// Arma o sistema: tudo volta ao estado de proteção total
  void armar() {
    sistemaArmado.value = true;
    semComunicacao.value = false;
    sensoresAtivos.value = 5;
    ambientesSeguros.value = 5;
  }

  /// Desarma o sistema: tudo cai pra zero e perde comunicação
  void desarmar() {
    sistemaArmado.value = false;
    semComunicacao.value = true;
    sensoresAtivos.value = 0;
    ambientesSeguros.value = 0;
  }

  /// Atualiza a contagem de sensores ativos (usado ao cadastrar/remover sensores)
  void atualizarSensores(int valor) => sensoresAtivos.value = valor;

  /// Atualiza a contagem de ambientes seguros (usado pela aba Ambientes)
  void atualizarAmbientes(int valor) => ambientesSeguros.value = valor;

  // ===== RESET (ao sair da conta) =====

  /// Volta tudo ao estado inicial (chamar no logout)
  void reset() {
    armar();
  }
}