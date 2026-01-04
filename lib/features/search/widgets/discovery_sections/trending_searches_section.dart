import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';

/// Trending searches discovery section
///
/// Features:
/// - Numbered list with rank badges
/// - Top 3 searches highlighted with special styling
/// - Tap to execute search
/// - Language-aware labels
/// - Paper aesthetic with minimal design
class TrendingSearchesSection extends ConsumerWidget {
  const TrendingSearchesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(globalSearchProvider);
    final languageCode = ref.watch(selectedLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (searchState.trendingSearches == null ||
        searchState.trendingSearches!.searches.isEmpty) {
      return const SizedBox.shrink();
    }

    final trending = searchState.trendingSearches!.searches;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                size: 18,
                color: Colors.orange,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                _getLabel('Trending Searches', languageCode),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.9)
                      : Colors.black.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.sm),

          // Trending searches list
          ...trending.asMap().entries.map((entry) {
            final index = entry.key;
            final search = entry.value;
            final rank = index + 1;
            final isTopThree = rank <= 3;

            return InkWell(
              onTap: () {
                ref.read(globalSearchProvider.notifier).executeSearch(
                  query: search.query,
                );
              },
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    // Rank badge
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isTopThree
                            ? _getTopThreeColor(rank).withValues(alpha: 0.15)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.05)),
                        shape: BoxShape.circle,
                        border: isTopThree
                            ? Border.all(
                                color: _getTopThreeColor(rank),
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isTopThree ? FontWeight.w700 : FontWeight.w500,
                            color: isTopThree
                                ? _getTopThreeColor(rank)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : Colors.black.withValues(alpha: 0.6)),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: AppSpacing.sm),

                    // Query text
                    Expanded(
                      child: Text(
                        search.query,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isTopThree ? FontWeight.w600 : FontWeight.w400,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),

                    // Trend indicator
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : Colors.black.withValues(alpha: 0.4),
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

  /// Get color for top 3 ranks
  Color _getTopThreeColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }

  /// Get localized label
  String _getLabel(String key, String languageCode) {
    final labels = {
      'ur': {
        'Trending Searches': 'مقبول تلاش',
      },
      'hi': {
        'Trending Searches': 'ट्रेंडिंग खोजें',
      },
      'en': {
        'Trending Searches': 'Trending Searches',
      },
    };

    return labels[languageCode]?[key] ?? labels['en']![key]!;
  }
}
