import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  UserModel({required this.uid, this.lastSwipe});

  factory UserModel.fromFirebase(User user) {
    return UserModel(
      uid: user.uid,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      lastSwipe: map['lastSwipe'],
    );
  }

  FirebaseFirestore db = FirebaseFirestore.instance;

  final String uid;
  final int swipes = 20;
  final DateTime? lastSwipe;

  Map<String, dynamic> toMap() {
    return {
      'swipes': swipes,
      'lastSwipe': lastSwipe,
    };
  }

  Future<int> getSwipes() async {
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await db.collection('users').doc(uid).get();

    return documentSnapshot.data()!['swipes'] ?? 0;
  }
}
