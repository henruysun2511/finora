import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/voice_recorder_service.dart';

class VoiceRecordingModal extends StatefulWidget {
  final void Function(List<int> bytes, String filename, {String? promptHint}) onSendVoice;
  final ValueChanged<String> onSelectSample;

  const VoiceRecordingModal({
    super.key,
    required this.onSendVoice,
    required this.onSelectSample,
  });

  @override
  State<VoiceRecordingModal> createState() => _VoiceRecordingModalState();
}

class _VoiceRecordingModalState extends State<VoiceRecordingModal>
    with SingleTickerProviderStateMixin {
  final VoiceRecorderService _recorder = VoiceRecorderService();
  bool _isRecording = false;
  bool _isProcessing = false;
  int _seconds = 0;
  Timer? _timer;
  String? _errorMessage;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  void _startTimer() {
    _seconds = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _seconds++);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatDuration(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _toggleRecording() async {
    if (_isProcessing) return;

    if (!_isRecording) {
      setState(() {
        _errorMessage = null;
        _isProcessing = true;
      });

      try {
        await _recorder.startRecording();
        setState(() {
          _isRecording = true;
          _isProcessing = false;
        });
        _startTimer();
      } catch (e) {
        setState(() {
          _isRecording = false;
          _isProcessing = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } else {
      // Dừng ghi âm và gửi
      setState(() => _isProcessing = true);
      _stopTimer();

      try {
        final bytes = await _recorder.stopRecording();
        setState(() => _isRecording = false);

        if (bytes != null && bytes.isNotEmpty) {
          final filename = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
          if (mounted) {
            Navigator.pop(context);
            widget.onSendVoice(
              bytes,
              filename,
              promptHint: '🎤 Ghi âm giọng nói chi tiêu (${_formatDuration(_seconds)})',
            );
          }
        } else {
          setState(() {
            _isProcessing = false;
            _errorMessage = 'Đoạn ghi âm quá ngắn hoặc không có dữ liệu âm thanh.';
          });
        }
      } catch (e) {
        setState(() {
          _isProcessing = false;
          _isRecording = false;
          _errorMessage = 'Lỗi lưu bản ghi: $e';
        });
      }
    }
  }

  Future<void> _cancelRecording() async {
    _stopTimer();
    await _recorder.cancelRecording();
    setState(() {
      _isRecording = false;
      _isProcessing = false;
      _seconds = 0;
    });
  }

  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg', 'webm'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes;
        final filename = file.name;

        if (bytes != null && bytes.isNotEmpty) {
          if (mounted) {
            Navigator.pop(context);
            widget.onSendVoice(
              bytes,
              filename,
              promptHint: '🎤 Tệp ghi âm: $filename',
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể chọn tệp âm thanh: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thanh kéo drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Tiêu đề
              Text(
                _isRecording ? 'Đang lắng nghe bạn nói...' : 'Nhập liệu bằng giọng nói',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isRecording
                    ? 'Chạm lại vào nút để kết thúc & gửi tới AI'
                    : 'Nói tự nhiên, ví dụ: "Ăn sáng phở bò 45k tiền mặt"',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),

              // Timer đếm giây khi đang ghi âm
              if (_isRecording) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(_seconds),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Thông báo lỗi nếu có
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Nút Micro chính
              GestureDetector(
                onTap: _isProcessing ? null : _toggleRecording,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (ctx, child) {
                    final scale = _isRecording ? _pulseAnimation.value : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _isRecording
                                ? const [Color(0xFFEF4444), Color(0xFFDC2626)]
                                : const [Color(0xFF0072D5), Color(0xFF0058A8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isRecording
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF0072D5))
                                  .withValues(alpha: _isRecording ? 0.45 : 0.35),
                              blurRadius: _isRecording ? 24 : 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  _isRecording
                                      ? Icons.stop_rounded
                                      : Icons.mic_rounded,
                                  color: Colors.white,
                                  size: 38,
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // Nhãn trạng thái nút
              Text(
                _isRecording
                    ? 'Chạm nút đỏ để gửi giọng nói'
                    : 'Chạm để bắt đầu nói',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: _isRecording ? const Color(0xFFEF4444) : AppColors.primary,
                ),
              ),

              // Nút hủy khi đang ghi âm
              if (_isRecording) ...[
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _cancelRecording,
                  icon: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                  label: Text(
                    'Hủy ghi âm',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],

              const Divider(height: 28),

              // Option 2: Chọn file âm thanh từ máy
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.audio_file_rounded,
                    color: Color(0xFF8B5CF6),
                    size: 22,
                  ),
                ),
                title: Text(
                  'Tải tệp âm thanh từ thiết bị',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Hỗ trợ file MP3, M4A, WAV, WebM ghi âm sẵn',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _pickAudioFile,
              ),

              const SizedBox(height: 10),

              // Option 3: Câu lệnh mẫu thử nhanh
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'HOẶC THỬ NHANH CÂU LỆNH MẪU',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSampleChip(
                    context,
                    '🍜 Ăn sáng phở Thìn 65k tiền mặt',
                  ),
                  _buildSampleChip(
                    context,
                    '⛽ Đổ xăng 80k thẻ Vietcombank',
                  ),
                  _buildSampleChip(
                    context,
                    '☕ Mua cà phê Highland 55k',
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSampleChip(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ActionChip(
      avatar: const Icon(Icons.record_voice_over_rounded, size: 14, color: Color(0xFF0072D5)),
      label: Text(text),
      labelStyle: GoogleFonts.inter(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
      ),
      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      side: BorderSide(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: () {
        Navigator.pop(context);
        widget.onSelectSample(text);
      },
    );
  }
}
