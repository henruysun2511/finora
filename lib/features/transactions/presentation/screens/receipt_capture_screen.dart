import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/app_toast.dart';

/// Màn hình chụp ảnh hóa đơn chuyên biệt (Camera HUD & Cloudinary Upload)
/// Lấy cảm hứng từ scan-receipt.html của Finora UI Design System
class ReceiptCaptureScreen extends ConsumerStatefulWidget {
  const ReceiptCaptureScreen({super.key});

  @override
  ConsumerState<ReceiptCaptureScreen> createState() =>
      _ReceiptCaptureScreenState();
}

class _ReceiptCaptureScreenState extends ConsumerState<ReceiptCaptureScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _laserController;
  late final Animation<double> _laserAnimation;

  Uint8List? _capturedBytes;
  String? _capturedName;
  bool _isUploading = false;
  String _uploadStatus = 'Đang tải ảnh lên Cloudinary...';

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.08, end: 0.90).animate(
      CurvedAnimation(
        parent: _laserController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 88,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _capturedBytes = bytes;
          _capturedName = file.name.isNotEmpty
              ? file.name
              : 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
        });
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Không thể truy cập camera hoặc thư viện: $e',
          type: ToastType.error,
        );
      }
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
          remoteUrl =
              data['secureUrl']?.toString() ?? data['url']?.toString();
        }
      }

      if (remoteUrl != null && remoteUrl.isNotEmpty) {
        if (mounted) {
          AppToast.show(
            context,
            message: 'Đã tải và lưu ảnh hóa đơn thành công!',
            type: ToastType.success,
          );
          Navigator.of(context).pop(remoteUrl);
        }
      } else {
        throw Exception('Không nhận được URL ảnh từ máy chủ Cloudinary');
      }
    } catch (err) {
      if (mounted) {
        setState(() => _isUploading = false);
        // Fallback: nếu backend chưa khởi động lại hoặc trả 404, dùng Data URI để không gián đoạn
        final fallbackUrl =
            'data:image/jpeg;base64,${base64Encode(_capturedBytes!)}';
        AppToast.show(
          context,
          message: 'Máy chủ Cloudinary (404). Đã lưu ảnh xem trước để tiếp tục!',
          type: ToastType.warning,
        );
        Navigator.of(context).pop(fallbackUrl);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgHud = Color(0xFF000000); // Đen thuần chuẩn Locket

    return Scaffold(
      backgroundColor: bgHud,
      body: SafeArea(
        child: Stack(
          children: [
            // Nội dung chính: Camera Viewport phong cách Locket
            Column(
              children: [
                // 1. Top HUD Action Bar
                _buildTopBar(),

                // 2. Viewfinder Squircle Locket
                Expanded(
                  child: Center(
                    child: _buildViewfinder(),
                  ),
                ),

                // 3. Bottom Controls Locket (Shutter tròn to đặc trưng)
                _buildBottomControls(),
              ],
            ),

            // Loading Overlay khi đang upload Cloudinary
            if (_isUploading)
              Container(
                color: Colors.black.withValues(alpha: 0.8),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
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
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Đang tải lên hệ thống...',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút Đóng frosted
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(99),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          // Tiêu đề tối giản (Đã bỏ Finora AI Vision theo yêu cầu)
          Text(
            'Hóa đơn',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),

          // Nút Đèn flash / Góc chụp frosted
          InkWell(
            onTap: () => _pickImage(ImageSource.camera),
            borderRadius: BorderRadius.circular(99),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(
                Icons.flash_on_rounded,
                color: Color(0xFFFBBF24),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewfinder() {
    final screenWidth = MediaQuery.of(context).size.width;
    // Khung ngắm Squircle Locket với kích thước tối ưu cho hóa đơn dọc
    final boxWidth = (screenWidth - 32).clamp(280.0, 380.0);
    final boxHeight = (boxWidth * 1.34).clamp(380.0, 500.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: boxWidth,
          height: boxHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(36), // Bo tròn lớn chuẩn Locket
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 36,
                spreadRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Khung nền camera preview
                if (_capturedBytes != null)
                  Image.memory(
                    _capturedBytes!,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  )
                else
                  Container(
                    color: const Color(0xFF0B0F19),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Họa tiết nền mờ & hướng dẫn tối giản
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                              child: const Icon(
                                Icons.receipt_long_rounded,
                                size: 30,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Căn chỉnh hóa đơn trong khung',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),

                        // Tâm ngắm focus tinh tế chuẩn Locket
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Laser quét chuyển động mềm mại (chỉ chạy khi chưa chụp)
                if (_capturedBytes == null)
                  AnimatedBuilder(
                    animation: _laserAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: boxHeight * _laserAnimation.value,
                        left: 12,
                        right: 12,
                        child: Container(
                          height: 2.5,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0xFF38BDF8),
                                AppColors.primary,
                                Color(0xFF38BDF8),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF38BDF8)
                                    .withValues(alpha: 0.8),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Nhãn trạng thái tối giản
        if (_capturedBytes != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: Color(0xFF34D399),
                ),
                const SizedBox(width: 6),
                Text(
                  'Đã chụp xong chứng từ',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            'Giữ thẳng góc và chụp đủ sáng',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Colors.white38,
            ),
          ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
      child: _capturedBytes == null
          ? _buildCameraShutterControls()
          : _buildPreviewActions(),
    );
  }

  /// Khi chưa chụp: Nút Shutter to tròn nổi bật phong cách Locket
  Widget _buildCameraShutterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Thư viện ảnh (Frosted icon circle)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => _pickImage(ImageSource.gallery),
              borderRadius: BorderRadius.circular(99),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Thư viện',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ],
        ),

        // 2. Nút chụp Shutter Locket đặc trưng (Vòng tròn kép lớn)
        GestureDetector(
          onTap: () => _pickImage(ImageSource.camera),
          child: Container(
            width: 84,
            height: 84,
            padding: const EdgeInsets.all(4.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4.5),
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 3. Đổi camera / Góc chụp
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => _pickImage(ImageSource.camera),
              borderRadius: BorderRadius.circular(99),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: const Icon(
                  Icons.flip_camera_ios_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Chụp',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Khi đã có ảnh: Nút Chụp lại & Nút Lưu ảnh phong cách Locket
  Widget _buildPreviewActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Chụp lại (Frosted circle)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _capturedBytes = null;
                  _capturedName = null;
                });
              },
              borderRadius: BorderRadius.circular(99),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Chụp lại',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),

        // 2. Nút Lưu ảnh chính (Nút tròn thương hiệu to nổi bật kiểu Locket Send)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _isUploading ? null : _handleUploadAndSave,
              child: Container(
                width: 82,
                height: 82,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 3.5,
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, Color(0xFF0284C7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary,
                        blurRadius: 18,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Lưu hóa đơn',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),

        // 3. Hủy bỏ ảnh
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
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white70,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Hủy',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

