import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Hash password
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Register user
  Future<UserModel?> registerUser({
    required String name,
    required String email,
    required String password,
    UserRole role = UserRole.user,
  }) async {
    try {
      // Create user with Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Create user model
        UserModel userModel = UserModel(
          id: result.user!.uid,
          name: name,
          email: email,
          password: _hashPassword(password),
          role: role,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        // Save user data to Firestore
        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(userModel.toMap());

        return userModel;
      }
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
    return null;
  }

  // Login user
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Get user data from Firestore
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .get();

        if (doc.exists) {
          UserModel userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
          
          // Update last login
          await _firestore
              .collection('users')
              .doc(result.user!.uid)
              .update({
            'lastLoginAt': DateTime.now().toIso8601String(),
          });

          return userModel;
        }
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
    return null;
  }

  // Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Get user error: $e');
    }
    return null;
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update(data);
    } catch (e) {
      print('Update profile error: $e');
      rethrow;
    }
  }

  // Check if user is admin
  Future<bool> isAdmin(String userId) async {
    try {
      UserModel? user = await getUserById(userId);
      return user?.role == UserRole.admin;
    } catch (e) {
      return false;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        // Re-authenticate user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        
        // Update password
        await user.updatePassword(newPassword);
        
        // Update hashed password in Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({
          'password': _hashPassword(newPassword),
        });
      }
    } catch (e) {
      print('Change password error: $e');
      rethrow;
    }
  }
} 