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
      relationshipGoals: List<String>.from(map['relationship_goals'] ?? []),
      politicalViews: List<String>.from(map['political_views'] ?? []),
      bodyTypes: List<String>.from(map['body_types'] ?? []),
      minAge: (map['min_age'] ?? 18) as double,
      maxAge: (map['max_age'] ?? 50) as double,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sexes': sexes,
      'relationship_goals': relationshipGoals,
      'political_views': politicalViews,
      'body_types': bodyTypes,
      'min_age': minAge,
      'max_age': maxAge,
    };
  }

  final List<String> sexes;
  final List<String> relationshipGoals;
  final List<String> politicalViews;
  final List<String> bodyTypes;
  final double minAge;
  final double maxAge;
}
