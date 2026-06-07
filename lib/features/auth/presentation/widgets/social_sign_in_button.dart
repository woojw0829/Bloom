import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';

class SocialSignInButton extends StatelessWidget {
  const SocialSignInButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDark = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  /// True for the Apple Sign-In dark variant.
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final background = isDark ? AppColors.textPrimary : AppColors.surface;
    final foreground = isDark ? AppColors.white : AppColors.textPrimary;
    final icon = isDark ? Icons.apple : Icons.login_rounded;
    final iconColor = isDark ? AppColors.white : const Color(0xFF4285F4);

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.buttonBorder,
        border: isDark
            ? null
            : Border.all(color: AppColors.border),
        boxShadow: isDark
            ? null
            : [
                const BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: AppRadius.buttonBorder,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: foreground,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: iconColor, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: AppTypography.bodyMedium.copyWith(
                          color: foreground,
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
