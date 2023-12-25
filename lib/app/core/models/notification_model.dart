class NotificationModel {
  NotificationModel({
    this.id,
    this.title,
    this.subtitle,
    this.image,
    this.updatedAt,
  });

  factory NotificationModel.fromMap(Map<dynamic, dynamic> map) {
    return NotificationModel(
      id: map['id'] as int,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      image: map['image'] as String,
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image': image,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is NotificationModel && other.id == id && other.title == title && other.subtitle == subtitle && other.image == image && other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(id, title);

  final int? id;
  final String? title;
  final String? subtitle;
  final String? image;
  final DateTime? updatedAt;
}
