// lib/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId; // ID penerima notifikasi (NIM Siswa)
  final String title;
  final String body;
  final bool isRead;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.isRead,
    required this.timestamp,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['user_id'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      isRead: data['is_read'] ?? false,
      timestamp: data['timestamp'] != null 
          ? (data['timestamp'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'title': title,
      'body': body,
      'is_read': isRead,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}