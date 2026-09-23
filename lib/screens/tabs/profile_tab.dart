import 'package:flutter/material.dart';
import 'package:mobile/screens/login_screen.dart';

class ProfileTab extends StatefulWidget {
  final String nome;
  final String email;

  const ProfileTab({
    super.key,
    this.nome = 'Rafael',
    this.email = 'rafael@email.com',
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _notificacoes = true;
  bool _biometria = false;

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111923),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Sair da conta',
          style: TextStyle(color: Color(0xFFE8EAED), fontSize: 18)),
        content: const Text(
            'Deseja realmente sair? Você precisará fazer login novamente.',
          style: TextStyle(color: Color(0xFF8B9DAB), fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
              style: TextStyle(color: Color(0xFF8B9DAB))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Limpa toda a pilha de navegação e volta pro login
              Navigator.of(context, rootNavigator: true)
                  .pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
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
    // Inicial dinâmica: primeira letra do primeiro nome
    final String inicial = widget.nome.isNotEmpty
        ? widget.nome[0].toUpperCase()
        : 'U';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          // ===== HEADER =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Perfil',
                style: TextStyle(fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE8EAED))),
            ],
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
                color: const Color(0xFF4DB6AC).withValues(alpha: 0.2),
                width: 1),
            ),
            child: Column(
              children: [
                // Avatar com inicial dinâmica
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00897B), Color(0xFF4DB6AC)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4DB6AC)
                            .withValues(alpha: 0.25),
                        blurRadius: 12,
                      ),
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
                // Nome dinâmico
                Text(widget.nome,
                  style: const TextStyle(fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE8EAED))),
                const SizedBox(height: 4),
                // E-mail dinâmico
                Text(widget.email,
                  style: const TextStyle(fontSize: 13,
                    color: Color(0xFF8B9DAB))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DB6AC).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Administrador',
                    style: TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4DB6AC))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ===== SEÇÃO: CONFIGURAÇÕES =====
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Configurações',
              style: TextStyle(fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8B9DAB).withValues(alpha: 0.8),
                letterSpacing: 1)),
          ),
          const SizedBox(height: 12),

          _buildConfigTile(
            titulo: 'Notificações',
            subtitulo: 'Alertas em tempo real',
            icon: Icons.notifications_outlined,
            valor: _notificacoes,
            onChanged: (v) => setState(() => _notificacoes = v),
          ),

          _buildConfigTile(
            titulo: 'Biometria',
            subtitulo: 'Entrar usando a digital',
            icon: Icons.fingerprint_outlined,
            valor: _biometria,
            onChanged: (v) => setState(() => _biometria = v),
          ),

          const SizedBox(height: 12),
          _buildActionTile(
            titulo: 'Editar perfil',
            icon: Icons.edit_outlined,
            onTap: () {},
          ),

          const SizedBox(height: 12),
          _buildActionTile(
            titulo: 'Sobre o aplicativo',
            subtitulo: 'Smart Home Guardian v1.0',
            icon: Icons.info_outline,
            onTap: () {},
          ),

          const SizedBox(height: 32),

          // ===== BOTÃO SAIR =====
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFFEF5350).withValues(alpha: 0.1),
                border: Border.all(
                  color: const Color(0xFFEF5350).withValues(alpha: 0.4),
                  width: 1),
              ),
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
  }

  // ===== TILE COM TOGGLE =====
  Widget _buildConfigTile({
    required String titulo,
    required String subtitulo,
    required IconData icon,
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111923),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2A38), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4DB6AC).withValues(alpha: 0.12),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF4DB6AC)),
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
                    : const Color(0xFF1E2A38),
              ),
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
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== TILE DE AÇÃO =====
  Widget _buildActionTile({
    required String titulo,
    required IconData icon,
    String? subtitulo,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111923),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E2A38), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4DB6AC).withValues(alpha: 0.12),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF4DB6AC)),
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
                  if (subtitulo != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitulo,
                      style: const TextStyle(fontSize: 12,
                        color: Color(0xFF6B7D8C))),
                  ],
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
}