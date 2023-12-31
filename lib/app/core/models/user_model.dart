import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thisdatedoesnotexist/app/core/models/base_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/hobby_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/preferences_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/pronoun_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';
import 'package:thisdatedoesnotexist/app/core/services/dio_service.dart';
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
    this.preferences,
  });

  factory UserModel.fromFirebase(User user) {
    return UserModel(
      uid: user.uid,
    );
  }

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
      occupation: map['occupation'],
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
      statusUntil: map['status_until'] != null ? DateTime.parse(map['status_until']) : null,
    );
  }

  String server = const String.fromEnvironment('SERVER');
  final User authenticatedUser = AuthService().getUser();
  final DioService dio = DioService();

  final String uid;
  final String? name;
  final String? surname;
  final int? age;
  final String? sex;
  final Pronoun? pronoun;
  final String? bio;
  final String? religion;
  final String? occupation;
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
      'occupation': occupation,
      'height': height,
      'weight': weight,
      'pronoun': pronoun?.toMap(),
      'available_swipes': availableSwipes ?? 20,
      'last_swipe': lastSwipe?.toIso8601String(),
      'active': active ?? false,
      'status': status,
      'status_reason': statusReason,
      'status_until': statusUntil?.toIso8601String(),
      'relationship_goal': relationshipGoal?.toMap(),
      'hobbies': hobbies?.map((Hobby hobby) => hobby.toMap()).toList(),
      'preferences': preferences?.toMap(),
    };
  }

  Future<int> getSwipes() async {
    final Response<dynamic> response = await dio.get(
      '$server/api/users/$uid',
      options: DioOptions(
        headers: {'Authorization': 'Bearer ${await authenticatedUser.getIdToken()}', 'Content-Type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      final UserModel user = UserModel.fromMap(response.data);

      return user.availableSwipes ?? 0;
    }

    return 0;
  }

  Future<bool> isActive() async {
    final Response<dynamic> response = await dio.get(
      '$server/api/users/$uid',
      options: DioOptions(
        headers: {'Authorization': 'Bearer ${await authenticatedUser.getIdToken()}', 'Content-Type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      final UserModel user = UserModel.fromMap(response.data as Map<String, dynamic>);

      return user.active ?? false;
    }

    return false;
  }
}
