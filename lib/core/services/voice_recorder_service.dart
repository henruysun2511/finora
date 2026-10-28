import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

class VoiceRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<List<int>>? _streamSub;
  final List<int> _audioChunks = [];
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<void> startRecording() async {
    if (_isRecording) return;
    final hasPerm = await _recorder.hasPermission();
    if (!hasPerm) {
      throw Exception('Chưa cấp quyền truy cập Microphone.');
    }

    _audioChunks.clear();

    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      sampleRate: 44100,
      bitRate: 128000,
    );

    try {
      final stream = await _recorder.startStream(config);
      _streamSub = stream.listen((chunk) {
        _audioChunks.addAll(chunk);
      });
      _isRecording = true;
    } catch (_) {
      // Fallback nếu encoder aacLc không khả dụng trên trình duyệt web
      const fallbackConfig = RecordConfig(
        encoder: kIsWeb ? AudioEncoder.opus : AudioEncoder.aacLc,
      );
      final stream = await _recorder.startStream(fallbackConfig);
      _streamSub = stream.listen((chunk) {
        _audioChunks.addAll(chunk);
      });
      _isRecording = true;
    }
  }

  Future<List<int>?> stopRecording() async {
    if (!_isRecording) return null;
    await _streamSub?.cancel();
    _streamSub = null;
    await _recorder.stop();
    _isRecording = false;

    if (_audioChunks.isEmpty) return null;
    return List<int>.from(_audioChunks);
  }

  Future<void> cancelRecording() async {
    if (!_isRecording) return;
    await _streamSub?.cancel();
    _streamSub = null;
    await _recorder.stop();
    _audioChunks.clear();
    _isRecording = false;
  }

  void dispose() {
    _streamSub?.cancel();
    _recorder.dispose();
  }
}
