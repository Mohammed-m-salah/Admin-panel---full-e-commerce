import 'dart:typed_data';

import 'package:core_dashboard/pages/support_chat/data/model/chat_message_model.dart';
import 'package:core_dashboard/pages/support_chat/data/model/chat_room_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _chatBucket = 'chat-media';

  // Cache for user data
  final Map<String, Map<String, dynamic>> _usersCache = {};

  Future<List<ChatRoomModel>> getAllChatRooms() async {
    final response = await _supabase
        .from('chat_rooms')
        .select()
        .order('created_at', ascending: false);

    final rooms = (response as List)
        .map((json) => ChatRoomModel.fromJson(json))
        .toList();

    return _enrichRoomsWithUserData(rooms);
  }

  Future<List<ChatRoomModel>> getChatRoomsByStatus(String status) async {
    final response = await _supabase
        .from('chat_rooms')
        .select()
        .eq('status', status)
        .order('created_at', ascending: false);

    final rooms = (response as List)
        .map((json) => ChatRoomModel.fromJson(json))
        .toList();

    return _enrichRoomsWithUserData(rooms);
  }

  Future<ChatRoomModel?> getChatRoomById(String roomId) async {
    final response = await _supabase
        .from('chat_rooms')
        .select()
        .eq('id', roomId)
        .maybeSingle();

    if (response == null) return null;

    final room = ChatRoomModel.fromJson(response);
    final enrichedRooms = await _enrichRoomsWithUserData([room]);
    return enrichedRooms.isNotEmpty ? enrichedRooms.first : room;
  }

  Future<ChatRoomModel?> getChatRoomByUserId(String userId) async {
    final response = await _supabase
        .from('chat_rooms')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;

    final room = ChatRoomModel.fromJson(response);
    final enrichedRooms = await _enrichRoomsWithUserData([room]);
    return enrichedRooms.isNotEmpty ? enrichedRooms.first : room;
  }

  /// جلب بيانات المستخدمين وإضافتها للغرف
  Future<List<ChatRoomModel>> _enrichRoomsWithUserData(
      List<ChatRoomModel> rooms) async {
    if (rooms.isEmpty) return rooms;

    // جمع كل user_ids الفريدة التي ليست في الكاش
    final userIds = rooms
        .where((r) => r.userId != null && !_usersCache.containsKey(r.userId))
        .map((r) => r.userId!)
        .toSet()
        .toList();

    if (userIds.isNotEmpty) {
      try {
        // جلب بيانات المستخدمين دفعة واحدة
        final usersResponse = await _supabase
            .from('users')
            .select('id, display_name, email, avatar')
            .inFilter('id', userIds);

        // إضافة للكاش
        for (final user in (usersResponse as List)) {
          _usersCache[user['id'].toString()] = user;
        }
      } catch (e) {
        // في حالة فشل جلب بيانات المستخدمين، نستمر بدون البيانات
      }
    }

    // إضافة بيانات المستخدم لكل غرفة من الكاش
    return rooms.map((room) {
      if (room.userId != null && _usersCache.containsKey(room.userId)) {
        final userData = _usersCache[room.userId]!;
        return room.copyWith(
          userName: userData['display_name'],
          userEmail: userData['email'],
          userAvatar: userData['avatar'],
        );
      }
      return room;
    }).toList();
  }

  Future<ChatRoomModel> createChatRoom(String userId) async {
    final response = await _supabase
        .from('chat_rooms')
        .insert({
          'user_id': userId,
          'status': 'open',
        })
        .select()
        .single();

    return ChatRoomModel.fromJson(response);
  }

  Future<void> updateChatRoomStatus(String roomId, String status) async {
    await _supabase
        .from('chat_rooms')
        .update({'status': status}).eq('id', roomId);
  }

  Future<void> assignAdminToChatRoom(String roomId, String adminId) async {
    await _supabase
        .from('chat_rooms')
        .update({'admin_id': adminId}).eq('id', roomId);
  }

  Future<void> deleteChatRoom(String roomId) async {
    await _supabase.from('messages').delete().eq('chat_room_id', roomId);
    await _supabase.from('chat_rooms').delete().eq('id', roomId);
  }

  Future<List<ChatMessageModel>> getMessages(String chatRoomId) async {
    final response = await _supabase
        .from('messages')
        .select()
        .eq('chat_room_id', chatRoomId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => ChatMessageModel.fromJson(json))
        .toList();
  }

  Future<List<ChatMessageModel>> getMessagesPaginated({
    required String chatRoomId,
    required int limit,
    required int offset,
  }) async {
    final response = await _supabase
        .from('messages')
        .select()
        .eq('chat_room_id', chatRoomId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => ChatMessageModel.fromJson(json))
        .toList()
        .reversed
        .toList();
  }

  Future<ChatMessageModel> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String message,
    required bool isAdmin,
    MessageType messageType = MessageType.text,
    String? mediaUrl,
    String? fileName,
    int? fileSize,
    int? audioDuration,
  }) async {
    final response = await _supabase
        .from('messages')
        .insert({
          'chat_room_id': chatRoomId,
          'sender_id': senderId,
          'message': message,
          'is_admin': isAdmin,
          'is_read': false,
          'message_type': messageType.value,
          if (mediaUrl != null) 'media_url': mediaUrl,
          if (fileName != null) 'file_name': fileName,
          if (fileSize != null) 'file_size_bytes': fileSize,
          if (audioDuration != null) 'voice_duration_seconds': audioDuration,
        })
        .select()
        .single();

    return ChatMessageModel.fromJson(response);
  }

  Future<String> uploadFile({
    required String chatRoomId,
    required String fileName,
    required Uint8List fileBytes,
    required String folder,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '$chatRoomId/$folder/${timestamp}_$fileName';

    await _supabase.storage.from(_chatBucket).uploadBinary(
          path,
          fileBytes,
          fileOptions: const FileOptions(upsert: true),
        );

    final url = _supabase.storage.from(_chatBucket).getPublicUrl(path);
    return url;
  }

  Future<String> uploadImage({
    required String chatRoomId,
    required String fileName,
    required Uint8List imageBytes,
  }) async {
    return uploadFile(
      chatRoomId: chatRoomId,
      fileName: fileName,
      fileBytes: imageBytes,
      folder: 'images',
    );
  }

  Future<String> uploadVoice({
    required String chatRoomId,
    required String fileName,
    required Uint8List audioBytes,
  }) async {
    return uploadFile(
      chatRoomId: chatRoomId,
      fileName: fileName,
      fileBytes: audioBytes,
      folder: 'voices',
    );
  }

  Future<String> uploadAttachment({
    required String chatRoomId,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    return uploadFile(
      chatRoomId: chatRoomId,
      fileName: fileName,
      fileBytes: fileBytes,
      folder: 'files',
    );
  }

  Future<ChatMessageModel> sendImageMessage({
    required String chatRoomId,
    required String senderId,
    required bool isAdmin,
    required String imageUrl,
    required String fileName,
    required int fileSize,
  }) async {
    return sendMessage(
      chatRoomId: chatRoomId,
      senderId: senderId,
      message: fileName,
      isAdmin: isAdmin,
      messageType: MessageType.image,
      mediaUrl: imageUrl,
      fileName: fileName,
      fileSize: fileSize,
    );
  }

  Future<ChatMessageModel> sendVoiceMessage({
    required String chatRoomId,
    required String senderId,
    required bool isAdmin,
    required String voiceUrl,
    required int duration,
    required int fileSize,
  }) async {
    return sendMessage(
      chatRoomId: chatRoomId,
      senderId: senderId,
      message: 'Voice message',
      isAdmin: isAdmin,
      messageType: MessageType.voice,
      mediaUrl: voiceUrl,
      audioDuration: duration,
      fileSize: fileSize,
    );
  }

  Future<ChatMessageModel> sendFileMessage({
    required String chatRoomId,
    required String senderId,
    required bool isAdmin,
    required String fileUrl,
    required String fileName,
    required int fileSize,
  }) async {
    return sendMessage(
      chatRoomId: chatRoomId,
      senderId: senderId,
      message: fileName,
      isAdmin: isAdmin,
      messageType: MessageType.file,
      mediaUrl: fileUrl,
      fileName: fileName,
      fileSize: fileSize,
    );
  }

  Future<void> markMessageAsRead(String messageId) async {
    await _supabase
        .from('messages')
        .update({'is_read': true}).eq('id', messageId);
  }

  Future<void> markAllMessagesAsRead({
    required String chatRoomId,
    required bool isAdmin,
  }) async {
    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('chat_room_id', chatRoomId)
        .eq('is_admin', !isAdmin)
        .eq('is_read', false);
  }

  /// حذف رسالة واحدة (soft delete)
  Future<void> deleteMessage(String messageId) async {
    await _supabase
        .from('messages')
        .update({'is_deleted': true})
        .eq('id', messageId);
  }

  /// حذف عدة رسائل (soft delete)
  Future<void> deleteMultipleMessages(List<String> messageIds) async {
    for (final id in messageIds) {
      await _supabase
          .from('messages')
          .update({'is_deleted': true})
          .eq('id', id);
    }
  }

  /// حذف جميع رسائل غرفة معينة (soft delete)
  Future<void> deleteAllMessagesInRoom(String chatRoomId) async {
    await _supabase
        .from('messages')
        .update({'is_deleted': true})
        .eq('chat_room_id', chatRoomId);
  }

  Future<int> getUnreadCount({
    required String chatRoomId,
    required bool isAdmin,
  }) async {
    final response = await _supabase
        .from('messages')
        .select()
        .eq('chat_room_id', chatRoomId)
        .eq('is_admin', !isAdmin)
        .eq('is_read', false);

    return (response as List).length;
  }

  Future<ChatMessageModel?> getLastMessage(String chatRoomId) async {
    final response = await _supabase
        .from('messages')
        .select()
        .eq('chat_room_id', chatRoomId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return ChatMessageModel.fromJson(response);
  }

  Stream<List<ChatRoomModel>> watchChatRooms() {
    return _supabase
        .from('chat_rooms')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => ChatRoomModel.fromJson(e)).toList());
  }

  Stream<List<ChatRoomModel>> watchChatRoomsByStatus(String status) {
    return _supabase
        .from('chat_rooms')
        .stream(primaryKey: ['id'])
        .eq('status', status)
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => ChatRoomModel.fromJson(e)).toList());
  }

  Stream<List<ChatMessageModel>> watchMessages(String chatRoomId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_room_id', chatRoomId)
        .order('created_at')
        .map((data) => data.map((e) => ChatMessageModel.fromJson(e)).toList());
  }

  /// إرسال إشعار push للمستخدم عبر Edge Function
  Future<void> sendPushNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      await _supabase.functions.invoke(
        'dynamic-function',
        body: {
          'user_id': userId,
          'title': title,
          'body': body,
        },
      );
    } catch (e) {
      // لا نريد أن يفشل إرسال الرسالة إذا فشل الإشعار
      print('Failed to send push notification: $e');
    }
  }

  Future<List<ChatRoomModel>> getChatRoomsWithDetails() async {
    final rooms = await getAllChatRooms();
    final List<ChatRoomModel> result = [];

    for (final room in rooms) {
      final lastMessage = await getLastMessage(room.id!);
      final unreadCount = await getUnreadCount(
        chatRoomId: room.id!,
        isAdmin: true,
      );

      result.add(room.copyWith(
        lastMessage: lastMessage?.message,
        lastMessageTime: lastMessage?.createdAt,
        unreadCount: unreadCount,
      ));
    }

    result.sort((a, b) {
      if (a.lastMessageTime == null) return 1;
      if (b.lastMessageTime == null) return -1;
      return b.lastMessageTime!.compareTo(a.lastMessageTime!);
    });

    return result;
  }
}
