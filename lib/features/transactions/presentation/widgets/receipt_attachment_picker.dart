import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/app_toast.dart';

class ReceiptAttachmentPicker extends ConsumerStatefulWidget {
  const ReceiptAttachmentPicker({
    super.key,
    required this.photoPath,
    required this.onPhotoSelected,
    required this.onPhotoRemoved,
  });

  final String? photoPath;
  final ValueChanged<String> onPhotoSelected;
  final VoidCallback onPhotoRemoved;

  @override
  ConsumerState<ReceiptAttachmentPicker> createState() =>
      _ReceiptAttachmentPickerState();
}

class _ReceiptAttachmentPickerState
    extends ConsumerState<ReceiptAttachmentPicker> {
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    Navigator.of(context).pop();
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (picked == null) return;

      setState(() => _isUploading = true);

      // Thử tải lên Cloudinary qua API
      try {
        final dio = ref.read(dioProvider);
        final bytes = await picked.readAsBytes();
        final formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(
            bytes,
            filename: picked.name.isNotEmpty ? picked.name : 'receipt.jpg',
          ),
          'folder': 'finora/receipts',
        });

        final res = await dio.post<dynamic>(
          ApiConstants.cloudinaryUpload,
          data: formData,
        );

        final data = res.data;
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

        final finalUrl = remoteUrl ?? picked.path;
        widget.onPhotoSelected(finalUrl);

        if (mounted) {
          AppToast.show(
            context,
            message: 'Đã đính kèm ảnh hóa đơn thành công!',
            type: ToastType.success,
          );
        }
      } catch (uploadErr) {
        // Fallback lưu path cục bộ nếu upload lỗi (ví dụ chưa kết nối internet/Cloudinary)
        widget.onPhotoSelected(picked.path);
        if (mounted) {
          AppToast.show(
            context,
            message: 'Đã đính kèm ảnh xem trước.',
            type: ToastType.info,
          );
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showPickerModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: muted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Đính kèm ảnh hóa đơn / chứng từ',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Chụp ảnh từ Camera',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Chọn từ Thư viện ảnh',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    if (_isUploading) {
      return Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
                child: Text(
              'Đang tải ảnh hóa đơn lên máy chủ...',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
          ],
        ),
      );
    }

    if (widget.photoPath != null && widget.photoPath!.isNotEmpty) {
      // Đã có ảnh đính kèm -> Hiển thị thumbnail
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 60,
                height: 60,
                child: Image.network(
                  widget.photoPath!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đã đính kèm ảnh hóa đơn',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _showPickerModal(context),
                    child: Text(
                      'Đổi ảnh khác',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: widget.onPhotoRemoved,
              icon: Icon(Icons.close_rounded, color: muted, size: 20),
              tooltip: 'Gỡ ảnh',
            ),
          ],
        ),
      );
    }

    // Chưa có ảnh -> Nút viền bo góc nhẹ nhàng
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showPickerModal(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_a_photo_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Flexible(
                  child: Text(
                'Đính kèm ảnh hóa đơn / chứng từ',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
