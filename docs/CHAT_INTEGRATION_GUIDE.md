# دليل ربط Chat بداتا حقيقية (Real-time Chat Integration)

## الوضع الحالي

حاليًا الـ chat يستخدم بيانات ثابتة (hardcoded) في:
- `lib/pages/support_chat/view/support_chat_page.dart`

---

## الخيارات المتاحة للـ Backend

| الخيار | المميزات | التكلفة |
|--------|----------|---------|
| **Firebase** | سهل، real-time، مجاني للبداية | مجاني حتى حد معين |
| **Supabase** | مفتوح المصدر، PostgreSQL | مجاني حتى حد معين |
| **Socket.IO + Node.js** | تحكم كامل | حسب السيرفر |

---

## الطريقة الأولى: Firebase Firestore (موصى بها)

### الخطوة 1: إعداد Firebase

#### 1.1 إنشاء مشروع Firebase
1. اذهب إلى [Firebase Console](https://console.firebase.google.com)
2. اضغط "Add Project"
3. أدخل اسم المشروع
4. فعّل Google Analytics (اختياري)

#### 1.2 إضافة تطبيق Flutter
1. في Firebase Console، اضغط على أيقونة Flutter
2. اتبع التعليمات لتثبيت FlutterFire CLI:

```bash
# تثبيت FlutterFire CLI
dart pub global activate flutterfire_cli

# تهيئة Firebase في المشروع
flutterfire configure
```

#### 1.3 إضافة Dependencies

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.2
  cloud_firestore: ^4.14.0
  firebase_auth: ^4.16.0  # للمصادقة
```

```bash
flutter pub get
```

---

### الخطوة 2: تهيئة Firebase في التطبيق

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

---

### الخطوة 3: إنشاء Models للـ Chat

أنشئ ملف جديد:

```dart
// lib/models/chat_models.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج المحادثة
class Conversation {
  final String id;
  final String oderId;  // طلب معين مربوط بالمحادثة
  final String oderpic;  // صورة المنتج
  final String odertitle; // عنوان المنتج
  final String oderprice; // سعر المنتج
  final String userId;
  final String adminId;
  final String userName;
  final String userAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final String status; // open, pending, resolved

  Conversation({
    required this.id,
    required this.userId,
    required this.oderId,
    required this.oderpic,
    required this.odertitle,
    required this.oderprice,
    required this.adminId,
    required this.userName,
    required this.userAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.status = 'open',
  });

  /// تحويل من Firestore Document
  factory Conversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Conversation(
      id: doc.id,
      oderId: data['oderId'] ?? '',
      oderpic: data['oderpic'] ?? '',
      odertitle: data['odertitle'] ?? '',
      oderprice: data['oderprice'] ?? '',
      userId: data['userId'] ?? '',
      adminId: data['adminId'] ?? '',
      userName: data['userName'] ?? '',
      userAvatar: data['userAvatar'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      unreadCount: data['unreadCount'] ?? 0,
      isOnline: data['isOnline'] ?? false,
      status: data['status'] ?? 'open',
    );
  }

  /// تحويل إلى Map للحفظ في Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'oderId': oderId,
      'oderpic': oderpic,
      'odertitle': odertitle,
      'oderprice': oderprice,
      'adminId': adminId,
      'userName': userName,
      'userAvatar': userAvatar,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'status': status,
    };
  }
}

