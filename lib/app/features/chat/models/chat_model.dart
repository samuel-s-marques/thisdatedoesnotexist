class ChatModel {
  ChatModel({
    required this.name,
    this.lastMessage,
    this.seen = false,
    required this.updatedAt,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      name: map['name'],
      lastMessage: map['last_message'],
      seen: map['seen'],
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

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
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      seen: seen ?? this.seen,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'last_message': lastMessage,
      'seen': seen,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}
