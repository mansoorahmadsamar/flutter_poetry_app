import 'package:flutter/material.dart';

import '../../../core/design_system/app_colors.dart';

/// Reusable section header with title, optional icon, and chip-style "See more" button.
/// Shows "See more" only when totalCount > items.length.
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final bool isRtl;
  final int itemCount;
  final int totalCount;
  final VoidCallback? onSeeMore;

  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    required this.isRtl,
    this.itemCount = 0,
    this.totalCount = 0,
    this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showSeeMore = onSeeMore != null && totalCount > itemCount;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: iconColor ??
                  (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
                fontSize: isRtl ? 18 : 16,
                fontWeight: FontWeight.w600,
                height: isRtl ? 1.8 : 1.4,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
          if (showSeeMore)
            GestureDetector(
              onTap: onSeeMore,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.secondary.withValues(alpha: 0.15)
                      : AppColors.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getSeeMoreText(),
                      style: TextStyle(
                        fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
                        color: AppColors.secondaryDark,
                        fontSize: isRtl ? 13 : 12,
                        fontWeight: FontWeight.w600,
                        height: isRtl ? 1.5 : 1.3,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isRtl
                          ? Icons.arrow_back_ios_rounded
                          : Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: AppColors.secondaryDark,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getSeeMoreText() {
    if (isRtl) return 'مزید دیکھیں';
    return 'See more';
  }
}