/// نموذج الرسالة
class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isFromAdmin;
  final bool isRead;
  final String? attachmentUrl;
  final String? attachmentType; // image, file, video

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isFromAdmin,
    this.isRead = false,
    this.attachmentUrl,
    this.attachmentType,
  });

  /// تحويل من Firestore Document
  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      conversationId: data['conversationId'] ?? '',
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isFromAdmin: data['isFromAdmin'] ?? false,
      isRead: data['isRead'] ?? false,
      attachmentUrl: data['attachmentUrl'],
      attachmentType: data['attachmentType'],
    );
  }

  /// تحويل إلى Map للحفظ في Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isFromAdmin': isFromAdmin,
      'isRead': isRead,
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
    };
  }
}
```

---

### الخطوة 4: إنشاء Chat Service

```dart
// lib/services/chat_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_models.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // مراجع المجموعات
  CollectionReference get _conversationsRef =>
      _firestore.collection('conversations');

  CollectionReference get _messagesRef =>
      _firestore.collection('messages');

  // ═══════════════════════════════════════════════════════════
  // المحادثات (Conversations)
  // ═══════════════════════════════════════════════════════════

  /// جلب جميع المحادثات (Real-time Stream)
  Stream<List<Conversation>> getConversations() {
    return _conversationsRef
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Conversation.fromFirestore(doc))
            .toList());
  }

  /// جلب المحادثات حسب الحالة
  Stream<List<Conversation>> getConversationsByStatus(String status) {
    return _conversationsRef
        .where('status', isEqualTo: status)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Conversation.fromFirestore(doc))
            .toList());
  }

  /// إنشاء محادثة جديدة
  Future<String> createConversation({
    required String oderId,
    required String oderpic,
    required String odertitle,
    required String oderprice,
    required String userId,
    required String userName,
    required String userAvatar,
    String adminId = '',
  }) async {
    final docRef = await _conversationsRef.add({
      'userId': userId,
      'oderId': oderId,
      'oderpic': oderpic,
      'odertitle': odertitle,
      'oderprice': oderprice,
      'adminId': adminId,
      'userName': userName,
      'userAvatar': userAvatar,
      'lastMessage': '',
      'lastMessageTime': Timestamp.now(),
      'unreadCount': 0,
      'isOnline': true,
      'status': 'open',
      'createdAt': Timestamp.now(),
    });
    return docRef.id;
  }

  /// تحديث حالة المحادثة
  Future<void> updateConversationStatus(String conversationId, String status) {
    return _conversationsRef.doc(conversationId).update({
      'status': status,
    });
  }

  // ═══════════════════════════════════════════════════════════
  // الرسائل (Messages)
  // ═══════════════════════════════════════════════════════════

  /// جلب رسائل محادثة معينة (Real-time Stream)
  Stream<List<ChatMessage>> getMessages(String conversationId) {
    return _messagesRef
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  /// إرسال رسالة جديدة
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    required bool isFromAdmin,
    String? attachmentUrl,
    String? attachmentType,
  }) async {
    // 1. إضافة الرسالة
    await _messagesRef.add({
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.now(),
      'isFromAdmin': isFromAdmin,
      'isRead': false,
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
    });

    // 2. تحديث آخر رسالة في المحادثة
    await _conversationsRef.doc(conversationId).update({
      'lastMessage': content,
      'lastMessageTime': Timestamp.now(),
      'unreadCount': FieldValue.increment(1),
    });
  }

  /// تحديث حالة القراءة
  Future<void> markMessagesAsRead(String conversationId, bool isAdmin) async {
    final query = await _messagesRef
        .where('conversationId', isEqualTo: conversationId)
        .where('isFromAdmin', isEqualTo: !isAdmin)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in query.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();

    // إعادة تعيين عداد الرسائل غير المقروءة
    await _conversationsRef.doc(conversationId).update({
      'unreadCount': 0,
    });
  }

  /// حذف رسالة
  Future<void> deleteMessage(String messageId) {
    return _messagesRef.doc(messageId).delete();
  }

  // ═══════════════════════════════════════════════════════════
  // حالة الاتصال (Online Status)
  // ═══════════════════════════════════════════════════════════

  /// تحديث حالة الاتصال
  Future<void> updateOnlineStatus(String conversationId, bool isOnline) {
    return _conversationsRef.doc(conversationId).update({
      'isOnline': isOnline,
    });
  }

  // ═══════════════════════════════════════════════════════════
  // البحث (Search)
  // ═══════════════════════════════════════════════════════════

  /// البحث في المحادثات
  Stream<List<Conversation>> searchConversations(String query) {
    // ملاحظة: Firestore لا يدعم البحث النصي الكامل
    // للبحث المتقدم، استخدم Algolia أو Elasticsearch
    return _conversationsRef
        .orderBy('userName')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Conversation.fromFirestore(doc))
            .toList());
  }
}
```

---

### الخطوة 5: إنشاء Chat Cubit (State Management)

```dart
// lib/blocs/chat/chat_cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/chat_models.dart';
import '../../services/chat_service.dart';

