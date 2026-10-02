import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceService {
  DeviceService._();
  static final DeviceService instance = DeviceService._();

  // ===== ESTADO DOS DISPOSITIVOS =====
  // nome, tipo, ambiente, ativo
  final ValueNotifier<List<Map<String, dynamic>>> dispositivos =
      ValueNotifier<List<Map<String, dynamic>>>([
    {'nome': 'Sensor de Fumaça', 'tipo': 'fumaca', 'ambiente': 'Cozinha', 'ativo': true},
    {'nome': 'Sensor de Movimento', 'tipo': 'movimento', 'ambiente': 'Sala', 'ativo': true},
    {'nome': 'Sensor de Porta', 'tipo': 'porta', 'ambiente': 'Garagem', 'ativo': true},
    {'nome': 'Câmera Frontal', 'tipo': 'camera', 'ambiente': 'Sala', 'ativo': true},
    {'nome': 'Câmera Quintal', 'tipo': 'camera', 'ambiente': 'Quintal', 'ativo': false},
  ]);

  // ===== PROTEÇÃO POR AMBIENTE (persistida) =====
  final Map<String, bool> ambientesSeguros = {};

  void definirSeguroAmbiente(String nome, bool seguro) {
    ambientesSeguros[nome] = seguro;
    salvar();
  }

  int get totalAtivos =>
      dispositivos.value.where((d) => d['ativo'] == true).length;

  void alternarDispositivo(int index) {
    final lista = List<Map<String, dynamic>>.from(dispositivos.value);
    lista[index]['ativo'] = !(lista[index]['ativo'] as bool);
    dispositivos.value = lista;
    salvar();
  }

  void removerDispositivo(Map<String, dynamic> dispositivo) {
    final lista = List<Map<String, dynamic>>.from(dispositivos.value);
    lista.remove(dispositivo);
    dispositivos.value = lista;
    salvar();
  }

  void adicionarDispositivo({
    required String nome,
    required String tipo,
    required String ambiente,
  }) {
    final lista = List<Map<String, dynamic>>.from(dispositivos.value);
    lista.add({
      'nome': nome,
      'tipo': tipo,
      'ambiente': ambiente,
      'ativo': true,
    });
    dispositivos.value = lista;
    salvar();
  }

  // ===== PERSISTÊNCIA =====
  Future<void> carregar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dados = prefs.getString('dispositivos_shg');
      if (dados != null && dados.isNotEmpty) {
        dispositivos.value =
            List<Map<String, dynamic>>.from(_decodificar(dados));
      }
      // Carrega a proteção salva por ambiente
      final seg = prefs.getString('ambientes_seguros_shg');
      if (seg != null && seg.isNotEmpty) {
        for (final item in seg.split(';;')) {
          final p = item.split('|');
          if (p.length == 2) ambientesSeguros[p[0]] = p[1] == 'true';
        }
      }
    } catch (e) {
      // Se falhar o carregamento, mantém os dados padrão em memória
      debugPrint('DeviceService: falha ao carregar - $e');
    }
  }

  Future<void> salvar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'dispositivos_shg', _codificar(dispositivos.value));
      // Salva também a proteção por ambiente
      final segStr = ambientesSeguros.entries
          .map((e) => '${e.key}|${e.value}')
          .join(';;');
      await prefs.setString('ambientes_seguros_shg', segStr);
    } catch (e) {
      debugPrint('DeviceService: falha ao salvar - $e');
    }
  }

  // ===== SERIALIZAÇÃO SIMPLES (sem dependência extra) =====
  String _codificar(List<Map<String, dynamic>> lista) {
    return lista
        .map((d) =>
            '${d['nome']}|${d['tipo']}|${d['ambiente']}|${d['ativo']}')
        .join(';;');
  }

  List<Map<String, dynamic>> _decodificar(String dados) {
    return dados.split(';;').map((item) {
      final p = item.split('|');
      return {
        'nome': p[0],
        'tipo': p[1],
        'ambiente': p[2],
        'ativo': p[3] == 'true',
      };
    }).toList();
  }
}