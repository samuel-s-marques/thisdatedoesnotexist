class Preferences {
  Preferences({
    required this.sexes,
    required this.relationshipGoals,
    required this.politicalViews,
    required this.bodyTypes,
    required this.minAge,
    required this.maxAge,
  });

  factory Preferences.fromMap(Map<String, dynamic> map) {
    return Preferences(
      sexes: List<String>.from(map['sexes'] ?? []),
      relationshipGoals: List<String>.from(map['relationshipGoals'] ?? []),
      politicalViews: List<String>.from(map['politicalViews'] ?? []),
      bodyTypes: List<String>.from(map['bodyTypes'] ?? []),
      minAge: (map['minAge'] ?? 18) as double,
      maxAge: (map['maxAge'] ?? 50) as double,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sexes': sexes,
      'relationshipGoals': relationshipGoals,
      'politicalViews': politicalViews,
      'bodyTypes': bodyTypes,
      'minAge': minAge,
      'maxAge': maxAge,
    };
  }

  final List<String> sexes;
  final List<String> relationshipGoals;
  final List<String> politicalViews;
  final List<String> bodyTypes;
  final double minAge;
  final double maxAge;
}
