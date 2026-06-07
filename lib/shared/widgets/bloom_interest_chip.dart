import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

class BloomInterestChip extends StatelessWidget {
  const BloomInterestChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.readOnly = false,
  });

  final String label;
  final bool selected;

  /// Callback invoked when the chip is tapped. Ignored when [readOnly] is true.
  final VoidCallback? onTap;

  /// When true the chip is non-interactive: taps are ignored and no splash
  /// feedback is shown. Use this for read-only profile views.
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: readOnly ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: AppRadius.pillBorder,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
