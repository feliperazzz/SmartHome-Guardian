import 'package:flutter/material.dart';
import 'package:mobile/screens/room_detail_screen.dart';
import 'package:mobile/services/system_service.dart';
import 'package:mobile/services/device_service.dart';
import 'package:mobile/services/api_client.dart'; // ===== 7.4: dados reais =====

class RoomsTab extends StatefulWidget {
  const RoomsTab({super.key});

  @override
  State<RoomsTab> createState() => _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab> {
  // ===== DADOS REAIS DO BACKEND =====
  // Antes era uma lista fixa escrita no código. Agora os ambientes
  // vêm do GET /api/ambientes (do banco, vinculados ao usuário logado).
  List<Map<String, dynamic>> _ambientes = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarAmbientes();
  }

  // ===== ÍCONE AUTOMÁTICO PELO NOME DO AMBIENTE =====
  IconData _iconePara(String nome) {
    final n = nome.toLowerCase();
    if (n.contains('sala')) return Icons.weekend_outlined;
    if (n.contains('cozinha')) return Icons.kitchen_outlined;
    if (n.contains('quarto')) return Icons.bed_outlined;
    if (n.contains('garagem')) return Icons.garage_outlined;
    if (n.contains('banheiro') || n.contains('lavabo')) {
      return Icons.bathtub_outlined;
    }
    if (n.contains('escritorio') || n.contains('escritório')) {
      return Icons.computer_outlined;
    }
    if (n.contains('varanda') || n.contains('area') || n.contains('área')) {
      return Icons.deck_outlined;
    }
    return Icons.home_outlined;
  }

