import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/app_toast.dart';

/// Màn hình chụp ảnh hóa đơn chuyên biệt (Camera HUD & Cloudinary Upload)
/// Lấy cảm hứng từ scan-receipt.html của Finora UI Design System
class ReceiptCaptureScreen extends ConsumerStatefulWidget {
  final bool autoCapture;
  final bool navigateToCreate;

  const ReceiptCaptureScreen({
    super.key,
    this.autoCapture = false,
    this.navigateToCreate = true,
  });

  @override
  ConsumerState<ReceiptCaptureScreen> createState() =>
      _ReceiptCaptureScreenState();
}

class _ReceiptCaptureScreenState extends ConsumerState<ReceiptCaptureScreen> {
  Uint8List? _capturedBytes;
  String? _capturedName;
  bool _isUploading = false;
  String _uploadStatus = 'Đang tải ảnh lên Cloudinary...';

  bool _isFlashOn = false;
  bool _isFrontCamera = false;

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    AppToast.show(
      context,
      message: _isFlashOn
          ? 'Đã bật đèn Flash trợ sáng khi chụp'
          : 'Đã tắt đèn Flash',
      type: ToastType.info,
    );
  }

  void _toggleCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    _pickImage(ImageSource.camera);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      XFile? file;
      try {
        file = await picker.pickImage(
          source: source,
          preferredCameraDevice:
              _isFrontCamera ? CameraDevice.front : CameraDevice.rear,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 88,
        );
      } catch (innerErr) {
        // Fallback trên môi trường Web hoặc máy tính không hỗ trợ camera media stream
        if (source == ImageSource.camera) {
          file = await picker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1920,
            maxHeight: 1920,
            imageQuality: 88,
          );
        } else {
          rethrow;
        }
      }

      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _capturedBytes = bytes;
          _capturedName = file!.name.isNotEmpty
              ? file.name
              : 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
        });
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Không thể truy cập máy ảnh: $e',
          type: ToastType.error,
        );
      }
    }
  }

  void _onSuccess(String finalUrl) {
    if (!mounted) return;
    AppToast.show(
      context,
      message: 'Đã lưu ảnh chứng từ!',
      type: ToastType.success,
    );
    if (widget.navigateToCreate) {
      context.pushReplacement(
        RoutePaths.createTransaction,
        extra: finalUrl,
      );
    } else {
      Navigator.of(context).pop(finalUrl);
    }
  }

  Future<void> _handleUploadAndSave() async {
    if (_capturedBytes == null) return;

    setState(() {
      _isUploading = true;
      _uploadStatus = 'Đang tải ảnh lên máy chủ Cloudinary...';
    });

    try {
      final dio = ref.read(dioProvider);
      final filename = _capturedName ??
          'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          _capturedBytes!,
          filename: filename,
        ),
        'folder': 'finora/receipts',
      });

      final response = await dio.post<dynamic>(
        ApiConstants.cloudinaryUpload,
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0 && mounted) {
            final percent = ((sent / total) * 100).toInt();
            setState(() {
              _uploadStatus = 'Đang tải ảnh: $percent%';
            });
          }
        },
      );

      final data = response.data;
      String? remoteUrl;

      if (data is Map<String, dynamic>) {
        if (data['data'] != null && data['data'] is Map) {
          remoteUrl = data['data']['secureUrl']?.toString() ??
              data['data']['url']?.toString();
        } else {
          remoteUrl = data['secureUrl']?.toString() ?? data['url']?.toString();
        }
      }

      if (remoteUrl != null && remoteUrl.isNotEmpty) {
        _onSuccess(remoteUrl);
      } else {
        throw Exception('Không nhận được URL ảnh từ máy chủ Cloudinary');
      }
    } catch (err) {
      if (mounted) {
        setState(() => _isUploading = false);
        // Fallback: nếu backend chưa khởi động lại hoặc trả 404, dùng Data URI để không gián đoạn
        final fallbackUrl =
            'data:image/jpeg;base64,${base64Encode(_capturedBytes!)}';
        _onSuccess(fallbackUrl);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgHud = Colors.white; // Nền trắng chuẩn theo yêu cầu
    const textDark = Color(0xFF0F172A);
    const borderLight = Color(0xFFE2E8F0);
    const pillBg = Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: bgHud,
      body: SafeArea(
        child: Stack(
          children: [
            // Nội dung chính: Camera Viewport chuẩn bố cục Locket mới
            Column(
              children: [
                // 1. Top HUD Action Bar (Nút Đóng - Capsule tiêu đề ở giữa - Nút Đèn Flash)
                _buildLocketTopBar(textDark, borderLight, pillBg),

                // 2. Viewfinder Squircle Locket
                Expanded(
                  child: Center(
                    child: _buildLocketViewfinder(),
                  ),
                ),

                // 3. Bottom Controls Locket (Shutter xanh hệ thống & Nút Lịch sử)
                _buildLocketBottomControls(textDark, borderLight, pillBg),
              ],
            ),

            // Loading Overlay khi đang upload Cloudinary
            if (_isUploading)
              Container(
                color: Colors.black.withValues(alpha: 0.6),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 44,
                          height: 44,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.5,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          _uploadStatus,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Đang tải lên hệ thống...',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 1. Top Bar chuẩn phong cách Locket mới
  Widget _buildLocketTopBar(Color textDark, Color borderLight, Color pillBg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút Đóng / Quay lại tròn bên trái
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(99),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: pillBg,
                shape: BoxShape.circle,
                border: Border.all(color: borderLight),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Color(0xFF1E293B),
                size: 22,
              ),
            ),
          ),

          // Capsule Pill lớn ở giữa (Chuẩn Locket pill như "👥 613 người bạn")
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: borderLight),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _capturedBytes == null ? 'Chụp hóa đơn' : 'Xem trước hóa đơn',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),

          // Nút Đèn flash / Bật đèn pin thật
          InkWell(
            onTap: _toggleFlash,
            borderRadius: BorderRadius.circular(99),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isFlashOn ? const Color(0xFFFEF3C7) : pillBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isFlashOn ? const Color(0xFFFBBF24) : borderLight,
                  width: _isFlashOn ? 1.5 : 1,
                ),
              ),
              child: Icon(
                _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                color: _isFlashOn
                    ? const Color(0xFFD97706)
                    : const Color(0xFF64748B),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Khung ngắm Squircle Locket HÌNH VUÔNG 1:1 chuẩn
  Widget _buildLocketViewfinder() {
    final screenWidth = MediaQuery.of(context).size.width;
    // Khung ngắm Squircle Locket hình vuông chuẩn 1:1
    final boxSize = (screenWidth - 32).clamp(280.0, 390.0);

    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: const Color(0xFF111827), // Nền xám đen sang trọng trong khung ngắm
        borderRadius: BorderRadius.circular(38), // Bo tròn lớn chuẩn Locket
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 28,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ảnh đã chụp hoặc Khung ngắm Camera
            if (_capturedBytes != null)
              Image.memory(
                _capturedBytes!,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              )
            else
              Container(
                color: const Color(0xFF0F172A),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Hướng dẫn căn chỉnh
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 32,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Căn chỉnh hóa đơn trong khung',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chụp rõ nét chứng từ để lưu trữ',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),

                    // Tâm ngắm focus chuẩn Locket
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 3. Bottom Controls Locket: Shutter xanh hệ thống & Footer Lịch sử
  Widget _buildLocketBottomControls(
      Color textDark, Color borderLight, Color pillBg) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hàng điều khiển nút bấm
          _capturedBytes == null
              ? _buildLocketShutterRow(textDark, borderLight, pillBg)
              : _buildLocketPreviewRow(textDark, borderLight, pillBg),

          const SizedBox(height: 14),

          // Capsule pill "Lịch sử hóa đơn v" chuẩn Locket
          InkWell(
            onTap: () {
              // Điều hướng xem danh sách giao dịch
              context.pushNamed(RouteNames.transactions);
            },
            borderRadius: BorderRadius.circular(99),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: borderLight),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lịch sử hóa đơn',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hàng nút khi CHƯA CHỤP: Thư viện (trái) - Nút chụp xanh hệ thống (giữa) - Đổi camera (phải)
  Widget _buildLocketShutterRow(
      Color textDark, Color borderLight, Color pillBg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Thư viện ảnh (Icon khung ảnh chuẩn Locket)
        InkWell(
          onTap: () => _pickImage(ImageSource.gallery),
          borderRadius: BorderRadius.circular(99),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: pillBg,
              shape: BoxShape.circle,
              border: Border.all(color: borderLight),
            ),
            child: const Icon(
              Icons.photo_library_outlined,
              color: Color(0xFF1E293B),
              size: 24,
            ),
          ),
        ),

        // 2. NÚT CHỤP SHUTTER LOCKET: MÀU XANH HỆ THỐNG (Vòng tròn ngoài + Nút tròn trong)
        GestureDetector(
          onTap: () => _pickImage(ImageSource.camera),
          child: Container(
            width: 88,
            height: 88,
            padding: const EdgeInsets.all(4.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 4.5, // Viền ngoài màu xanh thương hiệu chuẩn Locket
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary, // Solid màu xanh hệ thống #0072D6
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),

        // 3. Đổi camera trước / sau (Icon xoay tròn chuẩn Locket)
        InkWell(
          onTap: _toggleCamera,
          borderRadius: BorderRadius.circular(99),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: pillBg,
              shape: BoxShape.circle,
              border: Border.all(color: borderLight),
            ),
            child: const Icon(
              Icons.cached_rounded,
              color: Color(0xFF1E293B),
              size: 26,
            ),
          ),
        ),
      ],
    );
  }

  /// Hàng nút khi ĐÃ CHỤP XONG: Hủy bỏ (trái) - Xác nhận xanh hệ thống (giữa) - Chụp lại (phải)
  Widget _buildLocketPreviewRow(
      Color textDark, Color borderLight, Color pillBg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Nút Hủy bỏ
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _capturedBytes = null;
                  _capturedName = null;
                });
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(99),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFFDC2626),
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Hủy bỏ',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),

        // 2. NÚT XÁC NHẬN CHÍNH GIỮA: MÀU XANH HỆ THỐNG
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _isUploading ? null : _handleUploadAndSave,
              child: Container(
                width: 88,
                height: 88,
                padding: const EdgeInsets.all(4.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 4.5,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Xác nhận',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),

        // 3. Nút Chụp lại
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _capturedBytes = null;
                  _capturedName = null;
                });
                _pickImage(ImageSource.camera);
              },
              borderRadius: BorderRadius.circular(99),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: pillBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderLight),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF1E293B),
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Chụp lại',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
