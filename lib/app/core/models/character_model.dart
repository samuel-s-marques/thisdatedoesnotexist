class CharacterModel {
  CharacterModel({
    required this.uid,
    required this.name,
    required this.surname,
    required this.age,
    required this.updatedAt,
  });

  factory CharacterModel.fromMap(Map<String, dynamic> map) {
    return CharacterModel(
      uid: map['uid'],
      name: map['name'],
      surname: map['surname'],
      age: map['age'],
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  final String uid;
  final String name;
  final String surname;
  final int age;
  final DateTime updatedAt;

  CharacterModel copyWith({
    String? uid,
    String? name,
    String? surname,
    int? age,
    DateTime? updatedAt,
  }) {
    return CharacterModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      age: age ?? this.age,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'surname': surname,
      'age': age,
    };
  }
}
