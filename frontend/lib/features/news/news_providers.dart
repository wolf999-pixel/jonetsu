import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/feed_model.dart';
import '../../services/api_service.dart';
import '../auth/auth_providers.dart';

final feedPostsProvider = StateNotifierProvider<FeedPostsNotifier, AsyncValue<List<FeedPost>>>((ref) {
  final user = ref.watch(authNotifierProvider).value;
  return FeedPostsNotifier(user?.id);
});

class FeedPostsNotifier extends StateNotifier<AsyncValue<List<FeedPost>>> {
  final String? currentUserId;

  FeedPostsNotifier(this.currentUserId) : super(const AsyncValue.loading()) {
    loadPosts();
  }

  Future<void> loadPosts() async {
    try {
      final response = await ApiService.dio.get('/news');
      final List<dynamic> data = response.data as List;
      final posts = data.map((json) => FeedPost.fromJson(json as Map<String, dynamic>)).toList();
      state = AsyncValue.data(posts);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> createPost(String content, {List<String>? mediaUrls}) async {
    if (currentUserId == null) return;

    try {
      await ApiService.dio.post('/news', data: {
        'content': content,
        'authorId': currentUserId,
        'mediaUrls': mediaUrls ?? [],
      });
      await loadPosts();
    } catch (e) {
      print('Erreur création post: $e');
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await ApiService.dio.put('/news/like/$postId');
      if (state.hasValue) {
        final currentPosts = state.value!;
        state = AsyncValue.data(
          currentPosts.map<FeedPost>((post) {
            if (post.id == postId) {
              return post.copyWith(
                likesCount: post.likesCount + 1,
                liked: true,
              );
            }
            return post;
          }).toList(),
        );
      }
    } catch (e) {
      print('Erreur like post: $e');
    }
  }
}
