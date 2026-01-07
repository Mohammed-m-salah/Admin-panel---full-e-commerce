import 'dart:typed_data';

import 'package:core_dashboard/pages/support_chat/data/model/chat_message_model.dart';
import 'package:core_dashboard/pages/support_chat/data/model/chat_room_model.dart';
import 'package:core_dashboard/pages/support_chat/view/widgets/attachment_options.dart';
import 'package:core_dashboard/pages/support_chat/view/widgets/audio_player_widget.dart';
import 'package:core_dashboard/pages/support_chat/view/widgets/voice_recorder_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatArea extends StatefulWidget {
  final ChatRoomModel? selectedConversation;
  final List<ChatMessageModel> messages;
  final TextEditingController messageController;
  final bool isSending;
  final Function(String) onSendMessage;
  final VoidCallback onAttachFile;
  final Function(String) onStatusChange;
  final Function(String fileName, Uint8List bytes, int size)? onSendImage;
  final Function(Uint8List bytes, int duration)? onSendVoice;
  final Function(String fileName, Uint8List bytes, int size)? onSendFile;

  // Selection mode properties
  final bool isSelectionMode;
  final Set<String> selectedMessageIds;
  final Function(String?)? onEnableSelectionMode;
  final VoidCallback? onCancelSelectionMode;
  final Function(String)? onToggleMessageSelection;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDeleteSelected;
  final Function(String)? onDeleteMessage;

  const ChatArea({
    super.key,
    required this.selectedConversation,
    required this.messages,
    required this.messageController,
    this.isSending = false,
    required this.onSendMessage,
    required this.onAttachFile,
    required this.onStatusChange,
    this.onSendImage,
    this.onSendVoice,
    this.onSendFile,
    this.isSelectionMode = false,
    this.selectedMessageIds = const {},
    this.onEnableSelectionMode,
    this.onCancelSelectionMode,
    this.onToggleMessageSelection,
    this.onSelectAll,
    this.onDeleteSelected,
    this.onDeleteMessage,
  });

  @override
  State<ChatArea> createState() => _ChatAreaState();
}

