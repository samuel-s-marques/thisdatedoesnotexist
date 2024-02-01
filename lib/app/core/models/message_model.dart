import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_from_enum.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_status_enum.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_type_enum.dart';

class Message {
  Message({
    this.id,
    this.content,
    this.from,
    this.type,
    this.sendBy,
    this.status,
    this.location,
    this.duration,
    this.createdAt,
  });

  factory Message.fromMap(Map<dynamic, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      from: MessageFrom.values.firstWhere((MessageFrom from) => from.name == json['from']),
      type: MessageType.values.firstWhere((MessageType type) => type.name == json['type']),
      status: MessageStatus.values.firstWhere((MessageStatus status) => status.name == json['status']),
      location: json['location'],
      duration: json['duration'] != null ? Duration(milliseconds: json['duration']) : null,
      sendBy: json['send_by'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'from': from?.name,
      'type': type?.name,
      'location': location,
      'duration': duration?.inMilliseconds,
      'send_by': sendBy,
      'status': status?.name,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  final String? id;
  final dynamic content;
  final MessageFrom? from;
  final MessageType? type;
  final String? sendBy;
  final DateTime? createdAt;
  final String? location;
  final Duration? duration;
  MessageStatus? status;
}
