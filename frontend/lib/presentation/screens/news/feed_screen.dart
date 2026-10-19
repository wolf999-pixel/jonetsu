import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_colors.dart';
import '../../../features/auth/auth_providers.dart';
import '../../../features/news/news_providers.dart';
import '../../../models/feed_model.dart';
import '../../../shared/glass_container.dart';
import 'package:intl/intl.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(feedPostsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Feed OTAKU'),
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
        child: postsAsync.when(
          data: (posts) => RefreshIndicator(
            onRefresh: () => ref.read(feedPostsProvider.notifier).loadPosts(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: posts.length,
              itemBuilder: (context, index) => _PostCard(post: posts[index]),
            ),
          ),
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
          error: (err, _) => Center(
              child: Text('Erreur: $err',
                  style: const TextStyle(color: Colors.white24))),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final user = ref.read(authNotifierProvider).value;
          _showCreatePostModal(context, ref, user?.id);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau post'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showCreatePostModal(
      BuildContext context, WidgetRef ref, String? userId) {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connectez-vous pour publier un message dans le Feed !'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        opacity: 0.9,
        blur: 25,
        color: const Color(0xFF1A1A2E),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              maxLines: 4,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Quoi de neuf, voyageur ?',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                fillColor: Colors.white.withOpacity(0.05),
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  ref
                      .read(feedPostsProvider.notifier)
                      .createPost(controller.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('PUBLIER'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends ConsumerWidget {
  final FeedPost post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        opacity: 0.05,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: post.userAvatarUrl != null
                      ? NetworkImage(post.userAvatarUrl!)
                      : null,
                  child: post.userAvatarUrl == null
                      ? Text(
                          post.username.isNotEmpty
                              ? post.username[0].toUpperCase()
                              : 'O',
                          style: const TextStyle(
                              color: AppColors.primary, fontSize: 14))
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.username,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      Text(DateFormat('HH:mm').format(post.createdAt),
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.content,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.3)),
            if (post.mediaUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.mediaUrls[0],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 180,
                  errorBuilder: (_, __, ___) => Container(
                      height: 100,
                      color: Colors.white.withOpacity(0.05),
                      child: const Icon(Icons.broken_image,
                          color: Colors.white10)),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _ActionButton(
                  icon: post.liked ? Icons.favorite : Icons.favorite_border,
                  label: '${post.likesCount}',
                  color: post.liked ? AppColors.primary : Colors.white54,
                  onTap: () =>
                      ref.read(feedPostsProvider.notifier).likePost(post.id),
                ),
                const SizedBox(width: 20),
                _ActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: '${post.commentsCount}',
                    color: Colors.white54,
                    onTap: () {}),
                const Spacer(),
                Icon(Icons.share_outlined,
                    color: Colors.white.withOpacity(0.3), size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
