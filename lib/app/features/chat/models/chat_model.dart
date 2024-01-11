class ChatModel {
  ChatModel({
    required this.uid,
    required this.avatarUrl,
    required this.name,
    this.lastMessage,
    this.seen = false,
    required this.updatedAt,
  });

  factory ChatModel.fromMap(Map<dynamic, dynamic> map) {
    return ChatModel(
      uid: map['uid'],
      avatarUrl: map['avatar_url'],
      name: map['name'],
      lastMessage: map['last_message'],
      seen: map['seen'],
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  final String uid;
  final String avatarUrl;
  final String name;
  final String? lastMessage;
  final bool seen;
  final DateTime updatedAt;

  ChatModel copyWith({
    String? name,
    String? lastMessage,
    bool? seen,
    DateTime? updatedAt,
  }) {
    return ChatModel(
      uid: uid,
      avatarUrl: avatarUrl,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      seen: seen ?? this.seen,
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
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}
