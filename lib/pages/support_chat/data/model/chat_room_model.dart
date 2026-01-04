class ChatRoomModel {
  final String? id;

  final String? userId;

  final String? adminId;

  final String status;

  final DateTime? createdAt;

  final String? userName;

  final String? userAvatar;

  final String? userEmail;

  final String? lastMessage;

  final DateTime? lastMessageTime;

  final int unreadCount;

  final bool isOnline;

  ChatRoomModel({
    this.id,
    this.userId,
    this.adminId,
    this.status = 'open',
    this.createdAt,
    // حقول العرض
    this.userName,
    this.userAvatar,
    this.userEmail,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    // استخراج بيانات المستخدم إذا كانت موجودة (من JOIN)
    final userData = json['users'] as Map<String, dynamic>?;

    return ChatRoomModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      adminId: json['admin_id']?.toString(),
      status: json['status'] ?? 'open',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      userName: userData?['name'] ?? json['user_name'],
      userAvatar: userData?['avatar'] ?? json['user_avatar'],
      userEmail: userData?['email'] ?? json['user_email'],
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      isOnline: json['is_online'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'admin_id': adminId,
      'status': status,
    };
  }

  Map<String, dynamic> toJsonForInsert() {
    return {
      'user_id': userId,
      'status': status,
      // admin_id يبقى null حتى يتم تعيين أدمن
    };
  }

  ChatRoomModel copyWith({
    String? id,
    String? userId,
    String? adminId,
    String? status,
    DateTime? createdAt,
    String? userName,
    String? userAvatar,
    String? userEmail,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isOnline,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      adminId: adminId ?? this.adminId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      userEmail: userEmail ?? this.userEmail,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  bool get isOpen => status == 'open';

  bool get isResolved => status == 'resolved';

  bool get hasUnreadMessages => unreadCount > 0;

  bool get hasAdmin => adminId != null && adminId!.isNotEmpty;

  String get userInitial => userName != null && userName!.isNotEmpty
      ? userName![0].toUpperCase()
      : '?';

  String get formattedLastMessageTime {
    if (lastMessageTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(lastMessageTime!);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return '${diff.inMinutes} د';
    if (diff.inHours < 24) return '${diff.inHours} س';
    if (diff.inDays < 7) return '${diff.inDays} ي';
    return '${lastMessageTime!.day}/${lastMessageTime!.month}';
  }

  @override
  String toString() {
    return 'ChatRoomModel(id: $id, userId: $userId, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatRoomModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum ChatRoomStatus {
  open('open', 'مفتوحة'),
  pending('pending', 'معلقة'),
  resolved('resolved', 'محلولة'),
  closed('closed', 'مغلقة');

  final String value;
  final String arabicLabel;
  const ChatRoomStatus(this.value, this.arabicLabel);
}
