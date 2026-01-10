import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../model/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _notificationsCollection =>
      _firestore.collection('notifications');

  CollectionReference get _userTokensCollection =>
      _firestore.collection('user_tokens');

  /// Send notification to all users
  Future<void> sendToAllUsers({
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _notificationsCollection.add({
        'title': title,
        'body': body,
        'type': type.name,
        'target': 'allUsers',
        'data': data,
        'createdAt': FieldValue.serverTimestamp(),
        'sentCount': 0,
        'readCount': 0,
        'isAutomatic': false,
      });
      debugPrint('Notification sent to all users');
    } catch (e) {
      debugPrint('Error sending notification: $e');
      rethrow;
    }
  }

  /// Send notification to specific user
  Future<void> sendToUser({
    required String userId,
    required String userName,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _notificationsCollection.add({
        'title': title,
        'body': body,
        'type': type.name,
        'target': 'specificUser',
        'userId': userId,
        'userName': userName,
        'data': data,
        'createdAt': FieldValue.serverTimestamp(),
        'sentCount': 1,
        'readCount': 0,
        'isAutomatic': false,
      });
      debugPrint('Notification sent to user: $userName');
    } catch (e) {
      debugPrint('Error sending notification to user: $e');
      rethrow;
    }
  }

  /// Get all notifications stream
  Stream<List<NotificationModel>> getNotificationsStream() {
    return _notificationsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return NotificationModel(
          id: doc.id,
          title: data['title'] ?? '',
          body: data['body'] ?? '',
          type: _parseNotificationType(data['type']),
          target: _parseNotificationTarget(data['target']),
          userId: data['userId'],
          userName: data['userName'],
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          sentCount: data['sentCount'] ?? 0,
          readCount: data['readCount'] ?? 0,
          isAutomatic: data['isAutomatic'] ?? false,
        );
      }).toList();
    });
  }

  /// Get all notifications (one-time fetch)
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final snapshot = await _notificationsCollection
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return NotificationModel(
          id: doc.id,
          title: data['title'] ?? '',
          body: data['body'] ?? '',
          type: _parseNotificationType(data['type']),
          target: _parseNotificationTarget(data['target']),
          userId: data['userId'],
          userName: data['userName'],
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          sentCount: data['sentCount'] ?? 0,
          readCount: data['readCount'] ?? 0,
          isAutomatic: data['isAutomatic'] ?? false,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).delete();
      debugPrint('Notification deleted: $notificationId');
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      rethrow;
    }
  }

  /// Update notification read count
  Future<void> incrementReadCount(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).update({
        'readCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error updating read count: $e');
    }
  }

  /// Get user tokens for sending push notifications
  Future<List<Map<String, dynamic>>> getMobileUserTokens() async {
    try {
      final snapshot = await _userTokensCollection
          .where('platform', isEqualTo: 'mobile')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'userId': doc.id,
          'token': data['token'],
          'platform': data['platform'],
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching user tokens: $e');
      return [];
    }
  }

  /// Parse notification type from string
  NotificationType _parseNotificationType(String? type) {
    switch (type) {
      case 'newOrder':
        return NotificationType.newOrder;
      case 'orderStatusChange':
        return NotificationType.orderStatusChange;
      case 'newOffer':
        return NotificationType.newOffer;
      case 'productBackInStock':
        return NotificationType.productBackInStock;
      case 'newBanner':
        return NotificationType.newBanner;
      default:
        return NotificationType.custom;
    }
  }

  /// Parse notification target from string
  NotificationTarget _parseNotificationTarget(String? target) {
    switch (target) {
      case 'specificUser':
        return NotificationTarget.specificUser;
      default:
        return NotificationTarget.allUsers;
    }
  }
}
