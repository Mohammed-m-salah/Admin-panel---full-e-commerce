import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/chat_room_model.dart';
import '../../data/repository/chat_repository.dart';
import 'chat_state.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Chat Cubit - إدارة حالة الدردشة
/// ═══════════════════════════════════════════════════════════════════════════
/// يدير:
/// - قائمة غرف المحادثات
/// - المحادثة المفتوحة حاليًا
/// - الرسائل
/// - Real-time subscriptions
/// ═══════════════════════════════════════════════════════════════════════════

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;

  // Subscriptions للـ Real-time
  StreamSubscription? _chatRoomsSubscription;
  StreamSubscription? _messagesSubscription;

  // الغرفة المحددة حاليًا
  String? _selectedRoomId;

  // الفلتر الحالي
  String _currentFilter = 'all';

  ChatCubit(this._repository) : super(ChatInitial());

  // ═══════════════════════════════════════════════════════════════════════════
  // تحميل غرف المحادثات
  // ═══════════════════════════════════════════════════════════════════════════

  /// تحميل جميع غرف المحادثات
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

  /// الاستماع لغرف المحادثات (Real-time)
  void subscribeToChatRooms() {
    emit(ChatLoading());

    _chatRoomsSubscription?.cancel();
    _chatRoomsSubscription = _repository.watchChatRooms().listen(
      (chatRooms) async {
        // إضافة تفاصيل آخر رسالة وعدد غير المقروء
        final detailedRooms = await _addDetailsToRooms(chatRooms);

        final currentState = state;
        if (currentState is ChatConversationLoaded) {
          // إذا كانت محادثة مفتوحة، نحافظ عليها
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

  /// إضافة تفاصيل (آخر رسالة + غير مقروء) للغرف
  Future<List<ChatRoomModel>> _addDetailsToRooms(
      List<ChatRoomModel> rooms) async {
    final List<ChatRoomModel> result = [];

    for (final room in rooms) {
      final lastMessage = await _repository.getLastMessage(room.id!);
      final unreadCount = await _repository.getUnreadCount(
        chatRoomId: room.id!,
        isAdmin: true,
      );

      result.add(room.copyWith(
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

  // ═══════════════════════════════════════════════════════════════════════════
  // فلترة غرف المحادثات
  // ═══════════════════════════════════════════════════════════════════════════

  /// فلترة حسب الحالة
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

  // ═══════════════════════════════════════════════════════════════════════════
  // اختيار محادثة
  // ═══════════════════════════════════════════════════════════════════════════

  /// فتح محادثة وتحميل رسائلها
  Future<void> selectChatRoom(ChatRoomModel room) async {
    _selectedRoomId = room.id;

    try {
      // جلب الرسائل
      final messages = await _repository.getMessages(room.id!);

      // تحديث حالة القراءة
      await _repository.markAllMessagesAsRead(
        chatRoomId: room.id!,
        isAdmin: true,
      );

      // الحصول على قائمة الغرف الحالية
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

      // الاستماع للرسائل الجديدة
      _subscribeToMessages(room.id!);
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  /// الاستماع لرسائل غرفة معينة (Real-time)
  void _subscribeToMessages(String chatRoomId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _repository.watchMessages(chatRoomId).listen(
      (messages) {
        final currentState = state;
        if (currentState is ChatConversationLoaded) {
          emit(currentState.copyWith(messages: messages));

          // تحديث حالة القراءة للرسائل الجديدة
          _repository.markAllMessagesAsRead(
            chatRoomId: chatRoomId,
            isAdmin: true,
          );
        }
      },
      onError: (error) => emit(ChatError(error.toString())),
    );
  }

  /// إغلاق المحادثة والعودة للقائمة
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

  // ═══════════════════════════════════════════════════════════════════════════
  // إرسال الرسائل
  // ═══════════════════════════════════════════════════════════════════════════

  /// إرسال رسالة جديدة
  Future<void> sendMessage({
    required String message,
    required String adminId,
  }) async {
    if (_selectedRoomId == null) return;

    final currentState = state;
    if (currentState is! ChatConversationLoaded) return;

    // تحديث الحالة لإظهار جاري الإرسال
    emit(currentState.copyWith(isSendingMessage: true));

    try {
      // إرسال الرسالة إلى قاعدة البيانات
      final newMessage = await _repository.sendMessage(
        chatRoomId: _selectedRoomId!,
        senderId: adminId,
        message: message,
        isAdmin: true,
      );

      // الحصول على الحالة الحالية (قد تكون تغيرت بسبب الـ Stream)
      final updatedState = state;
      if (updatedState is ChatConversationLoaded) {
        // إضافة الرسالة الجديدة إذا لم تكن موجودة بالفعل (من الـ Stream)
        final messageExists = updatedState.messages.any((m) => m.id == newMessage.id);
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
      // في حالة الخطأ، نحصل على الحالة الحالية
      final errorState = state;
      if (errorState is ChatConversationLoaded) {
        emit(errorState.copyWith(isSendingMessage: false));
      }
      emit(ChatError('فشل إرسال الرسالة: ${e.toString()}'));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تحديث حالة الغرفة
  // ═══════════════════════════════════════════════════════════════════════════

  /// تحديث حالة المحادثة
  Future<void> updateRoomStatus(String roomId, String status) async {
    try {
      await _repository.updateChatRoomStatus(roomId, status);
      emit(ChatOperationSuccess('تم تحديث حالة المحادثة'));

      // إعادة تحميل الغرف
      await loadChatRooms();
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  /// تعيين أدمن للمحادثة
  Future<void> assignAdmin(String roomId, String adminId) async {
    try {
      await _repository.assignAdminToChatRoom(roomId, adminId);
      emit(ChatOperationSuccess('تم تعيين المسؤول'));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // البحث
  // ═══════════════════════════════════════════════════════════════════════════

  /// البحث في المحادثات
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

  // ═══════════════════════════════════════════════════════════════════════════
  // حذف
  // ═══════════════════════════════════════════════════════════════════════════

  /// حذف رسالة
  Future<void> deleteMessage(String messageId) async {
    try {
      await _repository.deleteMessage(messageId);
      emit(ChatOperationSuccess('تم حذف الرسالة'));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  /// حذف محادثة
  Future<void> deleteChatRoom(String roomId) async {
    try {
      await _repository.deleteChatRoom(roomId);
      emit(ChatOperationSuccess('تم حذف المحادثة'));

      // إغلاق المحادثة إذا كانت مفتوحة
      if (_selectedRoomId == roomId) {
        closeChatRoom();
      }

      await loadChatRooms();
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Getters
  // ═══════════════════════════════════════════════════════════════════════════

  /// الغرفة المحددة حاليًا
  String? get selectedRoomId => _selectedRoomId;

  /// الفلتر الحالي
  String get currentFilter => _currentFilter;

  // ═══════════════════════════════════════════════════════════════════════════
  // Cleanup
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> close() {
    _chatRoomsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }
}
