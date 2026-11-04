import 'dart:async';
import 'package:dio/dio.dart';
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
      throw Exception('Chưa cấp quyền truy cập Microphone trên trình duyệt/thiết bị.');
    }

    _audioChunks.clear();

    if (kIsWeb) {
      // Trên Web (Chrome), startStream không hỗ trợ Opus/AAC.
      // Dùng start() để MediaRecorder của trình duyệt thu âm và tạo Blob URL an toàn.
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.opus,
          sampleRate: 44100,
          bitRate: 128000,
        ),
        path: '',
      );
      _isRecording = true;
    } else {
      // Trên Android / iOS
      try {
        const config = RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
          bitRate: 128000,
        );
        final stream = await _recorder.startStream(config);
        _streamSub = stream.listen((chunk) {
          _audioChunks.addAll(chunk);
        });
        _isRecording = true;
      } catch (_) {
        const fallbackConfig = RecordConfig(
          encoder: AudioEncoder.pcm16bits,
        );
        final stream = await _recorder.startStream(fallbackConfig);
        _streamSub = stream.listen((chunk) {
          _audioChunks.addAll(chunk);
        });
        _isRecording = true;
      }
    }
  }

  Future<List<int>?> stopRecording() async {
    if (!_isRecording) return null;

    if (kIsWeb) {
      _isRecording = false;
      final blobUrl = await _recorder.stop();
      if (blobUrl == null || blobUrl.isEmpty) return null;

      try {
        // Tải byte dữ liệu từ Blob URL do trình duyệt tạo
        final response = await Dio().get<List<int>>(
          blobUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        return response.data;
      } catch (e) {
        debugPrint('Lỗi tải byte âm thanh từ Blob URL: $e');
        return null;
      }
    } else {
      await _streamSub?.cancel();
      _streamSub = null;
      await _recorder.stop();
      _isRecording = false;

      if (_audioChunks.isEmpty) return null;
      return List<int>.from(_audioChunks);
    }
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
