import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';

/// Trending searches discovery section
///
/// Features:
/// - Card container with soft elevation
/// - Clean numbered list (top 5 only for cleanliness)
/// - Subtle trend indicator
/// - Larger Urdu text
/// - No loud fire emoji in heading
class TrendingSearchesSection extends ConsumerWidget {
  const TrendingSearchesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(globalSearchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (searchState.trendingSearches == null ||
        searchState.trendingSearches!.searches.isEmpty) {
      return const SizedBox.shrink();
    }

    final trending = searchState.trendingSearches!.searches.take(5).toList();

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
          // Section header
          Row(
            children: [
              Text(
                'Trending Searches',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'POPULAR',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // Trending searches list
          ...trending.asMap().entries.map((entry) {
            final index = entry.key;
            final search = entry.value;
            final rank = index + 1;
            final isUrdu = _isUrduText(search.query);

            return InkWell(
              onTap: () {
                ref.read(globalSearchProvider.notifier).executeSearch(
                  query: search.query,
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    // Rank number
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    SizedBox(width: AppSpacing.sm),

                    // Query text
                    Expanded(
                      child: Text(
                        search.query,
                        style: TextStyle(
                          fontSize: isUrdu ? 16 : 14,
                          fontFamily: isUrdu ? 'JameelNoori' : null,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                          height: isUrdu ? 1.7 : 1.4,
                        ),
                      ),
                    ),

                    // Subtle indicator
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
            );
          }),
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
