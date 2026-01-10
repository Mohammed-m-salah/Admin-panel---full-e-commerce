import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initialize() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('User granted provisional permission');
      } else {
        debugPrint('User declined permission');
        return;
      }

      String? token = await _messaging.getToken(
        vapidKey:
            'BCJCkYn61ruiu8z9Uh7Ag9TJs8Mxxnx1Y3b5eY2hQT_io9DAGg5fpLL6H-82nZRhydVsoifTgpkYaFnWoLrbwLQ',
      );
      debugPrint('FCM Token: $token');

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint(
          'Message also contained a notification: ${message.notification}');
    }
  }

  static void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.data}');
  }

  static Future<void> sendNotificationToUser({
    required String userToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _firestore.collection('notifications').add({
      'token': userToken,
      'title': title,
      'body': body,
      'data': data,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  static Future<void> sendBroadcastNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _firestore.collection('broadcast_notifications').add({
      'title': title,
      'body': body,
      'data': data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> saveUserToken(String userId) async {
    String? token = await _messaging.getToken();
    if (token != null) {
      await _firestore.collection('user_tokens').doc(userId).set({
        'token': token,
        'updatedAt': FieldValue.serverTimestamp(),
        'platform': kIsWeb ? 'web' : 'mobile',
      });
    }
  }

  static Future<List<String>> getMobileUserTokens() async {
    QuerySnapshot snapshot = await _firestore
        .collection('user_tokens')
        .where('platform', isEqualTo: 'mobile')
        .get();

    return snapshot.docs.map((doc) => doc['token'] as String).toList();
  }
}
