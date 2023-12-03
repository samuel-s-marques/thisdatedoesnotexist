class PoliticalView {
  PoliticalView({
    this.id,
    this.name,
  });

  factory PoliticalView.fromMap(Map<String, dynamic> map) {
    return PoliticalView(
      id: map['id'],
      name: map['name'],
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
