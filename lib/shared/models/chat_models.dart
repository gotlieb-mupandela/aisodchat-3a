enum ChatMode { online, offline }

class AppConversation {
  AppConversation({
    required this.id,
    required this.userId,
    required this.title,
    required this.mode,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final ChatMode mode;
  final DateTime updatedAt;

  factory AppConversation.fromMap(Map<String, dynamic> map) {
    return AppConversation(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: (map['title'] as String?) ?? 'New Chat',
      mode: (map['mode'] == 'offline') ? ChatMode.offline : ChatMode.online,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class AppMessage {
  AppMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.isOffline = false,
  });

  final String id;
  final String conversationId;
  final String role;
  final String content;
  final DateTime createdAt;
  final bool isOffline;

  factory AppMessage.fromMap(Map<String, dynamic> map) {
    return AppMessage(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      role: map['role'] as String,
      content: (map['content'] as String?) ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      isOffline: (map['is_offline'] as bool?) ?? false,
    );
  }
}
