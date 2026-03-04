import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';

/// Sort dropdown for verses/couplets segment
///
/// Features:
/// - 6 sort options: relevance, trending, likes, shares, bookmarks, recent
/// - Icons for each option
/// - Compact dropdown design
/// - Only visible in verses segment
class CoupletSortDropdown extends ConsumerWidget {
  const CoupletSortDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(globalSearchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentSort = searchState.coupletSort;

    return PopupMenuButton<CoupletSortOption>(
      initialValue: currentSort,
      onSelected: (CoupletSortOption value) {
        ref.read(globalSearchProvider.notifier).setCoupletSort(value);
      },
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getSortIcon(currentSort),
              size: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              _getSortLabel(currentSort),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) {
        return CoupletSortOption.values.map((option) {
          final isSelected = option == currentSort;
          return PopupMenuItem<CoupletSortOption>(
            value: option,
            child: Row(
              children: [
                Icon(
                  _getSortIcon(option),
                  size: 18,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.white : Colors.black87),
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  _getSortLabel(option),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  IconData _getSortIcon(CoupletSortOption option) {
    switch (option) {
      case CoupletSortOption.relevance:
        return Icons.search;
      case CoupletSortOption.trending:
        return Icons.trending_up;
      case CoupletSortOption.likes:
        return Icons.favorite;
      case CoupletSortOption.shares:
        return Icons.share;
      case CoupletSortOption.bookmarks:
        return Icons.bookmark;
      case CoupletSortOption.recent:
        return Icons.schedule;
    }
  }

  String _getSortLabel(CoupletSortOption option) {
    switch (option) {
      case CoupletSortOption.relevance:
        return 'Most Relevant';
      case CoupletSortOption.trending:
        return 'Trending';
      case CoupletSortOption.likes:
        return 'Most Liked';
      case CoupletSortOption.shares:
        return 'Most Shared';
      case CoupletSortOption.bookmarks:
        return 'Most Bookmarked';
      case CoupletSortOption.recent:
        return 'Recent';
    }
  }
}
