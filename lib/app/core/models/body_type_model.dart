class BodyType {
  BodyType({
    this.id,
    this.name,
  });

  factory BodyType.fromMap(Map<String, dynamic> map) {
    return BodyType(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  final int? id;
  final String? name;
}