import 'user_model.dart';

class ChatRoom {
  final String id;
  final String? name;
  final bool isGroup;
  final List<UserModel> members;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final Map<String, dynamic> metadata;

  ChatRoom({
    required this.id,
    this.name,
    required this.isGroup,
    required this.members,
    this.lastMessage,
    this.lastMessageTime,
    this.metadata = const {},
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString(),
      isGroup: json['isGroup'] == true,
      members: (json['members'] as List?)
              ?.map((m) => UserModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      lastMessage: json['lastMessage']?.toString(),
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.tryParse(json['lastMessageTime'].toString())
          : null,
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : {},
    );
  }

  String getDisplayName(String currentUserId) {
    if (isGroup && name != null && name!.isNotEmpty) return name!;
    final otherMember = members.where((m) => m.id != currentUserId).firstOrNull;
    return otherMember?.displayName ?? otherMember?.username ?? 'Inconnu';
  }
}

class ChatMessage {
  final String id;
  final String roomId;
  final String userId;
  final String username;
  final String content;
  final String messageType;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.username,
    required this.content,
    this.messageType = 'text',
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      roomId: json['chatId']?.toString() ?? json['roomId']?.toString() ?? '',
      userId: json['senderId']?.toString() ?? json['userId']?.toString() ?? '',
      username: json['sender']?['username']?.toString() ?? json['username']?.toString() ?? 'User',
      content: json['content']?.toString() ?? '',
      messageType: json['messageType']?.toString() ?? 'text',
      timestamp: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : (json['timestamp'] != null ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now() : DateTime.now()),
    );
  }
}
