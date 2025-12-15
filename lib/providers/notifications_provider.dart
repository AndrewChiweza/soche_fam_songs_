import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart';

class AnnouncementsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Announcement> _items = [];
  List<Announcement> get items => List.unmodifiable(_items);

  /// STREAM for admin & users
  Stream<List<Announcement>> get announcementsStream {
    return _firestore
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Announcement(
                id: doc.id,
                title: doc['title'] ?? '',
                message: doc['message'] ?? '',
                createdAt: (doc['createdAt'] as Timestamp).toDate(),
              ))
          .toList();
    });
  }

  /// Load announcements (optional)
  Future<void> loadAnnouncements() async {
    try {
      final snapshot = await _firestore
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .get();

      _items = snapshot.docs
          .map((doc) => Announcement(
                id: doc.id,
                title: doc['title'] ?? '',
                message: doc['message'] ?? '',
                createdAt: (doc['createdAt'] as Timestamp).toDate(),
              ))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading announcements: $e');
    }
  }

  /// Add announcement
  Future<void> addAnnouncement(Announcement a) async {
    try {
      final doc = await _firestore.collection('announcements').add({
        'title': a.title,
        'message': a.message,
        'createdAt': a.createdAt,
      });

      _items.insert(
        0,
        Announcement(
          id: doc.id,
          title: a.title,
          message: a.message,
          createdAt: a.createdAt,
        ),
      );

      // 🔔 TRIGGER PUSH NOTIFICATION
      await _firestore.collection('pushQueue').add({
        'title': a.title,
        'body': a.message,
        'topic': 'allUsers',
        'createdAt': FieldValue.serverTimestamp(),
      });

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding announcement: $e');
    }
  }

  /// **Required by your screen**
  Future<void> editAnnouncement(Announcement a) async {
    try {
      await _firestore.collection('announcements').doc(a.id).update({
        'title': a.title,
        'message': a.message,
        // keep createdAt unchanged
      });

      // update in provider list
      final index = _items.indexWhere((x) => x.id == a.id);
      if (index != -1) {
        _items[index] = a;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error editing announcement: $e');
    }
  }

  /// Delete announcement
  Future<void> deleteAnnouncement(String id) async {
    try {
      await _firestore.collection('announcements').doc(id).delete();
      _items.removeWhere((x) => x.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting announcement: $e');
    }
  }

  void clearAll() {
    _items.clear();
    notifyListeners();
  }

  Future<void> removeAnnouncement(String id) async {
    return deleteAnnouncement(id);
  }
}
