import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';

/// Trending searches discovery section
///
/// Features:
/// - 6-10 trending search chips
/// - Fire icon on chips
/// - Consistent chip height (34px)
/// - Bilingual query display (Urdu/English/Hindi)
/// - Full pill border radius
/// - Soft shadows
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

    final trending = searchState.trendingSearches!.searches.take(10).toList();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 20,
                  color: const Color(0xFFC5A059), // Gold
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Trending Now',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  '/ مقبول تلاش',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Jameel Noori Nastaleeq',
                    fontWeight: FontWeight.w500,
                    color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.6),
                    height: 1.8,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.md),

          // Trending chips (wrap layout)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: trending.map((search) {
                return _buildTrendingChip(
                  context,
                  ref,
                  search.query,
                  isDark,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a single trending chip
  Widget _buildTrendingChip(
    BuildContext context,
    WidgetRef ref,
    String query,
    bool isDark,
  ) {
    final isUrdu = _isUrduText(query);

    return GestureDetector(
      onTap: () {
        ref.read(globalSearchProvider.notifier).executeSearch(query: query);
      },
      child: Container(
        height: 34,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFF1B4D3E).withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFF1B4D3E).withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              size: 14,
              color: const Color(0xFFC5A059), // Gold
            ),
            SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                query,
                style: TextStyle(
                  fontSize: isUrdu ? 16 : 13,
                  fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                  height: isUrdu ? 1.8 : 1.4,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
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
