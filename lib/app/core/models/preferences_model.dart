import 'package:thisdatedoesnotexist/app/core/models/body_type_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/political_view_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/relationship_goal_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/sex_model.dart';

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
    final List<dynamic> sexes = map['sexes'] ?? [];
    final List<dynamic> relationshipGoals = map['relationship_goals'] ?? [];
    final List<dynamic> politicalViews = map['political_views'] ?? [];
    final List<dynamic> bodyTypes = map['body_types'] ?? [];

    return Preferences(
      sexes: sexes.map((sex) => Sex.fromMap(sex)).toList(),
      relationshipGoals: relationshipGoals.map((goal) => RelationshipGoal.fromMap(goal)).toList(),
      politicalViews: politicalViews.map((view) => PoliticalView.fromMap(view)).toList(),
      bodyTypes: bodyTypes.map((type) => BodyType.fromMap(type)).toList(),
      minAge: (map['min_age'] ?? 18) as double,
      maxAge: (map['max_age'] ?? 50) as double,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sexes': sexes.map((sex) => sex.toMap()).toList(),
      'relationship_goals': relationshipGoals.map((goal) => goal.toMap()).toList(),
      'political_views': politicalViews.map((view) => view.toMap()).toList(),
      'body_types': bodyTypes.map((type) => type.toMap()).toList(),
      'min_age': minAge,
      'max_age': maxAge,
    };
  }

  final List<Sex> sexes;
  final List<RelationshipGoal> relationshipGoals;
  final List<PoliticalView> politicalViews;
  final List<BodyType> bodyTypes;
  final double minAge;
  final double maxAge;
}
