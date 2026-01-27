import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      return getUserData(user.uid);
    }
    return null;
  }

  Future<UserModel> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);

    final user = await getUserData(credential.user!.uid);
    if (user == null) {
      throw Exception('User data not found in Firestore');
    }
    return user;
  }

  Future<UserModel> signUpWithEmail(String email, String password, String displayName) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

    final user = UserModel(
      uid: credential.user!.uid,
      email: email,
      displayName: displayName,
      photoURL: null,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(user.toMap());

    return user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
