import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File imageFile, String path) async {
    try {
      // Create a reference to the location you want to upload to
      final ref = _storage.ref().child(path);

      // Upload the file
      final uploadTask = ref.putFile(imageFile);

      // Wait for the upload to complete
      final snapshot = await uploadTask.whenComplete(() {});

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      // Create a reference from the download URL
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}
