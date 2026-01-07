import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';

/// Recent searches discovery section
///
/// Features:
/// - Case-insensitive deduplication (MANSOOR/Mansoo → single chip)
/// - Max 6 recent searches displayed
/// - "See all" button if more than 6 exist
/// - Consistent chip height (34px)
/// - No card container (matching trending section)
/// - Subtle "Clear" button
class RecentSearchesSection extends ConsumerWidget {
  const RecentSearchesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(globalSearchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (searchState.recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    // Normalize and limit searches
    final normalized = _normalizeSearches(searchState.recentSearches);
    final displaySearches = normalized.take(6).toList();
    final hasMore = normalized.length > 6;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with clear button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
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
                    'Clear',
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
          ),

          SizedBox(height: AppSpacing.md),

          // Recent searches chips
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                ...displaySearches.map((query) => _buildRecentChip(
                  context,
                  ref,
                  query,
                  isDark,
                )),
                if (hasMore)
                  _buildSeeAllChip(context, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Normalize searches (case-insensitive deduplication)
  List<String> _normalizeSearches(List<String> searches) {
    final seen = <String, String>{};
    final result = <String>[];

    for (final search in searches) {
      final lower = search.toLowerCase();
      if (!seen.containsKey(lower)) {
        seen[lower] = search;
        result.add(search);
      }
    }
    return result;
  }

  /// Build a single recent search chip
  Widget _buildRecentChip(
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
              Icons.history,
              size: 14,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.5),
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

  /// Build "See all" chip
  Widget _buildSeeAllChip(BuildContext context, bool isDark) {
    return Container(
      height: 34,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFF1B4D3E).withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFF1B4D3E).withValues(alpha: 0.12),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'See all',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(width: 4),
          Icon(
            Icons.arrow_forward,
            size: 12,
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.5),
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
