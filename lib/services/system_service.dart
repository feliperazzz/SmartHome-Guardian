import 'package:flutter/foundation.dart';

class SystemService {
  SystemService._();
  static final SystemService instance = SystemService._();

  // ===== ESTADO GLOBAL DO SISTEMA =====

  // Sistema armado (true) ou desarmado (false)
  // ===== 7.7: agora começa neutro — o valor REAL vem do banco =====
  final ValueNotifier<bool> sistemaArmado = ValueNotifier<bool>(true);

  // Sem comunicação com a residência (ativa quando desarma)
  final ValueNotifier<bool> semComunicacao = ValueNotifier<bool>(false);

  // Sensores ativos (sem tabela de sensores ainda — 7.7 opção A)
  final ValueNotifier<int> sensoresAtivos = ValueNotifier<int>(0);

  // Ambientes seguros (alimentado pela Home/Ambientes com dados reais)
  final ValueNotifier<int> ambientesSeguros = ValueNotifier<int>(0);

  // ===== AÇÕES =====

  /// Arma o sistema (chamar DEPOIS de confirmar na API)
  void armar() {
    sistemaArmado.value = true;
    semComunicacao.value = false;
  }

  /// Desarma o sistema (chamar DEPOIS de confirmar na API)
  void desarmar() {
    sistemaArmado.value = false;
    semComunicacao.value = true;
  }

  /// ===== 7.7 NOVO: sincroniza o estado vindo do banco =====
  /// (usado ao carregar a Home — o toggle reflete o que está no banco)
  void sincronizarEstado(bool armado) {
    sistemaArmado.value = armado;
    semComunicacao.value = !armado;
  }

  /// Atualiza a contagem de sensores ativos
  void atualizarSensores(int valor) => sensoresAtivos.value = valor;

  /// Atualiza a contagem de ambientes seguros
  void atualizarAmbientes(int valor) => ambientesSeguros.value = valor;

  // ===== RESET (ao sair da conta) =====

  /// Volta ao estado inicial (chamar no logout)
  void reset() {
    sistemaArmado.value = true;
    semComunicacao.value = false;
    sensoresAtivos.value = 0;
    ambientesSeguros.value = 0;
  }
}