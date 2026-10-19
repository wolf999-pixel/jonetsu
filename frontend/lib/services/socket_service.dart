import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/chat_model.dart';
import 'api_service.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket _socket;
  bool _connected = false;

  factory SocketService() => _instance;
  SocketService._internal();

  bool get connected => _connected;
  IO.Socket get socket => _socket;

  Future<void> connect(String token) async {
    try {
      final serverUrl = ApiService.baseUrl.replaceFirst('/api', '');
      _socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .build(),
      );

      _socket.onConnect((_) {
        _connected = true;
        print('Socket connected');
      });

      _socket.onDisconnect((_) {
        _connected = false;
        print('Socket disconnected');
      });

      _socket.connect();
    } catch (e) {
      print('Socket connection error: $e');
    }
  }

  void disconnect() {
    if (_socket.connected) {
      _socket.disconnect();
      _connected = false;
    }
  }

  void joinRoom(String roomId) => _socket.emit('join_room', {'roomId': roomId});
  void leaveRoom(String roomId) =>
      _socket.emit('leave_room', {'roomId': roomId});
  void sendMessage(String roomId, String content) {
    _socket.emit('send_message', {
      'roomId': roomId,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void onMessageReceived(Function(ChatMessage) callback) {
    _socket.on('message_received', (data) {
      try {
        final message = ChatMessage.fromJson(data as Map<String, dynamic>);
        callback(message);
      } catch (e) {
        print('Error parsing message: $e');
      }
    });
  }

  void dispose() => disconnect();
}
