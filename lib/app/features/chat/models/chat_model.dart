class ChatModel {
  ChatModel({
    required this.uid,
    required this.avatarUrl,
    required this.name,
    this.lastMessage,
    this.draft,
    this.seen = false,
    this.isTyping = false,
    required this.updatedAt,
  });

  factory ChatModel.fromMap(Map<dynamic, dynamic> map) {
    return ChatModel(
      uid: map['uid'],
      avatarUrl: map['avatar_url'],
      name: map['name'],
      lastMessage: map['last_message'],
      seen: map['seen'],
      isTyping: map['isTyping'] ?? false,
      draft: map['draft'],
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  final String uid;
  final String avatarUrl;
  final String name;
  final String? lastMessage;
  final String? draft;
  bool isTyping;
  final bool seen;
  final DateTime updatedAt;

  ChatModel copyWith({
    String? name,
    String? lastMessage,
    bool? seen,
    bool? isTyping,
    DateTime? updatedAt,
  }) {
    return ChatModel(
      uid: uid,
      avatarUrl: avatarUrl,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      seen: seen ?? this.seen,
      draft: draft,
      isTyping: isTyping ?? this.isTyping,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'avatar_url': avatarUrl,
      'name': name,
      'last_message': lastMessage,
      'seen': seen,
      'draft': draft,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return name.toString();
  }
}