// ═══════════════════════════════════════════════════════════
// States
// ═══════════════════════════════════════════════════════════

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Conversation> conversations;
  final Conversation? selectedConversation;
  final List<ChatMessage> messages;

  ChatLoaded({
    required this.conversations,
    this.selectedConversation,
    this.messages = const [],
  });

  ChatLoaded copyWith({
    List<Conversation>? conversations,
    Conversation? selectedConversation,
    List<ChatMessage>? messages,
  }) {
    return ChatLoaded(
      conversations: conversations ?? this.conversations,
      selectedConversation: selectedConversation ?? this.selectedConversation,
      messages: messages ?? this.messages,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}

// ═══════════════════════════════════════════════════════════
// Cubit
// ═══════════════════════════════════════════════════════════

class ChatCubit extends Cubit<ChatState> {
  final ChatService _chatService;

  StreamSubscription? _conversationsSubscription;
  StreamSubscription? _messagesSubscription;

  ChatCubit(this._chatService) : super(ChatInitial());

  /// تحميل المحادثات
  void loadConversations() {
    emit(ChatLoading());

    _conversationsSubscription?.cancel();
    _conversationsSubscription = _chatService.getConversations().listen(
      (conversations) {
        final currentState = state;
        if (currentState is ChatLoaded) {
          emit(currentState.copyWith(conversations: conversations));
        } else {
          emit(ChatLoaded(conversations: conversations));
        }
      },
      onError: (error) => emit(ChatError(error.toString())),
    );
  }

  /// تحميل المحادثات حسب الفلتر
  void filterConversations(String status) {
    _conversationsSubscription?.cancel();

    final stream = status == 'all'
        ? _chatService.getConversations()
        : _chatService.getConversationsByStatus(status);

    _conversationsSubscription = stream.listen(
      (conversations) {
        final currentState = state;
        if (currentState is ChatLoaded) {
          emit(currentState.copyWith(conversations: conversations));
        } else {
          emit(ChatLoaded(conversations: conversations));
        }
      },
      onError: (error) => emit(ChatError(error.toString())),
    );
  }

  /// اختيار محادثة
  void selectConversation(Conversation conversation) {
    final currentState = state;
    if (currentState is ChatLoaded) {
      emit(currentState.copyWith(selectedConversation: conversation));
      _loadMessages(conversation.id);

      // تحديث حالة القراءة
      _chatService.markMessagesAsRead(conversation.id, true);
    }
  }

  /// تحميل الرسائل
  void _loadMessages(String conversationId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _chatService.getMessages(conversationId).listen(
      (messages) {
        final currentState = state;
        if (currentState is ChatLoaded) {
          emit(currentState.copyWith(messages: messages));
        }
      },
      onError: (error) => emit(ChatError(error.toString())),
    );
  }

  /// إرسال رسالة
  Future<void> sendMessage({
    required String content,
    String? attachmentUrl,
    String? attachmentType,
  }) async {
    final currentState = state;
    if (currentState is ChatLoaded && currentState.selectedConversation != null) {
      try {
        await _chatService.sendMessage(
          conversationId: currentState.selectedConversation!.id,
          senderId: 'admin_id', // استبدل بـ ID الأدمن الفعلي
          content: content,
          isFromAdmin: true,
          attachmentUrl: attachmentUrl,
          attachmentType: attachmentType,
        );
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    }
  }

  /// تحديث حالة المحادثة
  Future<void> updateStatus(String status) async {
    final currentState = state;
    if (currentState is ChatLoaded && currentState.selectedConversation != null) {
      await _chatService.updateConversationStatus(
        currentState.selectedConversation!.id,
        status,
      );
    }
  }

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }
}
```

---

### الخطوة 6: تحديث صفحة الـ Chat

```dart
// lib/pages/support_chat/view/support_chat_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/chat/chat_cubit.dart';
import '../../../services/chat_service.dart';
import 'widgets/conversation_list.dart';
import 'widgets/chat_area.dart';
import 'widgets/user_info_panel.dart';

class SupportChatPage extends StatelessWidget {
  const SupportChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(ChatService())..loadConversations(),
      child: const _SupportChatView(),
    );
  }
}

