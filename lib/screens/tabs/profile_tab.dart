import 'package:flutter/material.dart';
import 'package:mobile/screens/login_screen.dart';
import 'package:mobile/screens/edit_profile_screen.dart';
import 'package:mobile/screens/settings_screen.dart';
import 'package:mobile/services/user_service.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _notificacoes = true;
  bool _biometria = false;

  void _logout() {
    UserService.instance.reset();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text(
            'Deseja realmente sair? Você precisará fazer login novamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
              style: TextStyle(color: Color(0xFF8B9DAB))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context, rootNavigator: true)
                  .pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Sair',
              style: TextStyle(color: Color(0xFFEF5350))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: UserService.instance.nome,
      builder: (context, nome, _) {
        return ValueListenableBuilder<String>(
          valueListenable: UserService.instance.email,
          builder: (context, email, _) {
            final String inicial =
                nome.isNotEmpty ? nome[0].toUpperCase() : 'U';

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  // ===== HEADER =====
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Perfil',
                      style: TextStyle(fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE8EAED))),
                  ),
                  const SizedBox(height: 24),

                  // ===== CARD DO USUÁRIO =====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111923),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF4DB6AC)
                            .withValues(alpha: 0.2), width: 1)),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF00897B),
                                Color(0xFF4DB6AC)
                              ]),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4DB6AC)
                                    .withValues(alpha: 0.25),
                                blurRadius: 12),
                            ],
                          ),
                          child: Center(
                            child: Text(inicial,
                              style: const TextStyle(fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(nome,
                          style: const TextStyle(fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE8EAED))),
                        const SizedBox(height: 4),
                        Text(email,
                          style: const TextStyle(fontSize: 13,
                            color: Color(0xFF8B9DAB))),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4DB6AC)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10)),
                          child: const Text('Administrador',
                            style: TextStyle(fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4DB6AC))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ===== CONFIGURAÇÕES =====
                  _secao('Configurações'),
                  _toggle('Notificações', 'Alertas em tempo real',
                      Icons.notifications_outlined, _notificacoes,
                      (v) => setState(() => _notificacoes = v)),
                  _toggle('Biometria', 'Entrar usando a digital',
                      Icons.fingerprint_outlined, _biometria,
                      (v) => setState(() => _biometria = v)),
                  _acao('Editar perfil', 'Nome, e-mail e avatar',
                      Icons.edit_outlined, () async {
                    await Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) => const EditProfileScreen()));
                  }),
                  _acao('Configurações do app', 'Preferências e aparência',
                      Icons.settings_outlined, () {
                    Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()));
                  }),
                  _acao('Sobre o aplicativo', 'Smart Home Guardian v1.0',
                      Icons.info_outline, () {}),
                  const SizedBox(height: 24),

                  // ===== HISTÓRICO =====
                  _secao('Histórico'),
                  _historicoDia('Hoje', [
                    ['Sistema armado', '09:12', Icons.shield_outlined],
                    ['Sensor de fumaça verificado - Cozinha', '08:47',
                        Icons.smoke_free_outlined],
                  ]),
                  _historicoDia('Ontem', [
                    ['Movimento detectado - Quintal', '22:15',
                        Icons.directions_walk_outlined],
                    ['Porta da frente aberta', '19:03',
                        Icons.meeting_room_outlined],
                    ['Proteção da Garagem ativada', '14:20',
                        Icons.shield_outlined],
                  ]),
                  _historicoDia('23 de setembro', [
                    ['Sistema desarmado manualmente', '21:40',
                        Icons.shield_moon_outlined],
                    ['Novo sensor cadastrado - Sala', '18:05',
                        Icons.sensors_outlined],
                  ]),
                  const SizedBox(height: 32),

                  // ===== SAIR =====
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: const Color(0xFFEF5350)
                            .withValues(alpha: 0.1),
                        border: Border.all(
                          color: const Color(0xFFEF5350)
                              .withValues(alpha: 0.4), width: 1)),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _logout,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, size: 20,
                                  color: Color(0xFFEF5350)),
                              SizedBox(width: 10),
                              Text('Sair da conta',
                                style: TextStyle(fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFEF5350))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _secao(String titulo) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(titulo,
          style: TextStyle(fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8B9DAB).withValues(alpha: 0.8),
            letterSpacing: 1)),
      ),
    );
  }

  Widget _toggle(String titulo, String subtitulo, IconData icone,
      bool valor, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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

  Widget _acao(String titulo, String subtitulo, IconData icone,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE8EAED))),
                  const SizedBox(height: 2),
                  Text(subtitulo,
                    style: const TextStyle(fontSize: 12,
                      color: Color(0xFF6B7D8C))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20,
                color: Color(0xFF6B7D8C)),
          ],
        ),
      ),
    );
  }

  Widget _historicoDia(
      String dia, List<List<dynamic>> eventos) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111923),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2A38), width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dia,
            style: const TextStyle(fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4DB6AC), letterSpacing: 0.5)),
          const SizedBox(height: 10),
          ...eventos.map((evento) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFF1E2A38)),
                    child: Icon(evento[2] as IconData,
                        size: 16, color: const Color(0xFF4DB6AC)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(evento[0] as String,
                      style: const TextStyle(fontSize: 13,
                        color: Color(0xFFE8EAED))),
                  ),
                  Text(evento[1] as String,
                    style: const TextStyle(fontSize: 11,
                      color: Color(0xFF6B7D8C))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}