  // ===== CARREGAR AMBIENTES DO BACKEND =====
  Future<void> _carregarAmbientes() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final lista = await ApiClient.listarAmbientes();
      final carregados = lista.map((a) {
        final nome = a['nome'] as String? ?? 'Ambiente';
        // Restaura a proteção salva de sessões anteriores (por nome)
        final salvo = DeviceService.instance.ambientesSeguros[nome];
        return {
          'id': a['id'],               // id real do banco
          'nome': nome,
          'icon': _iconePara(nome),
          'seguro': salvo ?? true,     // novo ambiente nasce seguro
          'sensores': 0,               // sensores virão no 7.5+
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _ambientes = carregados;
        _carregando = false;
      });
      _sincronizarHome();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.toString().replaceFirst('Exception: ', '');
        _carregando = false;
      });
    }
  }

  // ===== MANTÉM OS CONTADORES DA HOME EM SINCRONIA =====
  void _sincronizarHome() {
    final totalSensores = _ambientes.fold<int>(
      0, (soma, a) => soma + (a['sensores'] as int));
    SystemService.instance.atualizarSensores(totalSensores);
    SystemService.instance
        .atualizarAmbientes(_ambientes.where((a) => a['seguro'] == true).length);
  }

  // ===== CRIAR AMBIENTE (POST /api/ambientes) =====
  Future<void> _criarAmbiente() async {
    final controller = TextEditingController();

    final criou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111923),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF1E2A38)),
        ),
        title: const Text('Novo ambiente',
          style: TextStyle(fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE8EAED))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Qual ambiente você quer monitorar?',
              style: TextStyle(fontSize: 13, color: Color(0xFF8B9DAB))),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: Color(0xFFE8EAED)),
              decoration: InputDecoration(
                hintText: 'Ex.: Varanda, Escritório...',
                hintStyle: const TextStyle(color: Color(0xFF6B7D8C)),
                filled: true,
                fillColor: const Color(0xFF0A1018),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E2A38))),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E2A38))),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4DB6AC))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
              style: TextStyle(color: Color(0xFF8B9DAB))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Criar',
              style: TextStyle(color: Color(0xFF4DB6AC),
                fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (criou != true || !mounted) return;

    final nome = controller.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um nome para o ambiente')));
      return;
    }

    // impede duplicado na mesma conta
    final jaExiste = _ambientes.any(
      (a) => (a['nome'] as String).toLowerCase() == nome.toLowerCase());
    if (jaExiste) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Você já tem um ambiente "$nome"')));
      return;
    }

    setState(() => _carregando = true); // feedback enquanto salva
    try {
      final novo = await ApiClient.criarAmbiente(nome: nome);
      if (!mounted) return;
      setState(() {
        _ambientes.add({
          'id': novo['id'],
          'nome': nome,
          'icon': _iconePara(nome),
          'seguro': true,
          'sensores': 0,
        });
        _carregando = false;
      });
      _sincronizarHome();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Ambiente "$nome" criado!')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      // ⬅️ 7.6: se aparecer "Token inválido ou expirado" aqui,
      // essa mensagem é a pista que a gente precisava!
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  // ===== ABRIR DETALHE E SINCRONIZAR DE VOLTA =====
  Future<void> _abrirDetalhe(int index) async {
    final ambiente = _ambientes[index];

    final resultado = await Navigator.push<Map>(
      context,
      MaterialPageRoute(
        builder: (context) => RoomDetailScreen(
          nome: ambiente['nome'] as String,
          icon: ambiente['icon'] as IconData,
          seguro: ambiente['seguro'] as bool,
          sensores: ambiente['sensores'] as int,
        ),
      ),
    );

    if (resultado != null && mounted) {
      setState(() {
        ambiente['seguro'] = resultado['seguro'] ?? ambiente['seguro'];
        ambiente['sensores'] = resultado['sensores'] ?? ambiente['sensores'];
      });
      _sincronizarHome();
    }
  }

  int get _protegidos => _ambientes.where((a) => a['seguro'] == true).length;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ===== HEADER =====
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ambientes',
                    style: TextStyle(fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE8EAED))),
                  const SizedBox(height: 2),
                  Text(
                    _carregando
                        ? 'Carregando...'
                        : _erro != null
                            ? 'Erro ao carregar'
                            : '$_protegidos de ${_ambientes.length} protegidos',
                    style: TextStyle(fontSize: 12,
                      color: (_erro == null && _protegidos == _ambientes.length)
                          ? const Color(0xFF4DB6AC)
                          : const Color(0xFFFFB74D))),
                ],
              ),
              // ===== BOTÃO CRIAR =====
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4DB6AC).withValues(alpha: 0.12),
                  border: Border.all(
                    color: const Color(0xFF4DB6AC).withValues(alpha: 0.4)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, size: 22,
                    color: Color(0xFF4DB6AC)),
                  tooltip: 'Criar ambiente',
                  onPressed: _criarAmbiente,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ===== CONTEÚDO =====
        Expanded(
          child: _carregando
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4DB6AC)))
              : _erro != null
                  ? _telaErro()
                  : _ambientes.isEmpty
                      ? _telaVazia()
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: _ambientes.length,
                          itemBuilder: (context, index) {
                            final ambiente = _ambientes[index];
                            final seguro = ambiente['seguro'] as bool;
                            final sensores = ambiente['sensores'] as int;

                            return GestureDetector(
                              onTap: () => _abrirDetalhe(index),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111923),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: seguro
                                        ? const Color(0xFF4DB6AC)
                                            .withValues(alpha: 0.3)
                                        : const Color(0xFFFFB74D)
                                            .withValues(alpha: 0.4),
                                    width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(ambiente['icon'] as IconData,
                                          size: 26,
                                          color: const Color(0xFF4DB6AC)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: seguro
                                                ? const Color(0xFF4DB6AC)
                                                    .withValues(alpha: 0.12)
                                                : const Color(0xFFFFB74D)
                                                    .withValues(alpha: 0.15),
                                          ),
                                          child: Text(
                                            seguro ? 'Seguro' : 'Atenção',
                                            style: TextStyle(fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: seguro
                                                  ? const Color(0xFF4DB6AC)
                                                  : const Color(0xFFFFB74D))),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(ambiente['nome'] as String,
                                      style: const TextStyle(fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFE8EAED))),
                                    const SizedBox(height: 4),
                                    Text(
                                      sensores == 0
                                          ? 'Nenhum sensor ainda'
                                          : '$sensores sensor${sensores == 1 ? '' : 'es'}',
                                      style: const TextStyle(fontSize: 12,
                                        color: Color(0xFF6B7D8C))),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }

  // ===== TELA DE ERRO (backend fora do ar, token expirado...) =====
  Widget _telaErro() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48,
              color: Color(0xFFEF5350)),
            const SizedBox(height: 16),
            Text(_erro ?? 'Erro desconhecido',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13,
                color: Color(0xFF8B9DAB))),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: _carregarAmbientes,
              icon: const Icon(Icons.refresh, color: Color(0xFF4DB6AC)),
              label: const Text('Tentar novamente',
                style: TextStyle(color: Color(0xFF4DB6AC))),
            ),
          ],
        ),
      ),
    );
  }

  // ===== TELA VAZIA (conta nova, nenhum ambiente criado) =====
  Widget _telaVazia() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.grid_view_outlined, size: 48,
            color: Color(0xFF4DB6AC)),
          const SizedBox(height: 16),
          const Text('Nenhum ambiente ainda',
            style: TextStyle(fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE8EAED))),
          const SizedBox(height: 6),
          const Text('Toque no + para criar seu primeiro ambiente',
            style: TextStyle(fontSize: 13, color: Color(0xFF8B9DAB))),
        ],
      ),
    );
  }
}