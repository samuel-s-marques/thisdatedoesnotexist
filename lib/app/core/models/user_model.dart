import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thisdatedoesnotexist/app/core/models/hobby_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/preferences_model.dart';

class UserModel {
  UserModel({
    required this.uid,
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
      lastSwipe: map['last_swipe'] != null ? (map['lastSwipe'] as Timestamp).toDate() : null,
      active: map['active'],
      swipes: map['swipes'],
      relationshipGoal: map['relationship_goal'] ?? [],
      hobbies: (map['hobbies'] as List<dynamic>?)?.map((hobbyMap) => Hobby.fromMap(hobbyMap as Map<String, dynamic>)).toList(),
      preferences: map['preferences'] != null ? Preferences.fromMap(map['preferences'] as Map<String, dynamic>) : null,
    );
  }

  FirebaseFirestore db = FirebaseFirestore.instance;

  final String uid;
  final int? swipes;
  final bool? active;
  final DateTime? lastSwipe;
  final String? relationshipGoal;
  final List<Hobby>? hobbies;
  final Preferences? preferences;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'swipes': swipes ?? 20,
      'last_swipe': lastSwipe != null ? Timestamp.fromDate(lastSwipe!) : null,
      'active': active ?? false,
      'relationship_goal': relationshipGoal ?? '',
      'hobbies': hobbies?.map((Hobby hobby) => hobby.toMap()).toList(),
      'preferences': preferences?.toMap(),
    };
  }

  Future<int> getSwipes() async {
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await db.collection('users').doc(uid).get();

    return documentSnapshot.data()!['swipes'] ?? 0;
  }

  Future<bool> isActive() async {
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await db.collection('users').doc(uid).get();

    return documentSnapshot.data()!['active'] ?? false;
  }
}
