class CharacterModel {
  CharacterModel({
    required this.uid,
    required this.name,
    required this.surname,
    required this.age,
  });

  factory CharacterModel.fromMap(Map<String, dynamic> map) {
    return CharacterModel(
      uid: map['uid'],
      name: map['name'],
      surname: map['surname'],
      age: map['age'],
    );
  }

  final String uid;
  final String name;
  final String surname;
  final int age;

  CharacterModel copyWith({
    String? uid,
    String? name,
    String? surname,
    int? age,
  }) {
    return CharacterModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      age: age ?? this.age,
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
