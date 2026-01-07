import 'package:flutter/material.dart';

class AttachmentOption {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class AttachmentOptionsSheet extends StatelessWidget {
  final VoidCallback onImageFromGallery;
  final VoidCallback onImageFromCamera;
  final VoidCallback onFile;
  final VoidCallback onVoice;

  const AttachmentOptionsSheet({
    super.key,
    required this.onImageFromGallery,
    required this.onImageFromCamera,
    required this.onFile,
    required this.onVoice,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      AttachmentOption(
        icon: Icons.photo_library_outlined,
        label: 'Gallery',
        color: const Color(0xFF5542F6),
        onTap: () {
          Navigator.pop(context);
          onImageFromGallery();
        },
      ),
      AttachmentOption(
        icon: Icons.camera_alt_outlined,
        label: 'Camera',
        color: const Color(0xFF10B981),
        onTap: () {
          Navigator.pop(context);
          onImageFromCamera();
        },
      ),
      AttachmentOption(
        icon: Icons.insert_drive_file_outlined,
        label: 'File',
        color: const Color(0xFFF59E0B),
        onTap: () {
          Navigator.pop(context);
          onFile();
        },
      ),
      AttachmentOption(
        icon: Icons.mic_outlined,
        label: 'Voice',
        color: const Color(0xFFEF4444),
        onTap: () {
          Navigator.pop(context);
          onVoice();
        },
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Send Attachment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: options.map((option) => _buildOption(option)).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOption(AttachmentOption option) {
    return InkWell(
      onTap: option.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: option.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              option.icon,
              color: option.color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            option.label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

void showAttachmentOptions(
  BuildContext context, {
  required VoidCallback onImageFromGallery,
  required VoidCallback onImageFromCamera,
  required VoidCallback onFile,
  required VoidCallback onVoice,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => AttachmentOptionsSheet(
      onImageFromGallery: onImageFromGallery,
      onImageFromCamera: onImageFromCamera,
      onFile: onFile,
      onVoice: onVoice,
    ),
  );
}
