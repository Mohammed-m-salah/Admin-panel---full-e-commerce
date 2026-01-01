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
    DateTime? createdAt,
    this.sentCount = 0,
    this.readCount = 0,
    this.isAutomatic = false,
  }) : createdAt = createdAt ?? DateTime.now();

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
  final bool isEnabled;

  AutoNotificationSetting({
    required this.type,
    required this.title,
    required this.description,
    this.isEnabled = true,
  });
}
