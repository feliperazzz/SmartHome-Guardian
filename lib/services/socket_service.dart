// ============================================================
// SOCKET SERVICE - SMART HOME GUARDIAN
// Conexão em tempo real com o backend via Socket.io:
// recebe eventos de segurança no instante em que acontecem
// ============================================================
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:mobile/services/api_client.dart';
import 'package:mobile/services/alerts_service.dart';

class SocketService {
  SocketService._();
  static final SocketService instance = SocketService._();

  io.Socket? _socket;
  bool _conectado = false;

  // ⚠️ CONFIRA NO BACKEND o nome exato do evento emitido
  // (procure no server.js por algo como: io.emit('novo_evento', ...))
  static const String nomeEvento = 'novo_evento';

  // Callback que a dashboard vai preencher (mostra o aviso na tela)
  void Function(Map<String, dynamic> evento)? onNovoEvento;

  bool get conectado => _conectado;

  // ---------- CONECTAR (com o token JWT do login) ----------
  Future<void> conectar() async {
    if (_conectado) return;
    final token = await ApiClient.getToken();
    if (token == null) return; // sem login = sem escutar a casa

    _socket = io.io(
      ApiClient.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token}) // envia o JWT na conexão
          .enableReconnection()      // caiu? reconecta sozinho (nome correto da API)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) {
      _conectado = true;
    });

    _socket!.onDisconnect((_) {
      _conectado = false;
    });

    // ---------- O CORAÇÃO DA ETAPA: evento chegando ao vivo ----------
    _socket!.on(nomeEvento, (data) {
      try {
        final Map<String, dynamic> evento =
            Map<String, dynamic>.from(data as Map);

        // Sobe o badge do sino na hora (Home + card de alertas)
        final atual = AlertsService.instance.naoLidos.value;
        AlertsService.instance.atualizarNaoLidos(atual + 1);

        // Avisa a interface (a dashboard mostra o SnackBar)
        onNovoEvento?.call(evento);
      } catch (_) {
        // payload inesperado — ignora sem quebrar o app
      }
    });
  }

  // ---------- DESCONECTAR (logout) ----------
  void desconectar() {
    _socket?.dispose();
    _socket = null;
    _conectado = false;
  }
}