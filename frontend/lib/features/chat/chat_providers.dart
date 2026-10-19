import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/chat_model.dart';
import '../../services/api_service.dart';
import '../../services/socket_service.dart';
import '../auth/auth_providers.dart';

final chatRoomsProvider = FutureProvider<List<ChatRoom>>((ref) async {
  final user = ref.watch(authNotifierProvider).value;
  if (user == null) return [];

  try {
    final response = await ApiService.dio.get('/chats/user/${user.id}');
    return (response.data as List).map((json) => ChatRoom.fromJson(json)).toList();
  } catch (e) {
    print('Error fetching chat rooms: $e');
    return [];
  }
});

final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, List<ChatMessage>, String>((ref, chatId) {
  return ChatMessagesNotifier(chatId);
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final String chatId;
  final SocketService _socketService = SocketService();

  ChatMessagesNotifier(this.chatId) : super([]) {
    _init();
  }

  void _init() {
    _socketService.onMessageReceived((message) {
      if (message.roomId == chatId) {
        // Éviter les doublons si le message vient de nous (déjà ajouté par sendMessage ou API)
        if (!state.any((m) => m.id == message.id)) {
          state = [...state, message];
        }
      }
    });
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final response = await ApiService.dio.get('/messages/chat/$chatId');
      final messages = (response.data as List).map((json) => ChatMessage.fromJson(json)).toList();
      // On inverse pour avoir l'ordre chronologique (l'API renvoie souvent du plus récent au plus ancien)
      state = messages.reversed.toList();
    } catch (e) {
      print('Error loading history: $e');
    }
  }

  void sendMessage(String content, String userId, String username) {
    _socketService.socket.emit('send_message', {
      'roomId': chatId,
      'content': content,
      'senderId': userId,
    });
    
    // On pourrait ajouter le message localement ici pour une UI plus réactive
    // Mais le socket 'message_received' s'en chargera
  }
}
