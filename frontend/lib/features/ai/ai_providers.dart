import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../auth/auth_providers.dart';

class AiMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  AiMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

final aiChatProvider = StateNotifierProvider<AiChatNotifier, List<AiMessage>>((ref) {
  final user = ref.watch(authNotifierProvider).value;
  return AiChatNotifier(user?.id);
});

class AiChatNotifier extends StateNotifier<List<AiMessage>> {
  final String? userId;

  AiChatNotifier(this.userId) : super([
    AiMessage(
      content: "Système AKIRA activé. Bonjour voyageur ! Je suis AKIRA, ton assistante Otaku. Comment puis-je t'aider dans le JŌNETSU-verse aujourd'hui ?",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ]);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String prompt) async {
    if (prompt.trim().isEmpty) return;

    final userMessage = AiMessage(
      content: prompt,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = [...state, userMessage];
    _isLoading = true;

    try {
      final response = await ApiService.dio.post('/ai/chat', data: {
        'prompt': prompt,
        'userId': userId,
      });
      final aiContent = response.data['response'] as String;

      final aiMessage = AiMessage(
        content: aiContent,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = [...state, aiMessage];
    } catch (e) {
      state = [...state, AiMessage(
        content: "Erreur de connexion à la matrice AKIRA. Vérifie ta connexion réseau.",
        isUser: false,
        timestamp: DateTime.now(),
      )];
    } finally {
      _isLoading = false;
    }
  }
}
