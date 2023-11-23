import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thisdatedoesnotexist/app/core/models/hobby_model.dart';

class UserModel {
  UserModel({
    required this.uid,
    this.lastSwipe,
    this.swipes,
    this.active,
    this.relationshipGoal,
    this.hobbies,
  });

  factory UserModel.fromFirebase(User user) {
    return UserModel(
      uid: user.uid,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      lastSwipe: map['lastSwipe'] != null ? (map['lastSwipe'] as Timestamp).toDate() : null,
      active: map['active'],
      swipes: map['swipes'],
      relationshipGoal: map['relationshipGoal'],
      hobbies: map['hobbies'] != null ? List<Hobby>.from(map['hobbies'].map(Hobby.fromMap)) : null,
    );
  }

  FirebaseFirestore db = FirebaseFirestore.instance;

  final String uid;
  final int? swipes;
  final bool? active;
  final DateTime? lastSwipe;
  final String? relationshipGoal;
  final List<Hobby>? hobbies;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'swipes': swipes,
      'lastSwipe': Timestamp.fromDate(lastSwipe!),
      'active': active,
      'relationshipGoal': relationshipGoal,
      'hobbies': hobbies,
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
