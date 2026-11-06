// ============================================================
// API CLIENT - SMART HOME GUARDIAN
// Centraliza toda a comunicação com o backend Node.js:
// health, cadastro, login (JWT), ambientes, eventos e sistema
// ============================================================
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb; // detecta se roda no Chrome
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // ===== ENDEREÇO DO BACKEND =====
  // Padrão do curso: celular/emulador conectados por USB com túnel:
  //   adb reverse tcp:3000 tcp:3000
  // → o localhost:3000 do Android chega no backend do notebook via CABO.
  //
  // Override manual (sem túnel — ex.: hotspot do notebook ou backend hospedado):
  //   flutter run --dart-define=API_URL=http://SEU_IP:3000
  static const String _overrideUrl = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_overrideUrl.isNotEmpty) {
      return _overrideUrl;             // endereço forçado na linha de comando
    }
    if (kIsWeb) {
      return 'http://localhost:3000';  // rodando no Chrome do notebook
    }
    return 'http://localhost:3000';    // Android: emulador E celular físico via adb reverse
  }

  // ---------- TOKEN (salvo no aparelho) ----------
  static Future<void> salvarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ===== 7.3 — LOGOUT REAL =====
  // Limpa TUDO que o login salvou: token JWT + nome + email.
  // Assim o splash inteligente (7.2) NÃO loga de volta sozinho.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');         // apaga o JWT
    await prefs.remove('nomeUsuario');   // apaga o nome salvo no login
    await prefs.remove('emailUsuario');  // apaga o email salvo no login
  }

  // ---------- HEADERS (injeta o Bearer token automaticamente) ----------
  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ---------- HEALTH: backend está no ar? ----------
  static Future<bool> backendNoAr() async {
    try {
      final resp = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 3));
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ---------- AUTH ----------
  static Future<Map<String, dynamic>> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/auth/cadastrar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nome': nome, 'email': email, 'senha': senha}),
    );
    final data = jsonDecode(resp.body);
    if (resp.statusCode == 201) return data;
    throw Exception(data['erro'] ?? 'Erro ao cadastrar');
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String senha,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );
    final data = jsonDecode(resp.body);
    if (resp.statusCode == 200) {
      // salva token + dados do usuário no aparelho
      await salvarToken(data['token']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nomeUsuario', data['usuario']['nome']);
      await prefs.setString('emailUsuario', data['usuario']['email']);
      return data;
    }
    throw Exception(data['erro'] ?? 'Credenciais inválidas');
  }

  // ---------- AMBIENTES ----------
  static Future<List<dynamic>> listarAmbientes() async {
    final resp = await http.get(
      Uri.parse('$baseUrl/api/ambientes'),
      headers: await _headers(),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Erro ao listar ambientes (${resp.statusCode})');
  }

  static Future<Map<String, dynamic>> criarAmbiente({required String nome}) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/ambientes'),
      headers: await _headers(),
      body: jsonEncode({'nome': nome}),
    );
    final data = jsonDecode(resp.body);
    if (resp.statusCode == 201) return data;
    throw Exception(data['erro'] ?? 'Erro ao criar ambiente');
  }

  // ---------- EVENTOS ----------
  static Future<List<dynamic>> listarEventos() async {
    final resp = await http.get(
      Uri.parse('$baseUrl/api/eventos'),
      headers: await _headers(),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Erro ao listar eventos (${resp.statusCode})');
  }

  // só os não lidos (pro badge do sino!)
  static Future<List<dynamic>> listarPendentes() async {
    final resp = await http.get(
      Uri.parse('$baseUrl/api/eventos/pendentes'),
      headers: await _headers(),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Erro ao listar pendentes (${resp.statusCode})');
  }

  // o famoso swipe de "marcar como lido"
  static Future<void> marcarComoLido(int id) async {
    final resp = await http.patch(
      Uri.parse('$baseUrl/api/eventos/$id/lido'),
      headers: await _headers(),
    );
    if (resp.statusCode != 200) {
      throw Exception('Erro ao marcar evento como lido (${resp.statusCode})');
    }
  }

  // ===== 7.7 — SISTEMA (armar/desarmar no banco) =====
  // O estado real fica na coluna "armado" do usuário logado.
  // Retorna true se ficou armado, false se ficou desarmado.
  static Future<bool> armarSistema() async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/sistema/armar'),
      headers: await _headers(),
    );
    if (resp.statusCode == 200) return true;
    throw Exception('Erro ao armar o sistema (${resp.statusCode})');
  }

  static Future<bool> desarmarSistema() async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/sistema/desarmar'),
      headers: await _headers(),
    );
    if (resp.statusCode == 200) return false;
    throw Exception('Erro ao desarmar o sistema (${resp.statusCode})');
  }

  // ===== 7.7 — estado atual do sistema (pra Home carregar do banco) =====
  static Future<bool> estadoSistema() async {
    final resp = await http.get(
      Uri.parse('$baseUrl/api/sistema/estado'),
      headers: await _headers(),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data['armado'] == true || data['armado'] == 1;
    }
    throw Exception('Erro ao buscar estado do sistema (${resp.statusCode})');
  }
}