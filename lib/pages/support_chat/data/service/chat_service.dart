import 'dart:async';

import 'package:core_dashboard/pages/support_chat/data/model/chat_message_model.dart';
import 'package:core_dashboard/pages/support_chat/data/model/chat_room_model.dart';

import '../repository/chat_repository.dart';

class ChatService {
  final ChatRepository _repository;

  static ChatService? _instance;
  static ChatService get instance {
    _instance ??= ChatService._internal(ChatRepository());
    return _instance!;
  }

  ChatService._internal(this._repository);

  ChatService(this._repository);

  Future<List<ChatRoomModel>> getAllChatRooms() {
    return _repository.getAllChatRooms();
  }

  Future<List<ChatRoomModel>> getChatRoomsWithDetails() {
    return _repository.getChatRoomsWithDetails();
  }

  Future<List<ChatRoomModel>> getChatRoomsByStatus(ChatRoomStatus status) {
    return _repository.getChatRoomsByStatus(status.value);
  }

  Future<ChatRoomModel?> getChatRoomById(String roomId) {
    return _repository.getChatRoomById(roomId);
  }

  Future<ChatRoomModel> createChatRoom(String userId) {
    return _repository.createChatRoom(userId);
  }

  Future<void> updateRoomStatus(String roomId, ChatRoomStatus status) {
    return _repository.updateChatRoomStatus(roomId, status.value);
  }

  Future<void> assignAdmin(String roomId, String adminId) {
    return _repository.assignAdminToChatRoom(roomId, adminId);
  }

  Future<void> deleteChatRoom(String roomId) {
    return _repository.deleteChatRoom(roomId);
  }

  Future<List<ChatMessageModel>> getMessages(String chatRoomId) {
    return _repository.getMessages(chatRoomId);
  }

  Future<List<ChatMessageModel>> getMessagesPaginated({
    required String chatRoomId,
    int limit = 50,
    int page = 0,
  }) {
    return _repository.getMessagesPaginated(
      chatRoomId: chatRoomId,
      limit: limit,
      offset: page * limit,
    );
  }

  Future<ChatMessageModel> sendAdminMessage({
    required String chatRoomId,
    required String adminId,
    required String message,
  }) {
    return _repository.sendMessage(
      chatRoomId: chatRoomId,
      senderId: adminId,
      message: message,
      isAdmin: true,
    );
  }

  Future<ChatMessageModel> sendUserMessage({
    required String chatRoomId,
    required String userId,
    required String message,
  }) {
    return _repository.sendMessage(
      chatRoomId: chatRoomId,
      senderId: userId,
      message: message,
      isAdmin: false,
    );
  }

  Future<void> markAsRead({
    required String chatRoomId,
    required bool isAdmin,
  }) {
    return _repository.markAllMessagesAsRead(
      chatRoomId: chatRoomId,
      isAdmin: isAdmin,
    );
  }

  /// حذف رسالة
  Future<void> deleteMessage(String messageId) {
    return _repository.deleteMessage(messageId);
  }

  Stream<List<ChatRoomModel>> get chatRoomsStream {
    return _repository.watchChatRooms();
  }

  Stream<List<ChatRoomModel>> chatRoomsByStatusStream(ChatRoomStatus status) {
    return _repository.watchChatRoomsByStatus(status.value);
  }

  Stream<List<ChatMessageModel>> messagesStream(String chatRoomId) {
    return _repository.watchMessages(chatRoomId);
  }

  Stream<Map<String, List<ChatMessageModel>>> groupedMessagesStream(
      String chatRoomId) {
    return messagesStream(chatRoomId).map((messages) => messages.groupByDate());
  }

  Future<int> getTotalUnreadCount() async {
    final rooms = await getAllChatRooms();
    int total = 0;

    for (final room in rooms) {
      total += await _repository.getUnreadCount(
        chatRoomId: room.id!,
        isAdmin: true,
      );
    }

    return total;
  }

  /// عدد غرف المحادثات حسب الحالة
  Future<Map<String, int>> getChatRoomStats() async {
    final all = await getAllChatRooms();

    return {
      'all': all.length,
      'open': all.where((r) => r.status == 'open').length,
      'pending': all.where((r) => r.status == 'pending').length,
      'resolved': all.where((r) => r.status == 'resolved').length,
      'closed': all.where((r) => r.status == 'closed').length,
    };
  }

  Future<List<ChatRoomModel>> searchChatRooms(String query) async {
    if (query.isEmpty) return getAllChatRooms();

    final rooms = await getChatRoomsWithDetails();
    final lowerQuery = query.toLowerCase();

    return rooms.where((room) {
      return (room.userName?.toLowerCase().contains(lowerQuery) ?? false) ||
          (room.userEmail?.toLowerCase().contains(lowerQuery) ?? false) ||
          (room.lastMessage?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}

class ChatRoomWithMessages {
  final ChatRoomModel room;
  final List<ChatMessageModel> messages;

  ChatRoomWithMessages({
    required this.room,
    required this.messages,
  });

  ChatMessageModel? get lastMessage =>
      messages.isNotEmpty ? messages.last : null;

  int get unreadCount => messages.where((m) => !m.isRead && !m.isAdmin).length;

  Map<String, List<ChatMessageModel>> get groupedMessages =>
      messages.groupByDate();
}
