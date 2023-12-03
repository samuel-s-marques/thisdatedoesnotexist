class Sex {
  Sex({
    this.id,
    this.name,
  });

  factory Sex.fromMap(Map<String, dynamic> map) {
    return Sex(
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
