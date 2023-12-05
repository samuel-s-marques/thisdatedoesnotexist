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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is BodyType && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);

  final int? id;
  final String? name;
}
