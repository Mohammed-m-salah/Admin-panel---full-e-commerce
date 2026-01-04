import 'package:core_dashboard/pages/support_chat/data/model/chat_message_model.dart';
import 'package:core_dashboard/pages/support_chat/data/model/chat_room_model.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatRoomsLoaded extends ChatState {
  final List<ChatRoomModel> chatRooms;
  final String currentFilter;

  ChatRoomsLoaded({
    required this.chatRooms,
    this.currentFilter = 'all',
  });

  ChatRoomsLoaded copyWith({
    List<ChatRoomModel>? chatRooms,
    String? currentFilter,
  }) {
    return ChatRoomsLoaded(
      chatRooms: chatRooms ?? this.chatRooms,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }

  int get openCount => chatRooms.where((r) => r.status == 'open').length;
  int get pendingCount => chatRooms.where((r) => r.status == 'pending').length;
  int get resolvedCount =>
      chatRooms.where((r) => r.status == 'resolved').length;

  int get totalUnreadCount =>
      chatRooms.fold(0, (sum, room) => sum + room.unreadCount);
}

class ChatConversationLoaded extends ChatState {
  final List<ChatRoomModel> chatRooms;
  final ChatRoomModel selectedRoom;
  final List<ChatMessageModel> messages;
  final bool isSendingMessage;
  final String currentFilter;

  ChatConversationLoaded({
    required this.chatRooms,
    required this.selectedRoom,
    required this.messages,
    this.isSendingMessage = false,
    this.currentFilter = 'all',
  });

  ChatConversationLoaded copyWith({
    List<ChatRoomModel>? chatRooms,
    ChatRoomModel? selectedRoom,
    List<ChatMessageModel>? messages,
    bool? isSendingMessage,
    String? currentFilter,
  }) {
    return ChatConversationLoaded(
      chatRooms: chatRooms ?? this.chatRooms,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      messages: messages ?? this.messages,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }

  Map<String, List<ChatMessageModel>> get groupedMessages =>
      messages.groupByDate();

  int get unreadCount => messages.where((m) => !m.isRead && !m.isAdmin).length;
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);
}

class ChatOperationSuccess extends ChatState {
  final String message;

  ChatOperationSuccess(this.message);
}

class MessageSending extends ChatState {}

class MessageSent extends ChatState {
  final ChatMessageModel message;

  MessageSent(this.message);
}

class MessageError extends ChatState {
  final String error;

  MessageError(this.error);
}
