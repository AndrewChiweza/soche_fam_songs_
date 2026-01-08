import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_user.dart';

class AdminsProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AdminUser? _currentAdmin;
  AdminUser? get currentAdmin => _currentAdmin;
  bool get isLoggedIn => _currentAdmin != null;

  /// SIGN IN ADMIN
  Future<String?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = result.user!.uid;

      final doc = await _db.collection('admins').doc(uid).get();
      if (!doc.exists) {
        await _auth.signOut();
        return "No admin profile found for this account!";
      }

      _currentAdmin = AdminUser.fromMap(doc.data()!, doc.id);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// SIGN OUT ADMIN
  Future<void> signOut() async {
    await _auth.signOut();
    _currentAdmin = null;
    notifyListeners();
  }

  /// STREAM ADMINS
  Stream<List<AdminUser>> streamAdmins() {
    return _db
        .collection("admins")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AdminUser.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// CREATE ADMIN (SUPER ADMIN ONLY)
  Future<void> createAdmin(AdminUser admin, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: admin.email,
        password: password,
      );

      final uid = cred.user!.uid;

      await _db.collection("admins").doc(uid).set({
        'name': admin.name,
        'email': admin.email,
        'isSuperAdmin': admin.isSuperAdmin,
        'createdAt': admin.createdAt,
      });
    } catch (e) {
      debugPrint("Error creating admin: $e");
      rethrow;
    }
  }

  /// UPDATE ADMIN PROFILE
  /// Password handling rules:
  /// - If editing SELF and password provided → update password
  /// - If SUPER ADMIN editing another admin and password provided → send reset email
  Future<void> updateAdmin(
    AdminUser admin, {
    String? newPassword,
  }) async {
    try {
      // Update Firestore profile
      await _db.collection("admins").doc(admin.id).update({
        'name': admin.name,
        'email': admin.email,
        'isSuperAdmin': admin.isSuperAdmin,
      });

      if (newPassword != null && newPassword.isNotEmpty) {
        final currentUser = _auth.currentUser;

        // CASE 1: Admin updating their OWN password
        if (currentUser != null && currentUser.uid == admin.id) {
          await currentUser.updatePassword(newPassword);
        }

        // CASE 2: Super admin updating another admin's password
        else if (_currentAdmin?.isSuperAdmin == true) {
          await _auth.sendPasswordResetEmail(email: admin.email);
        }
      }
    } catch (e) {
      debugPrint("Error updating admin: $e");
      rethrow;
    }
  }

  /// DELETE ADMIN (Firestore only)
  /// Firebase Auth deletion should be done via Cloud Functions
  Future<void> deleteAdmin(String id) async {
    try {
      await _db.collection("admins").doc(id).delete();
    } catch (e) {
      debugPrint("Error deleting admin: $e");
      rethrow;
    }
  }

  /// RESET PASSWORD (manual trigger)
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint("Error sending password reset: $e");
      rethrow;
    }
  }
}
