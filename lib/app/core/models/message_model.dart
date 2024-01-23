import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_status_enum.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_type_enum.dart';

class Message {
  Message({
    this.id,
    this.text,
    this.type,
    this.sendBy,
    this.status,
    this.createdAt,
  });

  factory Message.fromMap(Map<dynamic, dynamic> json) {
    return Message(
      id: json['id'],
      text: json['text'],
      type: MessageType.values.firstWhere((MessageType type) => type.name == json['type']),
      status: MessageStatus.values.firstWhere((MessageStatus status) => status.name == json['status']),
      sendBy: json['send_by'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'type': type?.name,
      'send_by': sendBy,
      'status': status?.name,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  final String? id;
  final String? text;
  final MessageType? type;
  final String? sendBy;
  final DateTime? createdAt;
  MessageStatus? status;
}
