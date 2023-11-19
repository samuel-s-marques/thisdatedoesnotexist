class CharacterModel {
  CharacterModel({
    required this.uuid,
    required this.name,
    required this.surname,
    required this.age,
  });

  factory CharacterModel.fromMap(Map<String, dynamic> map) {
    return CharacterModel(
      uuid: map['uuid'],
      name: map['name'],
      surname: map['surname'],
      age: map['age'],
    );
  }

  final String uuid;
  final String name;
  final String surname;
  final int age;

  CharacterModel copyWith({
    String? uuid,
    String? name,
    String? surname,
    int? age,
  }) {
    return CharacterModel(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      age: age ?? this.age,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'surname': surname,
      'age': age,
    };
  }
}
