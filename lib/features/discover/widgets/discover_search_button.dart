import 'package:flutter/material.dart';

import '../../../core/design_system/app_colors.dart';

/// Fake search bar that navigates to full search screen when tapped
class DiscoverSearchButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isRtl;

  const DiscoverSearchButton({
    super.key,
    required this.onTap,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: AppColors.textSecondaryLight,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isRtl ? 'شاعری تلاش کریں...' : 'Search poetry...',
                  style: TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(
                Icons.mic_outlined,
                color: AppColors.textSecondaryLight,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
