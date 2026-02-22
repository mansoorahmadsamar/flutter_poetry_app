import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';

/// Segment data for each tab chip.
class _SegmentData {
  final DiscoverSegment segment;
  final String urduLabel;
  final String hindiLabel;
  final String englishLabel;
  final IconData icon;

  const _SegmentData({
    required this.segment,
    required this.urduLabel,
    required this.hindiLabel,
    required this.englishLabel,
    required this.icon,
  });

  String label(String languageCode) {
    switch (languageCode) {
      case 'ur':
        return urduLabel;
      case 'hi':
        return hindiLabel;
      default:
        return englishLabel;
    }
  }
}

/// 5-segment tab bar (Urdu-first labels, no Dictionary/Watch).
///
/// Segments: سب | شعراء | غزلیں | اشعار | زمرے
///
/// Only watches `activeSegment` via `.select()` to minimize rebuilds.
class AppSearchSegmentTabs extends ConsumerWidget {
  const AppSearchSegmentTabs({super.key});

  static const _segments = [
    _SegmentData(
      segment: DiscoverSegment.all,
      urduLabel: 'سب',
      hindiLabel: 'सभी',
      englishLabel: 'All',
      icon: Icons.explore_rounded,
    ),
    _SegmentData(
      segment: DiscoverSegment.poets,
      urduLabel: 'شعراء',
      hindiLabel: 'कवि',
      englishLabel: 'Poets',
      icon: Icons.person_rounded,
    ),
    _SegmentData(
      segment: DiscoverSegment.poems,
      urduLabel: 'غزلیں',
      hindiLabel: 'ग़ज़लें',
      englishLabel: 'Ghazals',
      icon: Icons.auto_stories_rounded,
    ),
    _SegmentData(
      segment: DiscoverSegment.verses,
      urduLabel: 'اشعار',
      hindiLabel: 'शेर',
      englishLabel: 'Verses',
      icon: Icons.format_quote_rounded,
    ),
    _SegmentData(
      segment: DiscoverSegment.categories,
      urduLabel: 'زمرے',
      hindiLabel: 'श्रेणियाँ',
      englishLabel: 'Categories',
      icon: Icons.category_rounded,
    ),
  ];

  /// Get the total DB count for a segment from unified results.
  /// Returns 0 if no results available (count won't be shown).
  static int _totalForSegment(
    UnifiedSearchResponse? results,
    DiscoverSegment segment,
  ) {
    if (results == null) return 0;
    switch (segment) {
      case DiscoverSegment.all:
        return 0; // "All" doesn't show a count
      case DiscoverSegment.poets:
        return results.totalPoets;
      case DiscoverSegment.poems:
        return results.totalPoems;
      case DiscoverSegment.verses:
        return results.totalCouplets;
      case DiscoverSegment.categories:
        return results.totalCategories;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSegment = ref.watch(
      globalSearchProvider.select((s) => s.activeSegment),
    );
    final unifiedResults = ref.watch(
      globalSearchProvider.select((s) => s.unifiedResults),
    );
    final languageCode = ref.watch(selectedLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 1,
          ),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        itemCount: _segments.length,
        separatorBuilder: (_, __) => SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final data = _segments[index];
          final isActive = activeSegment == data.segment;
          final isUrdu = languageCode == 'ur';
          final total = _totalForSegment(unifiedResults, data.segment);

          // Build label with optional count: "شعراء (12)"
          final label = total > 0
              ? '${data.label(languageCode)} ($total)'
              : data.label(languageCode);

          return GestureDetector(
            onTap: () {
              ref
                  .read(globalSearchProvider.notifier)
                  .setActiveSegment(data.segment);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: isActive
                    ? null
                    : Border.all(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        width: 1,
                      ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    data.icon,
                    size: 16,
                    color: isActive
                        ? Colors.white
                        : AppColors.primary,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily:
                          isUrdu ? 'Jameel Noori Nastaleeq' : null,
                      fontSize: isUrdu ? 15 : 13,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? Colors.white
                          : AppColors.primary,
                      height: isUrdu ? 1.8 : 1.4,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
