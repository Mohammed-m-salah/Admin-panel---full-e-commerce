import 'package:core_dashboard/pages/support_chat/data/model/chat_message_model.dart';
import 'package:core_dashboard/pages/support_chat/data/model/chat_room_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ChatRoomModel>> getAllChatRooms() async {
    final response = await _supabase
        .from('chat_rooms')
        .select('''
          *,
          users:user_id (
            id,
            name,
            email,
            avatar
          )
        ''')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ChatRoomModel.fromJson(json))
        .toList();
  }

  Future<List<ChatRoomModel>> getChatRoomsByStatus(String status) async {
    final response = await _supabase
        .from('chat_rooms')
        .select('''
          *,
          users:user_id (
            id,
            name,
            email,
            avatar
          )
        ''')
        .eq('status', status)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ChatRoomModel.fromJson(json))
        .toList();
  }

  Future<ChatRoomModel?> getChatRoomById(String roomId) async {
    final response = await _supabase
        .from('chat_rooms')
        .select('''
          *,
          users:user_id (
            id,
            name,
            email,
            avatar
          )
        ''')
        .eq('id', roomId)
        .maybeSingle();

    if (response == null) return null;
    return ChatRoomModel.fromJson(response);
  }

  Future<ChatRoomModel?> getChatRoomByUserId(String userId) async {
    final response = await _supabase
        .from('chat_rooms')
        .select('''
          *,
          users:user_id (
            id,
            name,
            email,
            avatar
          )
        ''')
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return ChatRoomModel.fromJson(response);
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
  }) async {
    final response = await _supabase
        .from('messages')
        .insert({
          'chat_room_id': chatRoomId,
          'sender_id': senderId,
          'message': message,
          'is_admin': isAdmin,
          'is_read': false,
        })
        .select()
        .single();

    return ChatMessageModel.fromJson(response);
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

  Future<void> deleteMessage(String messageId) async {
    await _supabase.from('messages').delete().eq('id', messageId);
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