class _SupportChatView extends StatelessWidget {
  const _SupportChatView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatError) {
          return Center(child: Text('خطأ: ${state.message}'));
        }

        if (state is ChatLoaded) {
          return Row(
            children: [
              // قائمة المحادثات
              SizedBox(
                width: 320,
                child: ConversationList(
                  conversations: state.conversations,
                  selectedConversation: state.selectedConversation,
                  onConversationSelected: (conversation) {
                    context.read<ChatCubit>().selectConversation(conversation);
                  },
                  onFilterChanged: (filter) {
                    context.read<ChatCubit>().filterConversations(filter);
                  },
                ),
              ),

              // منطقة الدردشة
              Expanded(
                child: state.selectedConversation != null
                    ? ChatArea(
                        conversation: state.selectedConversation!,
                        messages: state.messages,
                        onSendMessage: (content) {
                          context.read<ChatCubit>().sendMessage(content: content);
                        },
                        onStatusChanged: (status) {
                          context.read<ChatCubit>().updateStatus(status);
                        },
                      )
                    : const Center(
                        child: Text('اختر محادثة للبدء'),
                      ),
              ),

              // معلومات المستخدم
              if (state.selectedConversation != null)
                SizedBox(
                  width: 300,
                  child: UserInfoPanel(
                    conversation: state.selectedConversation!,
                  ),
                ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }
}
```

---

### الخطوة 7: إعداد Firestore Security Rules

في Firebase Console > Firestore > Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // المحادثات
    match /conversations/{conversationId} {
      // يمكن للمستخدم قراءة محادثاته فقط
      allow read: if request.auth != null &&
        (request.auth.uid == resource.data.userId ||
         request.auth.uid == resource.data.adminId ||
         request.auth.token.admin == true);

      // يمكن للمستخدم إنشاء محادثة
      allow create: if request.auth != null;

      // يمكن للأدمن التحديث
      allow update: if request.auth != null &&
        (request.auth.token.admin == true ||
         request.auth.uid == resource.data.adminId);
    }

    // الرسائل
    match /messages/{messageId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
        request.auth.uid == resource.data.senderId;
    }
  }
}
```

---

### الخطوة 8: هيكل Firestore Database

```
firestore/
├── conversations/
│   └── {conversationId}/
│       ├── oderId: string
│       ├── oderpic: string
│       ├── odertitle: string
│       ├── oderprice: string
│       ├── userId: string
│       ├── adminId: string
│       ├── userName: string
│       ├── userAvatar: string
│       ├── lastMessage: string
│       ├── lastMessageTime: timestamp
│       ├── unreadCount: number
│       ├── isOnline: boolean
│       ├── status: string
│       └── createdAt: timestamp
│
└── messages/
    └── {messageId}/
        ├── conversationId: string
        ├── senderId: string
        ├── content: string
        ├── timestamp: timestamp
        ├── isFromAdmin: boolean
        ├── isRead: boolean
        ├── attachmentUrl: string?
        └── attachmentType: string?
```

---

## الطريقة الثانية: Supabase (بديل مفتوح المصدر)

### الخطوة 1: إعداد Supabase

```yaml
# pubspec.yaml
dependencies:
  supabase_flutter: ^2.3.0
```

### الخطوة 2: تهيئة Supabase

```dart
// lib/main.dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(MyApp());
}
```

### الخطوة 3: إنشاء الجداول في Supabase

```sql
-- جدول المحادثات
CREATE TABLE conversations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  oder_id TEXT,
  oder_pic TEXT,
  oder_title TEXT,
  oder_price TEXT,
  user_id UUID REFERENCES auth.users(id),
  admin_id UUID,
  user_name TEXT NOT NULL,
  user_avatar TEXT,
  last_message TEXT,
  last_message_time TIMESTAMPTZ DEFAULT NOW(),
  unread_count INTEGER DEFAULT 0,
  is_online BOOLEAN DEFAULT false,
  status TEXT DEFAULT 'open',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- جدول الرسائل
CREATE TABLE messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL,
  content TEXT NOT NULL,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  is_from_admin BOOLEAN DEFAULT false,
  is_read BOOLEAN DEFAULT false,
  attachment_url TEXT,
  attachment_type TEXT
);

-- تفعيل Real-time
ALTER TABLE conversations REPLICA IDENTITY FULL;
ALTER TABLE messages REPLICA IDENTITY FULL;

-- إضافة RLS (Row Level Security)
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- سياسات الأمان
CREATE POLICY "Users can view their conversations"
  ON conversations FOR SELECT
  USING (auth.uid() = user_id OR auth.uid() = admin_id);

CREATE POLICY "Users can insert conversations"
  ON conversations FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view messages in their conversations"
  ON messages FOR SELECT
  USING (
    conversation_id IN (
      SELECT id FROM conversations
      WHERE user_id = auth.uid() OR admin_id = auth.uid()
    )
  );
```

### الخطوة 4: Chat Service لـ Supabase

```dart
// lib/services/supabase_chat_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_models.dart';

class SupabaseChatService {
  final SupabaseClient _client = Supabase.instance.client;

  /// جلب المحادثات (Real-time)
  Stream<List<Conversation>> getConversations() {
    return _client
        .from('conversations')
        .stream(primaryKey: ['id'])
        .order('last_message_time', ascending: false)
        .map((data) => data.map((e) => Conversation.fromMap(e)).toList());
  }

  /// جلب الرسائل (Real-time)
  Stream<List<ChatMessage>> getMessages(String conversationId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('timestamp')
        .map((data) => data.map((e) => ChatMessage.fromMap(e)).toList());
  }

  /// إرسال رسالة
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    required bool isFromAdmin,
  }) async {
    await _client.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'is_from_admin': isFromAdmin,
    });

    await _client.from('conversations').update({
      'last_message': content,
      'last_message_time': DateTime.now().toIso8601String(),
    }).eq('id', conversationId);
  }
}
```

---

## ميزات إضافية

### 1. إشعارات Push (Firebase Cloud Messaging)

```dart
// lib/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // طلب الإذن
    await _messaging.requestPermission();

    // الحصول على Token
    final token = await _messaging.getToken();
    print('FCM Token: $token');

    // الاستماع للرسائل
    FirebaseMessaging.onMessage.listen((message) {
      print('رسالة جديدة: ${message.notification?.body}');
    });
  }
}
```

### 2. مؤشر الكتابة (Typing Indicator)

```dart
// في ChatService أضف:

Future<void> setTypingStatus(String conversationId, bool isTyping) {
  return _conversationsRef.doc(conversationId).update({
    'isTyping': isTyping,
    'typingUserId': isTyping ? 'admin_id' : null,
  });
}

Stream<bool> getTypingStatus(String conversationId) {
  return _conversationsRef
      .doc(conversationId)
      .snapshots()
      .map((doc) => doc.data()?['isTyping'] ?? false);
}
```

### 3. رفع المرفقات (Firebase Storage)

```dart
// lib/services/storage_service.dart

import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(File file, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<String> uploadChatAttachment(
    String conversationId,
    File file,
  ) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    return uploadFile(file, 'chat/$conversationId/$fileName');
  }
}
```

---

## ملخص الخطوات

1. ✅ إعداد Firebase/Supabase
2. ✅ إضافة Dependencies
3. ✅ تهيئة في main.dart
4. ✅ إنشاء Models
5. ✅ إنشاء Chat Service
6. ✅ إنشاء Chat Cubit
7. ✅ تحديث UI
8. ✅ إعداد Security Rules
9. ✅ اختبار التطبيق

---

## روابط مفيدة

- [Firebase Flutter Documentation](https://firebase.google.com/docs/flutter/setup)
- [Supabase Flutter Documentation](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- [Flutter BLoC Documentation](https://bloclibrary.dev)
