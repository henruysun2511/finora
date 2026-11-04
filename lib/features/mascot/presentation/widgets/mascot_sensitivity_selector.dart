import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/mascot_enums.dart';

class MascotSensitivitySelector extends StatelessWidget {
  const MascotSensitivitySelector({
    super.key,
    required this.selectedSensitivity,
    required this.onSensitivityChanged,
  });

  final MascotSensitivity selectedSensitivity;
  final ValueChanged<MascotSensitivity> onSensitivityChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: MascotSensitivity.values.asMap().entries.map((entry) {
          final idx = entry.key;
          final sensitivity = entry.value;
          final isSelected = sensitivity == selectedSensitivity;
          final isLast = idx == MascotSensitivity.values.length - 1;

          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSensitivityChanged(sensitivity),
                  borderRadius: idx == 0
                      ? const BorderRadius.vertical(top: Radius.circular(18))
                      : (isLast
                          ? const BorderRadius.vertical(bottom: Radius.circular(18))
                          : BorderRadius.zero),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sensitivity.label,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkForeground
                                      : AppColors.lightForeground,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                sensitivity.description,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.lightMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkMuted
                                  : const Color(0xFFCBD5E1)),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

