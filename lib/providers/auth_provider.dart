import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'package:flutter/material.dart';

import '../models/user_model.dart'; // Make sure this import is correct
import '../services/auth_services.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Add this
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    if (_isLoading) return; // Prevent multiple calls

    _isLoading = true;
    notifyListeners();

    try {
      print('🔄 Checking for existing user...');

      // Check Firebase Auth for existing session
      final firebaseUser = _auth.currentUser; // Use _auth instead

      if (firebaseUser != null) {
        print('👤 Found Firebase user: ${firebaseUser.uid}');

        // Get user data from Firestore
        _currentUser = await _authService.getUserData(firebaseUser.uid);

        if (_currentUser != null) {
          print('✅ Auto-login successful: ${_currentUser!.email}');
        } else {
          print('⚠️ User data not found in Firestore');
          await _auth.signOut(); // Clear invalid session
        }
      } else {
        print('ℹ️ No existing Firebase session found');
      }
    } catch (e) {
      print('❌ Error during auto-login: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.signInWithEmail(email, password);
      notifyListeners();
      return _currentUser;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> signUp(String email, String password, String displayName) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.signUpWithEmail(email, password, displayName);
      notifyListeners();
      return _currentUser;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
