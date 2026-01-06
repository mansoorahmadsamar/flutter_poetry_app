import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';

/// Recent searches discovery section
///
/// Features:
/// - Soft card container with gentle elevation
/// - Clean English heading (always)
/// - Subtle "Clear All" button
/// - Urdu-aware chips with proper sizing
/// - Literary, calm aesthetic
class RecentSearchesSection extends ConsumerWidget {
  const RecentSearchesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(globalSearchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (searchState.recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with clear button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () async {
                  final historyService = ref.read(searchHistoryServiceProvider);
                  await historyService.clearAll();
                  await ref.read(globalSearchProvider.notifier).refreshRecentSearches();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.sm),

          // Recent searches chips
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: searchState.recentSearches.map((query) {
              final isUrdu = _isUrduText(query);
              return ActionChip(
                label: Text(
                  query,
                  style: TextStyle(
                    fontSize: isUrdu ? 15 : 13,
                    fontFamily: isUrdu ? 'JameelNoori' : null,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                    height: isUrdu ? 1.6 : 1.3,
                  ),
                ),
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : AppColors.primary.withValues(alpha: 0.04),
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.primary.withValues(alpha: 0.12),
                  width: 1,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: isUrdu ? AppSpacing.xs + 2 : AppSpacing.xs,
                ),
                onPressed: () {
                  ref.read(globalSearchProvider.notifier).executeSearch(query: query);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Detect if text is primarily Urdu
  bool _isUrduText(String text) {
    final urduPattern = RegExp(r'[\u0600-\u06FF]');
    final urduMatches = urduPattern.allMatches(text).length;
    return urduMatches > text.length / 3;
  }
}
