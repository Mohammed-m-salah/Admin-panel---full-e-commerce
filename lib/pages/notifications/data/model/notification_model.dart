enum NotificationType {
  newOrder,
  orderStatusChange,
  newOffer,
  productBackInStock,
  newBanner,
  custom,
}

enum NotificationTarget {
  allUsers,
  specificUser,
}

class NotificationModel {
  final String? id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationTarget target;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final int sentCount;
  final int readCount;
  final bool isAutomatic;

  NotificationModel({
    this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.target,
    this.userId,
    this.userName,
    this.userEmail,
    this.data,
    DateTime? createdAt,
    this.sentCount = 0,
    this.readCount = 0,
    this.isAutomatic = false,
  }) : createdAt = createdAt ?? DateTime.now();

  // تحويل من Map (Supabase)
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: _parseNotificationType(map['type']),
      target: _parseNotificationTarget(map['target']),
      userId: map['user_id'],
      userName: map['user_name'],
      userEmail: map['user_email'],
      data: map['data'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      sentCount: map['sent_count'] ?? 0,
      readCount: map['read_count'] ?? 0,
      isAutomatic: map['is_automatic'] ?? false,
    );
  }

  // تحويل إلى Map (Supabase)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type.name,
      'target': target.name,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'data': data,
      'sent_count': sentCount,
      'read_count': readCount,
      'is_automatic': isAutomatic,
    };
  }

  static NotificationType _parseNotificationType(String? type) {
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

  static NotificationTarget _parseNotificationTarget(String? target) {
    switch (target) {
      case 'specificUser':
        return NotificationTarget.specificUser;
      default:
        return NotificationTarget.allUsers;
    }
  }

  String get typeDisplayName {
    switch (type) {
      case NotificationType.newOrder:
        return 'New Order';
      case NotificationType.orderStatusChange:
        return 'Order Status Change';
      case NotificationType.newOffer:
        return 'New Offer';
      case NotificationType.productBackInStock:
        return 'Back in Stock';
      case NotificationType.newBanner:
        return 'New Banner';
      case NotificationType.custom:
        return 'Custom';
    }
  }

  String get targetDisplayName {
    switch (target) {
      case NotificationTarget.allUsers:
        return 'All Users';
      case NotificationTarget.specificUser:
        return userName ?? 'Specific User';
    }
  }
}

// Auto Notification Settings
class AutoNotificationSetting {
  final NotificationType type;
  final String title;
  final String description;
  bool isEnabled;

  AutoNotificationSetting({
    required this.type,
    required this.title,
    required this.description,
    this.isEnabled = true,
  });
}
