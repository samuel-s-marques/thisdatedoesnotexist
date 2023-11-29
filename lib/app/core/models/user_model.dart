import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thisdatedoesnotexist/app/core/models/hobby_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/preferences_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';

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
    this.birthdayDate,
    this.lastSwipe,
    this.swipes,
    this.active,
    this.relationshipGoal,
    this.hobbies,
    this.preferences,
  });

  factory UserModel.fromFirebase(User user) {
    return UserModel(
      uid: user.uid,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
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
      height: map['height'],
      weight: map['weight'],
      birthdayDate: map['birthday_date'] != null ? DateTime.parse(map['birthday_date']) : null,
      lastSwipe: map['last_swipe'] != null ? DateTime.parse(map['last_swipe']) : null,
      swipes: map['swipes'],
      active: map['active'],
      relationshipGoal: map['relationship_goal'],
      hobbies: (map['hobbies'] as List<dynamic>?)?.map((hobbyMap) => Hobby.fromMap(hobbyMap as Map<String, dynamic>)).toList(),
      preferences: map['preferences'] != null ? Preferences.fromMap(map['preferences'] as Map<String, dynamic>) : null,
    );
  }

  String server = const String.fromEnvironment('SERVER');
  final User authenticatedUser = AuthService().getUser();
  final Dio dio = Dio();

  final String uid;
  final String? name;
  final String? surname;
  final int? age;
  final String? sex;
  final String? bio;
  final String? religion;
  final String? country;
  final String? politicalView;
  final double? height;
  final double? weight;
  final DateTime? birthdayDate;
  final int? swipes;
  final bool? active;
  final DateTime? lastSwipe;
  final String? relationshipGoal;
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
      'height': height,
      'weight': weight,
      'birthday_date': birthdayDate?.toIso8601String(),
      'swipes': swipes ?? 20,
      'last_swipe': lastSwipe?.toIso8601String(),
      'active': active ?? false,
      'relationship_goal': relationshipGoal ?? '',
      'hobbies': hobbies?.map((Hobby hobby) => hobby.toMap()).toList(),
      'preferences': preferences?.toMap(),
    };
  }

  Future<int> getSwipes() async {
    final Response response = await dio.get(
      '$server/api/users/$uid',
      options: Options(
        headers: {'Authorization': 'Bearer ${await authenticatedUser.getIdToken()}', 'Content-Type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      final UserModel user = UserModel.fromMap(response.data);

      return user.swipes ?? 0;
    }

    return 0;
  }

  Future<bool> isActive() async {
    final Response response = await dio.get(
      '$server/api/users/$uid',
      options: Options(
        headers: {'Authorization': 'Bearer ${await authenticatedUser.getIdToken()}', 'Content-Type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      final UserModel user = UserModel.fromMap(response.data);

      return user.active ?? false;
    }

    return false;
  }
}
