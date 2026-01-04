import 'package:core_dashboard/pages/support_chat/data/model/chat_message_model.dart';
import 'package:core_dashboard/pages/support_chat/data/model/chat_room_model.dart';
import 'package:flutter/material.dart';

class ChatArea extends StatefulWidget {
  final ChatRoomModel? selectedConversation;
  final List<ChatMessageModel> messages;
  final TextEditingController messageController;
  final bool isSending;
  final Function(String) onSendMessage;
  final VoidCallback onAttachFile;
  final Function(String) onStatusChange;

  const ChatArea({
    super.key,
    required this.selectedConversation,
    required this.messages,
    required this.messageController,
    this.isSending = false,
    required this.onSendMessage,
    required this.onAttachFile,
    required this.onStatusChange,
  });

  @override
  State<ChatArea> createState() => _ChatAreaState();
}

class _ChatAreaState extends State<ChatArea> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // التمرير للأسفل بعد بناء الـ widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChatArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    // التمرير للأسفل عند تغيير الرسائل أو تغيير المحادثة
    final messagesChanged = widget.messages.length != oldWidget.messages.length;
    final conversationChanged = widget.selectedConversation?.id != oldWidget.selectedConversation?.id;

    if (messagesChanged || conversationChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedConversation == null) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildChatHeader(),
          const Divider(height: 1),
          Expanded(child: _buildMessagesList()),
          const Divider(height: 1),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.forum_outlined,
                size: 48,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select a conversation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose a conversation from the list to start messaging',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _buildUserInfo(),
          const Spacer(),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    final conversation = widget.selectedConversation!;
    final hasAvatar =
        conversation.userAvatar != null && conversation.userAvatar!.isNotEmpty;

    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF5542F6).withValues(alpha: 0.1),
              backgroundImage:
                  hasAvatar ? NetworkImage(conversation.userAvatar!) : null,
              child: !hasAvatar
                  ? Text(
                      conversation.userInitial,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5542F6),
                      ),
                    )
                  : null,
            ),
            if (conversation.isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              conversation.userName ?? 'User ${conversation.userId?.substring(0, 8) ?? ""}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: conversation.isOnline
                        ? const Color(0xFF10B981)
                        : const Color(0xFF9CA3AF),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  conversation.isOnline ? 'Online now' : 'Offline',
                  style: TextStyle(
                    fontSize: 13,
                    color: conversation.isOnline
                        ? const Color(0xFF10B981)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        _buildStatusDropdown(),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.phone_outlined,
          tooltip: 'Voice Call',
          onPressed: () {},
        ),
        _buildActionButton(
          icon: Icons.videocam_outlined,
          tooltip: 'Video Call',
          onPressed: () {},
        ),
        _buildActionButton(
          icon: Icons.info_outline,
          tooltip: 'Info',
          onPressed: () {},
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
          tooltip: 'More options',
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          itemBuilder: (context) => [
            _buildPopupItem(Icons.block_outlined, 'Block User', 'block'),
            _buildPopupItem(Icons.delete_outline, 'Delete Chat', 'delete'),
            _buildPopupItem(Icons.archive_outlined, 'Archive', 'archive'),
            _buildPopupItem(Icons.flag_outlined, 'Report', 'report'),
          ],
          onSelected: (value) {},
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        color: const Color(0xFF6B7280),
        tooltip: tooltip,
        splashRadius: 20,
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(
      IconData icon, String text, String value) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6B7280)),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown() {
    final statuses = ['Open', 'Pending', 'Resolved'];
    final currentStatus = widget.selectedConversation!.status.isNotEmpty
        ? widget.selectedConversation!.status[0].toUpperCase() +
            widget.selectedConversation!.status.substring(1)
        : 'Open';

    Color statusColor;
    switch (currentStatus.toLowerCase()) {
      case 'open':
        statusColor = const Color(0xFF10B981);
        break;
      case 'pending':
        statusColor = const Color(0xFFF59E0B);
        break;
      case 'resolved':
        statusColor = const Color(0xFF6B7280);
        break;
      default:
        statusColor = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStatus,
          isDense: true,
          icon: Icon(Icons.keyboard_arrow_down, color: statusColor, size: 18),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: statusColor,
          ),
          items: statuses.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.onStatusChange(value.toLowerCase());
            }
          },
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    if (widget.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation by sending a message',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // تجميع الرسائل حسب التاريخ باستخدام الـ extension
    final groupedMessages = widget.messages.groupByDate();
    final sortedDateKeys = groupedMessages.keys.toList();

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: sortedDateKeys.length,
      itemBuilder: (context, dateIndex) {
        final dateKey = sortedDateKeys[dateIndex];
        final messagesForDate = groupedMessages[dateKey]!;

        return Column(
          children: [
            _buildDateSeparatorFromKey(dateKey),
            ...messagesForDate.map((message) => _MessageBubble(
                  message: message,
                  userName: widget.selectedConversation?.userName ?? '',
                )),
          ],
        );
      },
    );
  }

  // بناء فاصل التاريخ من النص
  Widget _buildDateSeparatorFromKey(String dateKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              dateKey,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildInputAction(Icons.attach_file, 'Attach', widget.onAttachFile),
          _buildInputAction(Icons.image_outlined, 'Image', () {}),
          _buildInputAction(Icons.emoji_emotions_outlined, 'Emoji', () {}),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: widget.messageController,
                decoration: const InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.newline,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    widget.onSendMessage(value.trim());
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildInputAction(
      IconData icon, String tooltip, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        color: const Color(0xFF6B7280),
        tooltip: tooltip,
        splashRadius: 20,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: widget.isSending
            ? LinearGradient(
                colors: [
                  const Color(0xFF5542F6).withValues(alpha: 0.6),
                  const Color(0xFF7C3AED).withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF5542F6), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5542F6).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isSending
              ? null
              : () {
                  final text = widget.messageController.text.trim();
                  if (text.isNotEmpty) {
                    widget.onSendMessage(text);
                  }
                },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: widget.isSending
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.send_rounded, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

// ويدجت فقاعة الرسالة
class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final String userName;

  const _MessageBubble({
    required this.message,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = message.isAdmin;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isAdmin) ...[
            _buildAvatar(
              initial: userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              color: const Color(0xFF5542F6),
              icon: Icons.person,
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.5,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? const Color(0xFF5542F6)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isAdmin ? 18 : 4),
                      bottomRight: Radius.circular(isAdmin ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: isAdmin ? Colors.white : const Color(0xFF1F2937),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.formattedTime,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(width: 6),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 14,
                        color: message.isRead
                            ? const Color(0xFF10B981)
                            : const Color(0xFF9CA3AF),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(width: 10),
            _buildAvatar(
              initial: 'A',
              color: const Color(0xFF10B981),
              icon: Icons.support_agent,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar({
    required String initial,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
