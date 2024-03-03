import 'package:firebase_auth/firebase_auth.dart';
import 'package:thisdatedoesnotexist/app/core/models/base_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/hobby_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/preferences_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/pronoun_model.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';

class UserModel {
  UserModel({
    required this.uid,
    this.name,
    this.surname,
    this.age,
    this.sex,
    this.bio,
    this.religion,
    this.country,
    this.politicalView,
    this.height,
    this.weight,
    this.pronoun,
    this.occupation,
    this.imageUrl,
    this.lastSwipe,
    this.availableSwipes,
    this.active,
    this.relationshipGoal,
    this.hobbies,
    this.status,
    this.statusReason,
    this.statusUntil,
    this.birthDay,
    this.preferences,
  });

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    final double height = checkDouble(map['height'] ?? 1.6);
    final double weight = checkDouble(map['weight'] ?? 60);

    return UserModel(
      uid: map['uid'],
      name: map['name'],
      surname: map['surname'],
      age: map['age'],
      sex: map['sex'],
      bio: map['bio'],
      religion: map['religion'],
      country: map['country'],
      politicalView: map['political_view'],
      occupation: map['occupation'] != null ? BaseModel.fromMap(map['occupation']) : null,
      height: height,
      weight: weight,
      imageUrl: map['image_url'],
      lastSwipe: map['last_swipe'] != null ? DateTime.parse(map['last_swipe']) : null,
      availableSwipes: map['available_swipes'],
      active: map['active'] != 0,
      relationshipGoal: map['relationship_goal'] != null ? BaseModel.fromMap(map['relationship_goal']) : null,
      pronoun: map['pronoun'] != null ? Pronoun.fromMap(map['pronoun']) : null,
      hobbies: (map['hobbies'] as List<dynamic>?)?.map((hobbyMap) => Hobby.fromMap(hobbyMap)).toList(),
      preferences: map['preferences'] != null ? Preferences.fromMap(map['preferences']) : null,
      status: map['status'],
      statusReason: map['status_reason'],
      birthDay: map['birthday'] != null ? DateTime.parse(map['birthday']) : null,
      statusUntil: map['status_until'] != null ? DateTime.parse(map['status_until']) : null,
    );
  }

  factory UserModel.fromFirebase(User user) {
    return UserModel(
      uid: user.uid,
    );
  }

  UserModel copyWith({
    String? name,
    String? surname,
    int? age,
    String? sex,
    Pronoun? pronoun,
    String? bio,
    String? religion,
    BaseModel? occupation,
    String? country,
    String? politicalView,
    double? height,
    double? weight,
    String? imageUrl,
    int? availableSwipes,
    bool? active,
    String? status,
    String? statusReason,
    DateTime? statusUntil,
    DateTime? lastSwipe,
    DateTime? birthDay,
    BaseModel? relationshipGoal,
    List<Hobby>? hobbies,
    Preferences? preferences,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      pronoun: pronoun ?? this.pronoun,
      bio: bio ?? this.bio,
      religion: religion ?? this.religion,
      occupation: occupation ?? this.occupation,
      country: country ?? this.country,
      politicalView: politicalView ?? this.politicalView,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      imageUrl: imageUrl ?? this.imageUrl,
      availableSwipes: availableSwipes ?? this.availableSwipes,
      active: active ?? this.active,
      status: status ?? this.status,
      statusReason: statusReason ?? this.statusReason,
      birthDay: birthDay ?? this.birthDay,
      statusUntil: statusUntil ?? this.statusUntil,
      lastSwipe: lastSwipe ?? this.lastSwipe,
      relationshipGoal: relationshipGoal ?? this.relationshipGoal,
      hobbies: hobbies ?? this.hobbies,
      preferences: preferences ?? this.preferences,
    );
  }

  final String uid;
  final String? name;
  final String? surname;
  final int? age;
  final String? sex;
  final Pronoun? pronoun;
  final String? bio;
  final String? religion;
  final BaseModel? occupation;
  final String? country;
  final String? politicalView;
  final double? height;
  final double? weight;
  final String? imageUrl;
  final int? availableSwipes;
  final bool? active;
  final String? status;
  final String? statusReason;
  final DateTime? statusUntil;
  final DateTime? lastSwipe;
  final DateTime? birthDay;
  final BaseModel? relationshipGoal;
  final List<Hobby>? hobbies;
  final Preferences? preferences;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'surname': surname,
      'age': age,
      'sex': sex,
      'bio': bio,
      'religion': religion,
      'country': country,
      'political_view': politicalView,
      'occupation': occupation?.toMap(),
      'height': height,
      'weight': weight,
      'pronoun': pronoun?.toMap(),
      'available_swipes': availableSwipes ?? 20,
      'last_swipe': lastSwipe?.toIso8601String(),
      'active': active ?? false,
      'status': status,
      'status_reason': statusReason,
      'birthday': birthDay?.toIso8601String(),
      'status_until': statusUntil?.toIso8601String(),
      'relationship_goal': relationshipGoal?.toMap(),
      'hobbies': hobbies?.map((Hobby hobby) => hobby.toMap()).toList(),
      'preferences': preferences?.toMap(),
    };
  }
}
