import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';

/// Recent searches discovery section
///
/// Features:
/// - ActionChips with history icon
/// - "Clear All" button
/// - Tap to execute search
/// - Language-aware labels
/// - Paper aesthetic with minimal design
class RecentSearchesSection extends ConsumerWidget {
  const RecentSearchesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(globalSearchProvider);
    final languageCode = ref.watch(selectedLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (searchState.recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with clear button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 18,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.black.withValues(alpha: 0.7),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    _getLabel('Recent Searches', languageCode),
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
              TextButton(
                onPressed: () async {
                  // Clear all recent searches
                  final historyService = ref.read(searchHistoryServiceProvider);
                  await historyService.clearAll();

                  // Refresh recent searches in state
                  await ref.read(globalSearchProvider.notifier).refreshRecentSearches();
                },
                child: Text(
                  _getLabel('Clear All', languageCode),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.black.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.xs),

          // Recent searches chips
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: searchState.recentSearches.map((query) {
              return ActionChip(
                label: Text(query),
                labelStyle: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
                  width: 1,
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

  /// Get localized label
  String _getLabel(String key, String languageCode) {
    final labels = {
      'ur': {
        'Recent Searches': 'حالیہ تلاش',
        'Clear All': 'سب صاف کریں',
      },
      'hi': {
        'Recent Searches': 'हाल की खोजें',
        'Clear All': 'सभी साफ़ करें',
      },
      'en': {
        'Recent Searches': 'Recent Searches',
        'Clear All': 'Clear All',
      },
    };

    return labels[languageCode]?[key] ?? labels['en']![key]!;
  }
}
