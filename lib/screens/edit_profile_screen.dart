import 'package:flutter/material.dart';
import 'package:mobile/services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nomeController;
  late final TextEditingController _emailController;
  String? _nomeError;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: UserService.instance.nome.value);
    _emailController = TextEditingController(text: UserService.instance.email.value);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _salvar() {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();

    setState(() {
      _nomeError = null;
      _emailError = null;
    });

    if (nome.isEmpty || nome.length < 3) {
      setState(() => _nomeError = 'Informe um nome válido');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _emailError = 'Informe um e-mail válido');
      return;
    }

    UserService.instance.atualizar(novoNome: nome, novoEmail: email);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Perfil atualizado com sucesso!'),
        backgroundColor: const Color(0xFF4DB6AC),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context);
  }

  InputDecoration _decoracao(String hint, IconData icone, String? erro) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF5A6B7A), fontSize: 14),
      errorText: erro,
      errorStyle: const TextStyle(color: Color(0xFFEF5350), fontSize: 12),
      filled: true,
      fillColor: const Color(0xFF111923),
      prefixIcon: Icon(icone, size: 20, color: const Color(0xFF4DB6AC)),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1E2A38), width: 1)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1E2A38), width: 1)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4DB6AC), width: 1.5)),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1)),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1018),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Editar perfil',
          style: TextStyle(color: Color(0xFFE8EAED),
            fontSize: 18, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Color(0xFFE8EAED)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00897B), Color(0xFF4DB6AC)]),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4DB6AC).withValues(alpha: 0.25),
                    blurRadius: 12),
                ],
              ),
              child: const Center(
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _nomeController,
              style: const TextStyle(color: Color(0xFFE8EAED), fontSize: 15),
              decoration: _decoracao(
                  'Nome completo', Icons.person_outline, _nomeError),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Color(0xFFE8EAED), fontSize: 15),
              decoration: _decoracao('E-mail', Icons.email_outlined, _emailError),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00897B), Color(0xFF4DB6AC)]),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _salvar,
                    child: const Center(
                      child: Text('SALVAR ALTERAÇÕES',
                        style: TextStyle(color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}