class RelationshipGoal {
  RelationshipGoal({
    this.id,
    this.name,
  });

  factory RelationshipGoal.fromMap(Map<String, dynamic> map) {
    return RelationshipGoal(
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
