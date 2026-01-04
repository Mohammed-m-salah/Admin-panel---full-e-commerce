import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../data/model/chat_room_model.dart';
import '../data/repository/chat_repository.dart';
import '../logic/cubit/chat_cubit.dart';
import '../logic/cubit/chat_state.dart';
import 'widgets/chat_room_list.dart';
import 'widgets/chat_area.dart';
import 'widgets/user_info_panel.dart';

class SupportChatPage extends StatelessWidget {
  const SupportChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(ChatRepository())..subscribeToChatRooms(),
      child: const _SupportChatView(),
    );
  }
}

class _SupportChatView extends StatefulWidget {
  const _SupportChatView();

  @override
  State<_SupportChatView> createState() => _SupportChatViewState();
}

class _SupportChatViewState extends State<_SupportChatView> {
  final TextEditingController _messageController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is ChatOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, state),
                const SizedBox(height: 24),
                Expanded(child: _buildChatLayout(context, state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ChatState state) {
    int openCount = 0;
    int pendingCount = 0;

    if (state is ChatRoomsLoaded) {
      openCount = state.openCount;
      pendingCount = state.pendingCount;
    } else if (state is ChatConversationLoaded) {
      openCount = state.chatRooms.where((r) => r.status == 'open').length;
      pendingCount = state.chatRooms.where((r) => r.status == 'pending').length;
    }

    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/entry-point');
              }
            },
            icon: const Icon(Icons.arrow_back_rounded),
            color: const Color(0xFF6B7280),
            tooltip: 'Back',
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Support Center',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage customer support conversations',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        _buildStatBadge('Open', openCount, const Color(0xFF10B981)),
        const SizedBox(width: 12),
        _buildStatBadge('Pending', pendingCount, const Color(0xFFF59E0B)),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {
            // إعادة تحميل البيانات
            context.read<ChatCubit>().loadChatRooms();
          },
          icon: const Icon(Icons.refresh, size: 20),
          label: const Text('Refresh'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5542F6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatBadge(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count $label',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatLayout(BuildContext context, ChatState state) {
    // حالة التحميل
    if (state is ChatLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF5542F6),
        ),
      );
    }

    // حالة الخطأ الأولي
    if (state is ChatInitial) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF5542F6),
        ),
      );
    }

    // استخراج البيانات من الحالة
    List<ChatRoomModel> chatRooms = [];
    ChatRoomModel? selectedRoom;
    List<dynamic> messages = [];
    String currentFilter = 'All';
    bool isSending = false;

    if (state is ChatRoomsLoaded) {
      chatRooms = state.chatRooms;
      currentFilter = _capitalizeFirst(state.currentFilter);
    } else if (state is ChatConversationLoaded) {
      chatRooms = state.chatRooms;
      selectedRoom = state.selectedRoom;
      messages = state.messages;
      currentFilter = _capitalizeFirst(state.currentFilter);
      isSending = state.isSendingMessage;
    }

    final filteredConversations = chatRooms.where((conv) {
      final matchesSearch = (conv.userName ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (conv.lastMessage ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // قائمة المحادثات
        SizedBox(
          width: 360,
          child: ChatRoomList(
            conversations: filteredConversations,
            selectedConversationId: selectedRoom?.id,
            onConversationSelected: (conversation) {
              context.read<ChatCubit>().selectChatRoom(conversation);
            },
            searchQuery: _searchQuery,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
              if (query.isNotEmpty) {
                context.read<ChatCubit>().searchChatRooms(query);
              } else {
                context.read<ChatCubit>().loadChatRooms();
              }
            },
            selectedFilter: currentFilter,
            onFilterChanged: (filter) {
              context.read<ChatCubit>().filterByStatus(filter.toLowerCase());
            },
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: ChatArea(
            selectedConversation: selectedRoom,
            messages: messages.cast(),
            messageController: _messageController,
            isSending: isSending,
            onSendMessage: (content) {
              if (content.trim().isEmpty) return;
              context.read<ChatCubit>().sendMessage(
                    message: content,
                    adminId: '1055fd29-cae5-4871-8209-ae6dad91bbaf',
                  );
              _messageController.clear();
            },
            onAttachFile: () {
              // TODO: تنفيذ رفع الملفات
            },
            onStatusChange: (status) {
              if (selectedRoom != null) {
                context
                    .read<ChatCubit>()
                    .updateRoomStatus(selectedRoom.id!, status);
              }
            },
          ),
        ),
        const SizedBox(width: 24),
        // لوحة معلومات المستخدم
        SizedBox(
          width: 300,
          child: UserInfoPanel(conversation: selectedRoom),
        ),
      ],
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
