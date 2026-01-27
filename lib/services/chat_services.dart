import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/message_model.dart';
import '../models/user_model.dart'; // Make sure this is correct

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> _uploadImage(File imageFile, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Future<void> sendMessage({required String receiverId, required String message, String? imagePath}) async {
    final currentUser = _auth.currentUser!;
    final timestamp = DateTime.now();

    String? imageUrl;
    if (imagePath != null) {
      imageUrl = await _uploadImage(
        File(imagePath),
        'chat_images/${currentUser.uid}_${timestamp.millisecondsSinceEpoch}.jpg',
      );
    }

    final messageData = {
      'senderId': currentUser.uid,
      'receiverId': receiverId,
      'message': message,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'isRead': false,
    };

    final chatRoomId = _getChatRoomId(currentUser.uid, receiverId);
    await _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').add(messageData);
  }

  Stream<List<MessageModel>> getChatStream(String otherUserId) {
    final currentUser = _auth.currentUser!;
    final chatRoomId = _getChatRoomId(currentUser.uid, otherUserId);

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => MessageModel.fromMap(doc.id, doc.data())).toList();
        });
  }

  Future<List<UserModel>> getAllUsers() async {
    final currentUser = _auth.currentUser!;
    final snapshot = await _firestore.collection('users').where('uid', isNotEqualTo: currentUser.uid).get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }

  String _getChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '$user1-$user2' : '$user2-$user1';
  }
}
