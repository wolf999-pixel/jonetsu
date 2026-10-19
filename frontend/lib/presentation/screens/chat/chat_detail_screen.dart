import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/app_colors.dart';
import '../../../features/auth/auth_providers.dart';
import '../../../features/chat/chat_providers.dart';
import '../../../models/chat_model.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatDetailScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    ref.read(chatMessagesProvider(widget.chatId).notifier).sendMessage(
          content,
          user.id,
          user.username,
        );

    _messageController.clear();
    // Petit délai pour laisser l'UI se mettre à jour avant de scroller
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider(widget.chatId));
    final user = ref.watch(authNotifierProvider).value;
    final chatRoomsAsync = ref.watch(chatRoomsProvider);

    final roomDetails =
        chatRoomsAsync.value?.where((r) => r.id == widget.chatId).firstOrNull;
    final chatName =
        roomDetails?.getDisplayName(user?.id ?? '') ?? 'Chargement...';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Hero(
              tag: 'avatar_${widget.chatId}',
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(chatName[0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chatName,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(
                    roomDetails?.isGroup == true
                        ? '${roomDetails?.members.length} membres'
                        : 'En ligne',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.primary.withOpacity(0.8))),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.videocam_outlined, color: Colors.white70),
              onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white70),
              onPressed: () {}),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0C29), AppColors.background],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isMe = message.userId == user?.id;
                  // On affiche le header seulement si l'expéditeur change
                  final showHeader = index == 0 ||
                      messages[index - 1].userId != message.userId;

                  return _MessageBubble(
                    message: message,
                    isMe: isMe,
                    showHeader: showHeader,
                  );
                },
              ),
            ),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.add, color: AppColors.primary),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Écris ton message...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary,
                        blurRadius: 10,
                        spreadRadius: -2)
                  ],
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool showHeader;

  const _MessageBubble(
      {required this.message, required this.isMe, required this.showHeader});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (showHeader && !isMe)
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 4, top: 12),
            child: Text(
              message.username,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.neonBlue,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5),
            ),
          ),
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin:
                EdgeInsets.only(bottom: 6, top: isMe && showHeader ? 12 : 0),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isMe
                  ? AppColors.primary.withOpacity(0.9)
                  : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(22).copyWith(
                bottomRight:
                    isMe ? const Radius.circular(4) : const Radius.circular(22),
                bottomLeft:
                    isMe ? const Radius.circular(22) : const Radius.circular(4),
              ),
              border: isMe
                  ? null
                  : Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                      color:
                          isMe ? Colors.white : Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      height: 1.3),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(message.timestamp),
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.3), fontSize: 9),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.done_all,
                          size: 12, color: Colors.white.withOpacity(0.3)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
