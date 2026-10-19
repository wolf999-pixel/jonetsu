import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/app_colors.dart';
import '../../../features/auth/auth_providers.dart';
import '../../../features/chat/chat_providers.dart';
import '../../../models/chat_model.dart';
import '../../../services/api_service.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoomsAsync = ref.watch(chatRoomsProvider);
    final user = ref.watch(authNotifierProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messagerie OTAKU'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0C29), AppColors.background],
          ),
        ),
        child: chatRoomsAsync.when(
          data: (rooms) => rooms.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => ref.read(chatRoomsProvider.future),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      return _ChatRoomTile(
                          room: room, currentUserId: user?.id ?? '');
                    },
                  ),
                ),
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
          error: (err, _) => Center(
            child: Text('Erreur: $err',
                style: const TextStyle(color: Colors.white54)),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateChatDialog(context, ref, user?.id),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat),
      ),
    );
  }

  void _showCreateChatDialog(BuildContext context, WidgetRef ref, String? userId) {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez vous connecter pour démarrer une discussion !'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    final controller = TextEditingController(text: 'Salon Otaku #${DateTime.now().minute}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16192E),
        title: const Text('Nouveau Salon de Discussion',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nom du groupe / salon',
            labelStyle: TextStyle(color: AppColors.primary),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              try {
                final response = await ApiService.dio.post('/chats', data: {
                  'name': name,
                  'isGroup': true,
                  'members': [{'id': userId}],
                });
                ref.invalidate(chatRoomsProvider);
                if (context.mounted && response.data['id'] != null) {
                  context.push('/chat/${response.data['id']}');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur création salon: $e')),
                  );
                }
              }
            },
            child: const Text('Créer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 20),
          const Text(
            'Aucune conversation',
            style: TextStyle(
                color: Colors.white54,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Commence à discuter avec des Otakus !',
            style: TextStyle(color: Colors.white24, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  final ChatRoom room;
  final String currentUserId;

  const _ChatRoomTile({required this.room, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final displayName = room.getDisplayName(currentUserId);
    final timeStr = room.lastMessageTime != null
        ? DateFormat('HH:mm').format(room.lastMessageTime!)
        : '';

    return ListTile(
      onTap: () => context.push('/chat/${room.id}'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              displayName.isNotEmpty
                  ? displayName[0].toUpperCase()
                  : 'C',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
          if (room.isGroup)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.groups, size: 10, color: Colors.white),
              ),
            ),
        ],
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              displayName,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            timeStr,
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 12,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          room.lastMessage ?? 'Commencer la discussion...',
          style: TextStyle(
            color:
                Colors.white.withOpacity(room.lastMessage == null ? 0.2 : 0.5),
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
