import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class VoiceRecorderWidget extends StatefulWidget {
  final Function(Uint8List audioBytes, int duration) onRecordingComplete;
  final VoidCallback onCancel;

  const VoiceRecorderWidget({
    super.key,
    required this.onRecordingComplete,
    required this.onCancel,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget>
    with SingleTickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  int _recordDuration = 0;
  Timer? _timer;
  String? _recordPath;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _startRecording();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        String path;
        if (kIsWeb) {
          path = '';
        } else {
          final dir = await getTemporaryDirectory();
          path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        }

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _recordPath = path;
          _recordDuration = 0;
        });

        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordDuration++;
          });
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();

    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        Uint8List? bytes;

        if (kIsWeb) {
          // On web, the path is a blob URL - fetch it to get bytes
          final response = await http.get(Uri.parse(path));
          if (response.statusCode == 200) {
            bytes = response.bodyBytes;
          }
        } else {
          // On mobile/desktop, read the file directly
          final file = File(path);
          if (await file.exists()) {
            bytes = await file.readAsBytes();
            await file.delete();
          }
        }

        if (bytes != null && bytes.isNotEmpty) {
          widget.onRecordingComplete(bytes, _recordDuration);
        }
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }

    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();

    try {
      await _audioRecorder.stop();
      if (_recordPath != null) {
        final file = File(_recordPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error canceling recording: $e');
    }

    widget.onCancel();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _cancelRecording,
            icon: const Icon(Icons.delete_outline),
            color: const Color(0xFFEF4444),
            tooltip: 'Cancel',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          const Color(0xFFEF4444),
                          const Color(0xFFEF4444).withValues(alpha: 0.3),
                          _animationController.value,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  _formatDuration(_recordDuration),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEF4444),
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Recording...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _stopRecording,
              icon: const Icon(Icons.send_rounded),
              color: Colors.white,
              tooltip: 'Send',
            ),
          ),
        ],
      ),
    );
  }
}
