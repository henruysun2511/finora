import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/form_card.dart';

class TransactionDetailReceiptCard extends StatelessWidget {
  const TransactionDetailReceiptCard({
    super.key,
    required this.photoUrl,
    required this.onTapImage,
  });

  final String photoUrl;
  final VoidCallback onTapImage;

  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Hóa đơn & Chứng từ đính kèm',
      child: InkWell(
        onTap: onTapImage,
        borderRadius: BorderRadius.circular(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 160,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                !kIsWeb && File(photoUrl).existsSync()
                    ? Image.file(
                        File(photoUrl),
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                      ),
                Container(
                  color: Colors.black26,
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.zoom_in_rounded,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Chạm để phóng to ảnh',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

