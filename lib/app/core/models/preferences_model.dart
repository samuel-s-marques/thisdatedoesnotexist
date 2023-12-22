import 'package:thisdatedoesnotexist/app/core/models/base_model.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';

class Preferences {
  Preferences({
    required this.sexes,
    required this.relationshipGoals,
    required this.politicalViews,
    required this.bodyTypes,
    required this.religions,
    required this.minAge,
    required this.maxAge,
  });

  factory Preferences.fromMap(Map<dynamic, dynamic> map) {
    final List<dynamic> sexes = map['sexes'] ?? [];
    final List<dynamic> relationshipGoals = map['relationship_goals'] ?? [];
    final List<dynamic> politicalViews = map['political_views'] ?? [];
    final List<dynamic> bodyTypes = map['body_types'] ?? [];
    final List<dynamic> religions = map['religions'] ?? [];
    final double minAge = checkDouble(map['min_age'] ?? 18);
    final double maxAge = checkDouble(map['max_age'] ?? 70);

    return Preferences(
      sexes: sexes.map((sex) => BaseModel.fromMap(sex)).toList(),
      relationshipGoals: relationshipGoals.map((goal) => BaseModel.fromMap(goal)).toList(),
      politicalViews: politicalViews.map((view) => BaseModel.fromMap(view)).toList(),
      bodyTypes: bodyTypes.map((type) => BaseModel.fromMap(type)).toList(),
      religions: religions.map((religion) => BaseModel.fromMap(religion)).toList(),
      minAge: minAge,
      maxAge: maxAge,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sexes': sexes.map((sex) => sex.toMap()).toList(),
      'relationship_goals': relationshipGoals.map((goal) => goal.toMap()).toList(),
      'political_views': politicalViews.map((view) => view.toMap()).toList(),
      'body_types': bodyTypes.map((type) => type.toMap()).toList(),
      'religions': religions.map((religion) => religion.toMap()).toList(),
      'min_age': minAge,
      'max_age': maxAge,
    };
  }

  final List<BaseModel> sexes;
  final List<BaseModel> relationshipGoals;
  final List<BaseModel> politicalViews;
  final List<BaseModel> bodyTypes;
  final List<BaseModel> religions;
  final double minAge;
  final double maxAge;
}
