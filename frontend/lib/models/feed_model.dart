class FeedPost {
  final String id;
  final String userId;
  final String username;
  final String? userAvatarUrl;
  final String content;
  final List<String> mediaUrls;
  final String category;
  final int likesCount;
  final int commentsCount;
  final bool liked;
  final DateTime createdAt;
  final List<String>? tags;

  FeedPost({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatarUrl,
    required this.content,
    required this.mediaUrls,
    this.category = 'news',
    this.likesCount = 0,
    this.commentsCount = 0,
    this.liked = false,
    required this.createdAt,
    this.tags,
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    final usernameRaw = author != null ? (author['displayName'] ?? author['username']) : json['username'];
    
    return FeedPost(
      id: json['id']?.toString() ?? '',
      userId: author != null ? author['id']?.toString() ?? '' : (json['userId']?.toString() ?? ''),
      username: usernameRaw?.toString() ?? 'Otaku',
      userAvatarUrl: author != null ? author['avatarUrl']?.toString() : json['userAvatarUrl']?.toString(),
      content: json['content']?.toString() ?? '',
      mediaUrls: json['mediaUrls'] != null ? List<String>.from(json['mediaUrls'] as List) : [],
      category: json['category']?.toString() ?? 'news',
      likesCount: json['likesCount'] is int ? json['likesCount'] as int : 0,
      commentsCount: json['commentsCount'] is int ? json['commentsCount'] as int : 0,
      liked: json['liked'] == true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
    );
  }

  FeedPost copyWith({int? likesCount, bool? liked}) {
    return FeedPost(
      id: id, userId: userId, username: username, userAvatarUrl: userAvatarUrl,
      content: content, mediaUrls: mediaUrls, category: category,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount, liked: liked ?? this.liked,
      createdAt: createdAt, tags: tags,
    );
  }
}
