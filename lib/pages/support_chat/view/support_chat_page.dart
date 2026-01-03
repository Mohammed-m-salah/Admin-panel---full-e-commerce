import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/conversation_list.dart';
import 'widgets/chat_area.dart';
import 'widgets/user_info_panel.dart';

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final TextEditingController _messageController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  ConversationModel? _selectedConversation;

  // Sample data
  final List<ConversationModel> _allConversations = [
    ConversationModel(
      id: '1001',
      userName: 'Ahmed Hassan',
      userAvatar: '',
      lastMessage: 'I have an issue with my order #12345',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 2)),
      unreadCount: 3,
      isOnline: true,
      status: 'open',
    ),
    ConversationModel(
      id: '1002',
      userName: 'Sarah Johnson',
      userAvatar: '',
      lastMessage: 'When will my refund be processed?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
      unreadCount: 1,
      isOnline: true,
      status: 'pending',
    ),
    ConversationModel(
      id: '1003',
      userName: 'Mohammed Ali',
      userAvatar: '',
      lastMessage: 'Thank you for your help!',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 0,
      isOnline: false,
      status: 'resolved',
    ),
    ConversationModel(
      id: '1004',
      userName: 'Emily Davis',
      userAvatar: '',
      lastMessage: 'The product I received is damaged',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 5,
      isOnline: true,
      status: 'open',
    ),
    ConversationModel(
      id: '1005',
      userName: 'Omar Khalid',
      userAvatar: '',
      lastMessage: 'How can I track my shipment?',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 0,
      isOnline: false,
      status: 'pending',
    ),
    ConversationModel(
      id: '1006',
      userName: 'Lisa Anderson',
      userAvatar: '',
      lastMessage: 'I want to change my delivery address',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
      unreadCount: 2,
      isOnline: false,
      status: 'open',
    ),
    ConversationModel(
      id: '1007',
      userName: 'Yusuf Ibrahim',
      userAvatar: '',
      lastMessage: 'Payment issue resolved, thanks!',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      isOnline: false,
      status: 'resolved',
    ),
    ConversationModel(
      id: '1008',
      userName: 'Maria Garcia',
      userAvatar: '',
      lastMessage: 'Can I get a discount on bulk orders?',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 1,
      isOnline: true,
      status: 'open',
    ),
  ];

  List<ChatMessage> _messages = [];

  List<ConversationModel> get _filteredConversations {
    return _allConversations.where((conv) {
      final matchesSearch = conv.userName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          conv.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == 'All' ||
          conv.status.toLowerCase() == _selectedFilter.toLowerCase();

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _loadMessagesForConversation(ConversationModel conversation) {
    // Sample messages for the selected conversation
    setState(() {
      _messages = [
        ChatMessage(
          id: '1',
          content: 'Hello, I need help with my order',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isFromAdmin: false,
        ),
        ChatMessage(
          id: '2',
          content:
              'Hi! I\'d be happy to help you. Could you please provide your order number?',
          timestamp:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
          isFromAdmin: true,
          isRead: true,
        ),
        ChatMessage(
          id: '3',
          content: 'My order number is #12345',
          timestamp:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
          isFromAdmin: false,
        ),
        ChatMessage(
          id: '4',
          content:
              'Thank you! I can see your order. It was shipped yesterday and should arrive within 2-3 business days.',
          timestamp:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
          isFromAdmin: true,
          isRead: true,
        ),
        ChatMessage(
          id: '5',
          content: 'Can you provide me with the tracking number?',
          timestamp:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          isFromAdmin: false,
        ),
        ChatMessage(
          id: '6',
          content:
              'Of course! Your tracking number is: TRK789456123. You can track it on our website.',
          timestamp:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 25)),
          isFromAdmin: true,
          isRead: true,
        ),
        ChatMessage(
          id: '7',
          content: conversation.lastMessage,
          timestamp: conversation.lastMessageTime,
          isFromAdmin: false,
        ),
      ];
    });
  }

  void _sendMessage(String content) {
    if (content.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        timestamp: DateTime.now(),
        isFromAdmin: true,
        isRead: false,
      ));
    });

    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Expanded(child: _buildChatLayout()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final openCount =
        _allConversations.where((c) => c.status == 'open').length;
    final pendingCount =
        _allConversations.where((c) => c.status == 'pending').length;

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
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined, size: 20),
          label: const Text('Settings'),
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

  Widget _buildChatLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Conversations List
        SizedBox(
          width: 360,
          child: ConversationList(
            conversations: _filteredConversations,
            selectedConversationId: _selectedConversation?.id,
            onConversationSelected: (conversation) {
              setState(() {
                _selectedConversation = conversation;
              });
              _loadMessagesForConversation(conversation);
            },
            searchQuery: _searchQuery,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),
        ),
        const SizedBox(width: 24),
        // Chat Area
        Expanded(
          child: ChatArea(
            selectedConversation: _selectedConversation,
            messages: _messages,
            messageController: _messageController,
            onSendMessage: _sendMessage,
            onAttachFile: () {
              // Handle file attachment
            },
            onStatusChange: (status) {
              if (_selectedConversation != null) {
                setState(() {
                  final index = _allConversations.indexWhere(
                      (c) => c.id == _selectedConversation!.id);
                  if (index != -1) {
                    _allConversations[index] = ConversationModel(
                      id: _selectedConversation!.id,
                      userName: _selectedConversation!.userName,
                      userAvatar: _selectedConversation!.userAvatar,
                      lastMessage: _selectedConversation!.lastMessage,
                      lastMessageTime: _selectedConversation!.lastMessageTime,
                      unreadCount: _selectedConversation!.unreadCount,
                      isOnline: _selectedConversation!.isOnline,
                      status: status,
                    );
                    _selectedConversation = _allConversations[index];
                  }
                });
              }
            },
          ),
        ),
        const SizedBox(width: 24),
        // User Info Panel
        SizedBox(
          width: 300,
          child: UserInfoPanel(conversation: _selectedConversation),
        ),
      ],
    );
  }
}
