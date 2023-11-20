class Hobby {
  Hobby({
    required this.name,
    required this.type,
  });

  factory Hobby.fromMap(Map<String, dynamic> json) {
    return Hobby(
      name: json['name'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
    };
  }

  final String name;
  final String type;
}
