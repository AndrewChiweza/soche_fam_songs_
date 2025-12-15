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

      String uid = result.user!.uid;

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

  /// STREAM ADMINS FOR UI LISTS
  Stream<List<AdminUser>> streamAdmins() {
    return _db
        .collection("admins")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AdminUser.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// CREATE NEW ADMIN (also create Firebase Auth user)
  Future<void> createAdmin(AdminUser admin, String password) async {
    try {
      // Create Firebase Auth account
      final userCred = await _auth.createUserWithEmailAndPassword(
          email: admin.email, password: password);

      final uid = userCred.user!.uid;

      // Save profile in Firestore
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

  /// UPDATE ADMIN PROFILE (Firestore only)
  Future<void> updateAdmin(AdminUser admin) async {
    try {
      await _db.collection("admins").doc(admin.id).update({
        'name': admin.name,
        'email': admin.email,
        'isSuperAdmin': admin.isSuperAdmin,
      });
    } catch (e) {
      debugPrint("Error updating admin: $e");
      rethrow;
    }
  }

  /// DELETE ADMIN (Firestore + Firebase Auth)
  Future<void> deleteAdmin(String id) async {
    try {
      // Delete from Firestore
      await _db.collection("admins").doc(id).delete();

      // Delete Firebase Auth user
      // Note: Deleting from Firebase Auth requires admin privileges (use Firebase Functions)
      debugPrint(
          "Firebase Auth deletion not implemented here; consider Firebase Function.");
    } catch (e) {
      debugPrint("Error deleting admin: $e");
      rethrow;
    }
  }

  /// RESET PASSWORD (send email)
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint("Error sending password reset: $e");
      rethrow;
    }
  }
}
