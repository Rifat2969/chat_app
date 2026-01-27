import 'package:firebase_auth/firebase_auth.dart'; // Add this import

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final DateTime? createdAt;

  UserModel({required this.uid, required this.email, required this.displayName, this.photoURL, this.createdAt});

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoURL: map['photoURL'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }

  // Create from Firebase User
  factory UserModel.fromFirebaseUser(User user, {String? displayName}) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName ?? user.displayName ?? 'User',
      photoURL: user.photoURL,
      createdAt: DateTime.now(),
    );
  }
}