class _ChatAreaState extends State<ChatArea> {
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isRecordingVoice = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      widget.onSendImage?.call(image.name, bytes, bytes.length);
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      widget.onSendImage?.call(image.name, bytes, bytes.length);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        widget.onSendFile?.call(file.name, file.bytes!, file.size);
      }
    }
  }

  void _startVoiceRecording() {
    setState(() {
      _isRecordingVoice = true;
    });
  }

  void _onVoiceRecordingComplete(Uint8List bytes, int duration) {
    setState(() {
      _isRecordingVoice = false;
    });
    widget.onSendVoice?.call(bytes, duration);
  }

  void _cancelVoiceRecording() {
    setState(() {
      _isRecordingVoice = false;
    });
  }

  void _showAttachmentOptions() {
    showAttachmentOptions(
      context,
      onImageFromGallery: _pickImageFromGallery,
      onImageFromCamera: _pickImageFromCamera,
      onFile: _pickFile,
      onVoice: _startVoiceRecording,
    );
  }

  @override
  void didUpdateWidget(ChatArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    final messagesChanged = widget.messages.length != oldWidget.messages.length;
    final conversationChanged =
        widget.selectedConversation?.id != oldWidget.selectedConversation?.id;

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

  void _showDeleteConfirmation(String messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف الرسالة'),
        content: const Text('هل تريد حذف هذه الرسالة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDeleteMessage?.call(messageId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showDeleteSelectedConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف الرسائل المحددة'),
        content: Text(
            'هل تريد حذف ${widget.selectedMessageIds.length} رسالة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDeleteSelected?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
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
          // Show selection header or normal header
          if (widget.isSelectionMode)
            _buildSelectionHeader()
          else
            _buildChatHeader(),
          const Divider(height: 1),
          Expanded(child: _buildMessagesList()),
          const Divider(height: 1),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildSelectionHeader() {
    final selectedCount = widget.selectedMessageIds.length;
    final totalMessages =
        widget.messages.where((m) => !m.isDeleted).length;
    final isAllSelected = selectedCount == totalMessages;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF5542F6).withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 400;

          return Row(
            children: [
              // Close button
              IconButton(
                onPressed: widget.onCancelSelectionMode,
                icon: const Icon(Icons.close, size: 20),
                color: const Color(0xFF5542F6),
                tooltip: 'إلغاء التحديد',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              // Selected count
              Text(
                '$selectedCount محدد',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5542F6),
                ),
              ),
              const Spacer(),
              // Select all button
              if (!isCompact)
                TextButton.icon(
                  onPressed: widget.onSelectAll,
                  icon: Icon(
                    isAllSelected ? Icons.deselect : Icons.select_all,
                    size: 18,
                  ),
                  label: Text(
                    isAllSelected ? 'إلغاء الكل' : 'تحديد الكل',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF5542F6),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                )
              else
                IconButton(
                  onPressed: widget.onSelectAll,
                  icon: Icon(
                    isAllSelected ? Icons.deselect : Icons.select_all,
                    size: 20,
                  ),
                  color: const Color(0xFF5542F6),
                  tooltip: isAllSelected ? 'إلغاء الكل' : 'تحديد الكل',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              const SizedBox(width: 8),
              // Delete button
              isCompact
                  ? IconButton(
                      onPressed: selectedCount > 0
                          ? _showDeleteSelectedConfirmation
                          : null,
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Colors.red,
                      tooltip: 'حذف',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  : ElevatedButton.icon(
                      onPressed: selectedCount > 0
                          ? _showDeleteSelectedConfirmation
                          : null,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('حذف', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
            ],
          );
        },
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              Expanded(child: _buildUserInfo(constraints.maxWidth)),
              _buildActions(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserInfo(double maxWidth) {
    final conversation = widget.selectedConversation!;
    final hasAvatar =
        conversation.userAvatar != null && conversation.userAvatar!.isNotEmpty;
    final isCompact = maxWidth < 400;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: isCompact ? 20 : 24,
              backgroundColor: const Color(0xFF5542F6).withValues(alpha: 0.1),
              backgroundImage:
                  hasAvatar ? NetworkImage(conversation.userAvatar!) : null,
              child: !hasAvatar
                  ? Text(
                      conversation.userInitial,
                      style: TextStyle(
                        fontSize: isCompact ? 14 : 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5542F6),
                      ),
                    )
                  : null,
            ),
            if (conversation.isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: isCompact ? 12 : 14,
                  height: isCompact ? 12 : 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                conversation.userName ??
                    'User ${conversation.userId?.substring(0, 8) ?? ""}',
                style: TextStyle(
                  fontSize: isCompact ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
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
                    conversation.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: conversation.isOnline
                          ? const Color(0xFF10B981)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        _buildStatusDropdown(),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
          tooltip: 'More options',
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          itemBuilder: (context) => [
            _buildPopupItem(Icons.checklist, 'تحديد الرسائل', 'select'),
            _buildPopupItem(Icons.block_outlined, 'Block User', 'block'),
            _buildPopupItem(Icons.delete_outline, 'Delete Chat', 'delete'),
            _buildPopupItem(Icons.archive_outlined, 'Archive', 'archive'),
            _buildPopupItem(Icons.flag_outlined, 'Report', 'report'),
          ],
          onSelected: (value) {
            if (value == 'select') {
              widget.onEnableSelectionMode?.call(null);
            }
          },
        ),
      ],
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
                  isSelectionMode: widget.isSelectionMode,
                  isSelected: widget.selectedMessageIds.contains(message.id),
                  onLongPress: () {
                    if (!message.isDeleted) {
                      widget.onEnableSelectionMode?.call(message.id);
                    }
                  },
                  onTap: () {
                    if (widget.isSelectionMode && !message.isDeleted) {
                      widget.onToggleMessageSelection?.call(message.id!);
                    }
                  },
                  onDelete: () => _showDeleteConfirmation(message.id!),
                )),
          ],
        );
      },
    );
  }

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
    if (_isRecordingVoice) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: VoiceRecorderWidget(
          onRecordingComplete: _onVoiceRecordingComplete,
          onCancel: _cancelVoiceRecording,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 400;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildInputAction(Icons.add, 'Attach', _showAttachmentOptions),
              if (!isCompact) ...[
                _buildInputAction(
                    Icons.image_outlined, 'Image', _pickImageFromGallery),
                _buildInputAction(
                    Icons.mic_outlined, 'Voice', _startVoiceRecording),
              ],
              const SizedBox(width: 8),
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
                    decoration: InputDecoration(
                      hintText: isCompact ? 'Message...' : 'Type your message...',
                      hintStyle:
                          const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
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
              const SizedBox(width: 8),
              _buildSendButton(),
            ],
          );
        },
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

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final String userName;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _MessageBubble({
    required this.message,
    required this.userName,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = message.isAdmin;

    // If message is deleted, show deleted message bubble
    if (message.isDeleted) {
      return _buildDeletedMessageBubble(isAdmin);
    }

    return GestureDetector(
      onLongPress: onLongPress,
      onTap: isSelectionMode ? onTap : null,
      child: Container(
        color: isSelected
            ? const Color(0xFF5542F6).withValues(alpha: 0.1)
            : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment:
                isAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Checkbox in selection mode
              if (isSelectionMode) ...[
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onTap?.call(),
                  activeColor: const Color(0xFF5542F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 4),
              ],
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
                      padding: EdgeInsets.symmetric(
                        horizontal: message.isImage ? 4 : 16,
                        vertical: message.isImage ? 4 : 12,
                      ),
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
                      child: _buildMessageContent(context, isAdmin),
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
        ),
      ),
    );
  }

  Widget _buildDeletedMessageBubble(bool isAdmin) {
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isAdmin ? 18 : 4),
                      bottomRight: Radius.circular(isAdmin ? 4 : 18),
                    ),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.block,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'تم حذف هذه الرسالة',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message.formattedTime,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
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

  Widget _buildMessageContent(BuildContext context, bool isAdmin) {
    switch (message.messageType) {
      case MessageType.image:
        return _buildImageMessage(context, isAdmin);
      case MessageType.voice:
        return _buildVoiceMessage(isAdmin);
      case MessageType.file:
        return _buildFileMessage(isAdmin);
      case MessageType.text:
      default:
        return Text(
          message.message,
          style: TextStyle(
            fontSize: 14,
            color: isAdmin ? Colors.white : const Color(0xFF1F2937),
            height: 1.4,
          ),
        );
    }
  }

  Widget _buildImageMessage(BuildContext context, bool isAdmin) {
    return GestureDetector(
      onTap: () => _showFullImage(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          message.mediaUrl ?? '',
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 200,
              height: 200,
              color: isAdmin
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: isAdmin ? Colors.white : const Color(0xFF5542F6),
                  strokeWidth: 2,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 200,
              height: 200,
              color: isAdmin
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    color: isAdmin ? Colors.white70 : Colors.grey[400],
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load',
                    style: TextStyle(
                      fontSize: 12,
                      color: isAdmin ? Colors.white70 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  message.mediaUrl ?? '',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceMessage(bool isAdmin) {
    return SizedBox(
      width: 200,
      child: AudioPlayerWidget(
        audioUrl: message.mediaUrl ?? '',
        duration: message.audioDuration ?? 0,
        isAdmin: isAdmin,
      ),
    );
  }

  Widget _buildFileMessage(bool isAdmin) {
    return InkWell(
      onTap: () {
        // Open file URL in browser or download
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isAdmin
                  ? Colors.white.withValues(alpha: 0.2)
                  : const Color(0xFF5542F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getFileIcon(message.fileName ?? ''),
              color: isAdmin ? Colors.white : const Color(0xFF5542F6),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.fileName ?? 'File',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isAdmin ? Colors.white : const Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  message.formattedFileSize,
                  style: TextStyle(
                    fontSize: 12,
                    color: isAdmin
                        ? Colors.white.withValues(alpha: 0.7)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.download_outlined,
            color: isAdmin
                ? Colors.white.withValues(alpha: 0.7)
                : const Color(0xFF6B7280),
            size: 20,
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip;
      case 'mp3':
      case 'wav':
      case 'aac':
        return Icons.audio_file;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
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
