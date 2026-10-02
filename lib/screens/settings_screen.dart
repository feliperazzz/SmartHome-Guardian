import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificacoesPush = true;
  bool _somAlertas = true;
  bool _vibracao = true;
  bool _modoEconomia = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1018),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Configurações',
          style: TextStyle(color: Color(0xFFE8EAED),
            fontSize: 18, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Color(0xFFE8EAED)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _secao('NOTIFICAÇÕES'),
            _toggle('Notificações push', 'Receber alertas do sistema',
                Icons.notifications_active_outlined, _notificacoesPush,
                (v) => setState(() => _notificacoesPush = v)),
            _toggle('Som de alertas', 'Toque ao receber alerta',
                Icons.volume_up_outlined, _somAlertas,
                (v) => setState(() => _somAlertas = v)),
            _toggle('Vibração', 'Vibrar em alertas críticos',
                Icons.vibration_outlined, _vibracao,
                (v) => setState(() => _vibracao = v)),
            const SizedBox(height: 16),
            _secao('SISTEMA'),
            _toggle('Modo economia de dados',
                'Reduz sincronização em segundo plano',
                Icons.data_saver_off_outlined, _modoEconomia,
                (v) => setState(() => _modoEconomia = v)),
            _info('Tema', 'Escuro (padrão)', Icons.dark_mode_outlined),
            _info('Idioma', 'Português (Brasil)', Icons.language_outlined),
            const SizedBox(height: 16),
            _secao('CONEXÃO'),
            _info('Servidor', 'Conectado via WebSocket',
                Icons.cloud_done_outlined),
            _info('Versão do app', 'Smart Home Guardian v1.0',
                Icons.info_outline),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _secao(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Text(titulo,
        style: const TextStyle(fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4DB6AC), letterSpacing: 1)),
    );
  }

  Widget _toggle(String titulo, String subtitulo, IconData icone,
      bool valor, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111923),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2A38), width: 1)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4DB6AC).withValues(alpha: 0.12)),
            child: Icon(icone, size: 20, color: const Color(0xFF4DB6AC)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                  style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w600, color: Color(0xFFE8EAED))),
                const SizedBox(height: 2),
                Text(subtitulo,
                  style: const TextStyle(fontSize: 12,
                    color: Color(0xFF6B7D8C))),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!valor),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: valor
                    ? const Color(0xFF4DB6AC)
                    : const Color(0xFF1E2A38)),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: valor
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(String titulo, String subtitulo, IconData icone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111923),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2A38), width: 1)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4DB6AC).withValues(alpha: 0.12)),
            child: Icon(icone, size: 20, color: const Color(0xFF4DB6AC)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                  style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w600, color: Color(0xFFE8EAED))),
                const SizedBox(height: 2),
                Text(subtitulo,
                  style: const TextStyle(fontSize: 12,
                    color: Color(0xFF6B7D8C))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}