// lib/providers/notification_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream notifikasi khusus untuk user tertentu
  Stream<List<NotificationModel>> streamUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
    });
  }

  // Fungsi untuk mengubah status notifikasi menjadi "Sudah Dibaca"
  Future<void> tandaiSudahDibaca(String notifId) async {
    try {
      await _firestore.collection('notifications').doc(notifId).update({
        'is_read': true,
      });
    } catch (e) {
      debugPrint('Error update notif: $e');
    }
  }
}