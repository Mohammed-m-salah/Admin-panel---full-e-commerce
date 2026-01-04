import 'dart:collection';

class ChatMessageModel {
  final String? id;

  final String chatRoomId;

  final String senderId;

  final String message;

  final bool isAdmin;

  final bool isRead;

  final DateTime? createdAt;

  ChatMessageModel({
    this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.message,
    this.isAdmin = false,
    this.isRead = false,
    this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id']?.toString(),
      chatRoomId: json['chat_room_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      message: json['message'] ?? '',
      isAdmin: json['is_admin'] ?? false,
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'chat_room_id': chatRoomId,
      'sender_id': senderId,
      'message': message,
      'is_admin': isAdmin,
      'is_read': isRead,
    };
  }

  Map<String, dynamic> toJsonForInsert() {
    return {
      'chat_room_id': chatRoomId,
      'sender_id': senderId,
      'message': message,
      'is_admin': isAdmin,
    };
  }

  ChatMessageModel copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? message,
    bool? isAdmin,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      isAdmin: isAdmin ?? this.isAdmin,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedTime {
    if (createdAt == null) return '';
    return '${createdAt!.hour.toString().padLeft(2, '0')}:${createdAt!.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    if (createdAt == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate =
        DateTime(createdAt!.year, createdAt!.month, createdAt!.day);

    if (messageDate == today) return 'اليوم';
    if (messageDate == yesterday) return 'أمس';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }

  bool get isFromUser => !isAdmin;

  @override
  String toString() {
    return 'ChatMessageModel(id: $id, message: ${message.length > 20 ? '${message.substring(0, 20)}...' : message}, isAdmin: $isAdmin)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

extension ChatMessageListExtension on List<ChatMessageModel> {
  /// تجميع الرسائل حسب التاريخ مع الحفاظ على الترتيب الزمني
  Map<String, List<ChatMessageModel>> groupByDate() {
    // ترتيب الرسائل حسب التاريخ أولاً
    final sortedMessages = List<ChatMessageModel>.from(this)
      ..sort((a, b) {
        final aTime = a.createdAt ?? DateTime(1970);
        final bTime = b.createdAt ?? DateTime(1970);
        return aTime.compareTo(bTime);
      });

    // تجميع حسب التاريخ مع الحفاظ على الترتيب
    final Map<String, List<ChatMessageModel>> grouped = {};
    final List<String> orderedKeys = [];

    for (final message in sortedMessages) {
      final dateKey = message.formattedDate;
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
        orderedKeys.add(dateKey);
      }
      grouped[dateKey]!.add(message);
    }

    // إرجاع Map مرتب حسب ترتيب الإضافة
    final LinkedHashMap<String, List<ChatMessageModel>> orderedMap =
        LinkedHashMap<String, List<ChatMessageModel>>();
    for (final key in orderedKeys) {
      orderedMap[key] = grouped[key]!;
    }

    return orderedMap;
  }

  ChatMessageModel? get lastMessage => isEmpty ? null : last;

  int get unreadCount => where((m) => !m.isRead && !m.isAdmin).length;
}
