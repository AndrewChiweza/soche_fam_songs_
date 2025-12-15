import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUser {
  final String id; // SAME AS FirebaseAuth UID
  final String name;
  final String email;
  final bool isSuperAdmin;
  final DateTime createdAt;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.isSuperAdmin,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'isSuperAdmin': isSuperAdmin,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AdminUser.fromMap(Map<String, dynamic> map, String id) {
    return AdminUser(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      isSuperAdmin: map['isSuperAdmin'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
