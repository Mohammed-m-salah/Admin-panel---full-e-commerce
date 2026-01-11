import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/notification_model.dart';

class NotificationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _notificationsTable = 'notifications';
  static const String _userTokensTable = 'user_tokens';
  static const String _customersTable = 'customers';

  Future<void> sendToAllUsers({
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _supabase.from(_notificationsTable).insert({
        'title': title,
        'body': body,
        'type': type.name,
        'target': 'allUsers',
        'data': data,
        'sent_count': 0,
        'read_count': 0,
        'is_automatic': false,
      });
      debugPrint('Notification sent to all users');
    } catch (e) {
      debugPrint('Error sending notification: $e');
      rethrow;
    }
  }

  Future<void> sendToUser({
    required String userId,
    required String userName,
    String? userEmail,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _supabase.from(_notificationsTable).insert({
        'title': title,
        'body': body,
        'type': type.name,
        'target': 'specificUser',
        'user_id': userId,
        'user_name': userName,
        'user_email': userEmail,
        'data': data,
        'sent_count': 1,
        'read_count': 0,
        'is_automatic': false,
      });
      debugPrint('Notification sent to user: $userName');
    } catch (e) {
      debugPrint('Error sending notification to user: $e');
      rethrow;
    }
  }

  Stream<List<NotificationModel>> getNotificationsStream() {
    return _supabase
        .from(_notificationsTable)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
          return data.map((item) => NotificationModel.fromMap(item)).toList();
        });
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final response = await _supabase
          .from(_notificationsTable)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => NotificationModel.fromMap(item))
          .toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from(_notificationsTable)
          .delete()
          .eq('id', notificationId);
      debugPrint('Notification deleted: $notificationId');
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      rethrow;
    }
  }

  Future<void> incrementReadCount(String notificationId) async {
    try {
      // Get current read_count first
      final response = await _supabase
          .from(_notificationsTable)
          .select('read_count')
          .eq('id', notificationId)
          .single();

      final currentCount = response['read_count'] ?? 0;

      await _supabase.from(_notificationsTable).update({
        'read_count': currentCount + 1,
      }).eq('id', notificationId);
    } catch (e) {
      debugPrint('Error updating read count: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMobileUserTokens() async {
    try {
      final response = await _supabase
          .from(_userTokensTable)
          .select()
          .eq('platform', 'mobile');

      return (response as List).map((doc) {
        return {
          'userId': doc['id'],
          'token': doc['token'],
          'platform': doc['platform'],
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching user tokens: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCustomers() async {
    try {
      final response = await _supabase
          .from(_customersTable)
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((customer) {
        return {
          'id': customer['id']?.toString() ?? '',
          'name': customer['name'] ?? 'Unknown',
          'email': customer['email'] ?? '',
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching customers from Supabase: $e');
      return [];
    }
  }

  Future<void> resendNotification(NotificationModel notification) async {
    try {
      if (notification.target == NotificationTarget.allUsers) {
        await sendToAllUsers(
          title: notification.title,
          body: notification.body,
          type: notification.type,
          data: notification.data,
        );
      } else {
        await sendToUser(
          userId: notification.userId ?? '',
          userName: notification.userName ?? 'User',
          userEmail: notification.userEmail,
          title: notification.title,
          body: notification.body,
          type: notification.type,
          data: notification.data,
        );
      }
      debugPrint('Notification resent successfully');
    } catch (e) {
      debugPrint('Error resending notification: $e');
      rethrow;
    }
  }
}
