import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/chat_room_model.dart';
import '../../data/repository/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;

  StreamSubscription? _chatRoomsSubscription;
  StreamSubscription? _messagesSubscription;

  String? _selectedRoomId;

  String _currentFilter = 'all';

  ChatCubit(this._repository) : super(ChatInitial());

  Future<void> loadChatRooms() async {
    emit(ChatLoading());
    try {
      final chatRooms = await _repository.getChatRoomsWithDetails();
      emit(ChatRoomsLoaded(
        chatRooms: chatRooms,
        currentFilter: _currentFilter,
      ));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void subscribeToChatRooms() {
    emit(ChatLoading());

    _chatRoomsSubscription?.cancel();
    _chatRoomsSubscription = _repository.watchChatRooms().listen(
      (chatRooms) async {
        final detailedRooms = await _addDetailsToRooms(chatRooms);

        final currentState = state;
        if (currentState is ChatConversationLoaded) {
          emit(currentState.copyWith(
            chatRooms: detailedRooms,
            currentFilter: _currentFilter,
          ));
        } else {
          emit(ChatRoomsLoaded(
            chatRooms: detailedRooms,
            currentFilter: _currentFilter,
          ));
        }
      },
      onError: (error) => emit(ChatError(error.toString())),
    );
  }

  /// إضافة تفاصيل (آخر رسالة + غير مقروء + بيانات المستخدم) للغرف
  Future<List<ChatRoomModel>> _addDetailsToRooms(
      List<ChatRoomModel> rooms) async {
    final List<ChatRoomModel> result = [];

    for (final room in rooms) {
      final lastMessage = await _repository.getLastMessage(room.id!);
      final unreadCount = await _repository.getUnreadCount(
        chatRoomId: room.id!,
        isAdmin: true,
      );

      // إذا لم تكن بيانات المستخدم موجودة، نجلبها من قاعدة البيانات
      ChatRoomModel updatedRoom = room;
      if (room.userName == null || room.userName!.isEmpty) {
        final fullRoom = await _repository.getChatRoomById(room.id!);
        if (fullRoom != null) {
          updatedRoom = fullRoom;
        }
      }

      result.add(updatedRoom.copyWith(
        lastMessage: lastMessage?.message,
        lastMessageTime: lastMessage?.createdAt,
        unreadCount: unreadCount,
      ));
    }

    // ترتيب حسب آخر رسالة
    result.sort((a, b) {
      if (a.lastMessageTime == null) return 1;
      if (b.lastMessageTime == null) return -1;
      return b.lastMessageTime!.compareTo(a.lastMessageTime!);
    });

    return result;
  }

  Future<void> filterByStatus(String status) async {
    _currentFilter = status;

    try {
      List<ChatRoomModel> chatRooms;

      if (status == 'all') {
        chatRooms = await _repository.getChatRoomsWithDetails();
      } else {
        chatRooms = await _repository.getChatRoomsByStatus(status);
        chatRooms = await _addDetailsToRooms(chatRooms);
      }

      final currentState = state;
      if (currentState is ChatConversationLoaded) {
        emit(currentState.copyWith(
          chatRooms: chatRooms,
          currentFilter: status,
        ));
      } else {
        emit(ChatRoomsLoaded(
          chatRooms: chatRooms,
          currentFilter: status,
        ));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> selectChatRoom(ChatRoomModel room) async {
    _selectedRoomId = room.id;

    try {
      final messages = await _repository.getMessages(room.id!);

      await _repository.markAllMessagesAsRead(
        chatRoomId: room.id!,
        isAdmin: true,
      );

      List<ChatRoomModel> currentRooms = [];
      final currentState = state;
      if (currentState is ChatRoomsLoaded) {
        currentRooms = currentState.chatRooms;
      } else if (currentState is ChatConversationLoaded) {
        currentRooms = currentState.chatRooms;
      }

      emit(ChatConversationLoaded(
        chatRooms: currentRooms,
        selectedRoom: room.copyWith(unreadCount: 0),
        messages: messages,
        currentFilter: _currentFilter,
      ));

      _subscribeToMessages(room.id!);
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _subscribeToMessages(String chatRoomId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _repository.watchMessages(chatRoomId).listen(
      (messages) {
        final currentState = state;
        if (currentState is ChatConversationLoaded) {
          emit(currentState.copyWith(messages: messages));

          _repository.markAllMessagesAsRead(
            chatRoomId: chatRoomId,
            isAdmin: true,
          );
        }
      },
      onError: (error) => emit(ChatError(error.toString())),
    );
  }

  void closeChatRoom() {
    _selectedRoomId = null;
    _messagesSubscription?.cancel();

    final currentState = state;
    if (currentState is ChatConversationLoaded) {
      emit(ChatRoomsLoaded(
        chatRooms: currentState.chatRooms,
        currentFilter: _currentFilter,
      ));
    }
  }

  Future<void> sendMessage({
    required String message,
    required String adminId,
  }) async {
    if (_selectedRoomId == null) return;

    final currentState = state;
    if (currentState is! ChatConversationLoaded) return;

    emit(currentState.copyWith(isSendingMessage: true));

    try {
      final newMessage = await _repository.sendMessage(
        chatRoomId: _selectedRoomId!,
        senderId: adminId,
        message: message,
        isAdmin: true,
      );

      final updatedState = state;
      if (updatedState is ChatConversationLoaded) {
        final messageExists =
            updatedState.messages.any((m) => m.id == newMessage.id);
        if (!messageExists) {
          final updatedMessages = [...updatedState.messages, newMessage];
          emit(updatedState.copyWith(
            messages: updatedMessages,
            isSendingMessage: false,
          ));
        } else {
          emit(updatedState.copyWith(isSendingMessage: false));
        }
      }
    } catch (e) {
      final errorState = state;
      if (errorState is ChatConversationLoaded) {
        emit(errorState.copyWith(isSendingMessage: false));
      }
      emit(ChatError('فشل إرسال الرسالة: ${e.toString()}'));
    }
  }

  /// إرسال صورة
  Future<void> sendImage({
    required String adminId,
    required String fileName,
    required Uint8List imageBytes,
    required int fileSize,
  }) async {
    if (_selectedRoomId == null) return;

    final currentState = state;
    if (currentState is! ChatConversationLoaded) return;

    emit(currentState.copyWith(isSendingMessage: true));

    try {
      final imageUrl = await _repository.uploadImage(
        chatRoomId: _selectedRoomId!,
        fileName: fileName,
        imageBytes: imageBytes,
      );

      final newMessage = await _repository.sendImageMessage(
        chatRoomId: _selectedRoomId!,
        senderId: adminId,
        isAdmin: true,
        imageUrl: imageUrl,
        fileName: fileName,
        fileSize: fileSize,
      );

      final updatedState = state;
      if (updatedState is ChatConversationLoaded) {
        final messageExists =
            updatedState.messages.any((m) => m.id == newMessage.id);
        if (!messageExists) {
          final updatedMessages = [...updatedState.messages, newMessage];
          emit(updatedState.copyWith(
            messages: updatedMessages,
            isSendingMessage: false,
          ));
        } else {
          emit(updatedState.copyWith(isSendingMessage: false));
        }
      }
    } catch (e) {
      final errorState = state;
      if (errorState is ChatConversationLoaded) {
        emit(errorState.copyWith(isSendingMessage: false));
      }
      emit(ChatError('فشل إرسال الصورة: ${e.toString()}'));
    }
  }

  Future<void> sendVoice({
    required String adminId,
    required String fileName,
    required Uint8List audioBytes,
    required int duration,
    required int fileSize,
  }) async {
    if (_selectedRoomId == null) return;

    final currentState = state;
    if (currentState is! ChatConversationLoaded) return;

    emit(currentState.copyWith(isSendingMessage: true));

    try {
      final voiceUrl = await _repository.uploadVoice(
        chatRoomId: _selectedRoomId!,
        fileName: fileName,
        audioBytes: audioBytes,
      );

      final newMessage = await _repository.sendVoiceMessage(
        chatRoomId: _selectedRoomId!,
        senderId: adminId,
        isAdmin: true,
        voiceUrl: voiceUrl,
        duration: duration,
        fileSize: fileSize,
      );

      final updatedState = state;
      if (updatedState is ChatConversationLoaded) {
        final messageExists =
            updatedState.messages.any((m) => m.id == newMessage.id);
        if (!messageExists) {
          final updatedMessages = [...updatedState.messages, newMessage];
          emit(updatedState.copyWith(
            messages: updatedMessages,
            isSendingMessage: false,
          ));
        } else {
          emit(updatedState.copyWith(isSendingMessage: false));
        }
      }
    } catch (e) {
      final errorState = state;
      if (errorState is ChatConversationLoaded) {
        emit(errorState.copyWith(isSendingMessage: false));
      }
      emit(ChatError('فشل إرسال الرسالة الصوتية: ${e.toString()}'));
    }
  }

  Future<void> sendFile({
    required String adminId,
    required String fileName,
    required Uint8List fileBytes,
    required int fileSize,
  }) async {
    if (_selectedRoomId == null) return;

    final currentState = state;
    if (currentState is! ChatConversationLoaded) return;

    emit(currentState.copyWith(isSendingMessage: true));

    try {
      final fileUrl = await _repository.uploadAttachment(
        chatRoomId: _selectedRoomId!,
        fileName: fileName,
        fileBytes: fileBytes,
      );

      final newMessage = await _repository.sendFileMessage(
        chatRoomId: _selectedRoomId!,
        senderId: adminId,
        isAdmin: true,
        fileUrl: fileUrl,
        fileName: fileName,
        fileSize: fileSize,
      );

      final updatedState = state;
      if (updatedState is ChatConversationLoaded) {
        final messageExists =
            updatedState.messages.any((m) => m.id == newMessage.id);
        if (!messageExists) {
          final updatedMessages = [...updatedState.messages, newMessage];
          emit(updatedState.copyWith(
            messages: updatedMessages,
            isSendingMessage: false,
          ));
        } else {
          emit(updatedState.copyWith(isSendingMessage: false));
        }
      }
    } catch (e) {
      final errorState = state;
      if (errorState is ChatConversationLoaded) {
        emit(errorState.copyWith(isSendingMessage: false));
      }
      emit(ChatError('فشل إرسال الملف: ${e.toString()}'));
    }
  }

  Future<void> updateRoomStatus(String roomId, String status) async {
    try {
      await _repository.updateChatRoomStatus(roomId, status);
      emit(ChatOperationSuccess('تم تحديث حالة المحادثة'));

      await loadChatRooms();
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> assignAdmin(String roomId, String adminId) async {
    try {
      await _repository.assignAdminToChatRoom(roomId, adminId);
      emit(ChatOperationSuccess('تم تعيين المسؤول'));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> searchChatRooms(String query) async {
    if (query.isEmpty) {
      await loadChatRooms();
      return;
    }

    try {
      final allRooms = await _repository.getChatRoomsWithDetails();
      final lowerQuery = query.toLowerCase();

      final filtered = allRooms.where((room) {
        return (room.userName?.toLowerCase().contains(lowerQuery) ?? false) ||
            (room.userEmail?.toLowerCase().contains(lowerQuery) ?? false) ||
            (room.lastMessage?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();

      final currentState = state;
      if (currentState is ChatConversationLoaded) {
        emit(currentState.copyWith(chatRooms: filtered));
      } else {
        emit(ChatRoomsLoaded(
          chatRooms: filtered,
          currentFilter: _currentFilter,
        ));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _repository.deleteMessage(messageId);

      // تحديث الرسائل محلياً
      final currentState = state;
      if (currentState is ChatConversationLoaded) {
        final updatedMessages = currentState.messages.map((m) {
          if (m.id == messageId) {
            return m.copyWith(isDeleted: true);
          }
          return m;
        }).toList();

        emit(currentState.copyWith(
          messages: updatedMessages,
          isSelectionMode: false,
          selectedMessageIds: {},
        ));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void enableSelectionMode(String? initialMessageId) {
    final currentState = state;
    if (currentState is ChatConversationLoaded) {
      emit(currentState.copyWith(
        isSelectionMode: true,
        selectedMessageIds: initialMessageId != null ? {initialMessageId} : {},
      ));
    }
  }

  /// إلغاء وضع التحديد
  void cancelSelectionMode() {
    final currentState = state;
    if (currentState is ChatConversationLoaded) {
      emit(currentState.copyWith(
        isSelectionMode: false,
        selectedMessageIds: {},
      ));
    }
  }

  /// تحديد/إلغاء تحديد رسالة
  void toggleMessageSelection(String messageId) {
    final currentState = state;
    if (currentState is ChatConversationLoaded) {
      final newSelection = Set<String>.from(currentState.selectedMessageIds);

      if (newSelection.contains(messageId)) {
        newSelection.remove(messageId);
      } else {
        newSelection.add(messageId);
      }

      if (newSelection.isEmpty) {
        emit(currentState.copyWith(
          isSelectionMode: false,
          selectedMessageIds: {},
        ));
      } else {
        emit(currentState.copyWith(selectedMessageIds: newSelection));
      }
    }
  }

  void selectAllMessages() {
    final currentState = state;
    if (currentState is ChatConversationLoaded) {
      final allIds = currentState.messages
          .where((m) => !m.isDeleted)
          .map((m) => m.id!)
          .toSet();

      emit(currentState.copyWith(selectedMessageIds: allIds));
    }
  }

  void deselectAllMessages() {
    final currentState = state;
    if (currentState is ChatConversationLoaded) {
      emit(currentState.copyWith(selectedMessageIds: {}));
    }
  }

  Future<void> deleteSelectedMessages() async {
    final currentState = state;
    if (currentState is! ChatConversationLoaded) return;

    if (currentState.selectedMessageIds.isEmpty) return;

    try {
      await _repository
          .deleteMultipleMessages(currentState.selectedMessageIds.toList());

      final updatedMessages = currentState.messages.map((m) {
        if (currentState.selectedMessageIds.contains(m.id)) {
          return m.copyWith(isDeleted: true);
        }
        return m;
      }).toList();

      emit(currentState.copyWith(
        messages: updatedMessages,
        isSelectionMode: false,
        selectedMessageIds: {},
      ));
    } catch (e) {
      emit(ChatError('فشل حذف الرسائل: ${e.toString()}'));
    }
  }

  Future<void> deleteAllMessagesInCurrentRoom() async {
    if (_selectedRoomId == null) return;

    final currentState = state;
    if (currentState is! ChatConversationLoaded) return;

    try {
      await _repository.deleteAllMessagesInRoom(_selectedRoomId!);

      final updatedMessages = currentState.messages.map((m) {
        return m.copyWith(isDeleted: true);
      }).toList();

      emit(currentState.copyWith(
        messages: updatedMessages,
        isSelectionMode: false,
        selectedMessageIds: {},
      ));
    } catch (e) {
      emit(ChatError('فشل حذف جميع الرسائل: ${e.toString()}'));
    }
  }

  Future<void> deleteChatRoom(String roomId) async {
    try {
      await _repository.deleteChatRoom(roomId);
      emit(ChatOperationSuccess('تم حذف المحادثة'));

      if (_selectedRoomId == roomId) {
        closeChatRoom();
      }

      await loadChatRooms();
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  String? get selectedRoomId => _selectedRoomId;

  String get currentFilter => _currentFilter;

  @override
  Future<void> close() {
    _chatRoomsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }
}
