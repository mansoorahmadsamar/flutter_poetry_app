import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';

/// Horizontal scrollable segment tabs for search results
///
/// Segments: All, Poets, Ghazals, Nazams, Verses, Categories
class SearchSegmentTabs extends ConsumerWidget {
  const SearchSegmentTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(globalSearchProvider);
    final languageCode = ref.watch(selectedLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeSegment = searchState.activeSegment;

    final segments = _getSegments(languageCode);

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        itemCount: segments.length,
        itemBuilder: (context, index) {
          final segment = segments[index];
          final isActive = segment.value == activeSegment;

          return Padding(
            padding: EdgeInsetsDirectional.only(
              end: AppSpacing.sm,
            ),
            child: _SegmentChip(
              label: segment.label,
              icon: segment.icon,
              isActive: isActive,
              isDark: isDark,
              languageCode: languageCode,
              onTap: () {
                ref.read(globalSearchProvider.notifier).setActiveSegment(segment.value);
              },
            ),
          );
        },
      ),
    );
  }

  List<_SegmentItem> _getSegments(String languageCode) {
    return [
      _SegmentItem(
        value: DiscoverSegment.all,
        label: languageCode == 'ur' ? 'سب' : (languageCode == 'hi' ? 'सभी' : 'All'),
        icon: Icons.apps_rounded,
      ),
      _SegmentItem(
        value: DiscoverSegment.poets,
        label: languageCode == 'ur' ? 'شعراء' : (languageCode == 'hi' ? 'कवि' : 'Poets'),
        icon: Icons.person_rounded,
      ),
      _SegmentItem(
        value: DiscoverSegment.poems,
        label: languageCode == 'ur' ? 'غزلیں' : (languageCode == 'hi' ? 'ग़ज़लें' : 'Ghazals'),
        icon: Icons.auto_stories_rounded,
      ),
      _SegmentItem(
        value: DiscoverSegment.verses,
        label: languageCode == 'ur' ? 'اشعار' : (languageCode == 'hi' ? 'शेर' : 'Verses'),
        icon: Icons.format_quote_rounded,
      ),
      _SegmentItem(
        value: DiscoverSegment.categories,
        label: languageCode == 'ur' ? 'زمرے' : (languageCode == 'hi' ? 'श्रेणियाँ' : 'Categories'),
        icon: Icons.category_rounded,
      ),
    ];
  }
}

class _SegmentItem {
  final DiscoverSegment value;
  final String label;
  final IconData icon;

  const _SegmentItem({
    required this.value,
    required this.label,
    required this.icon,
  });
}

class _SegmentChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final bool isDark;
  final String languageCode;
  final VoidCallback onTap;

  const _SegmentChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isDark,
    required this.languageCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : (isDark
                  ? AppColors.backgroundDark
                  : AppColors.verseBackground),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive
                  ? Colors.white
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontFamily: languageCode == 'ur'
                    ? 'Jameel Noori Nastaleeq'
                    : (languageCode == 'hi' ? 'NotoSansDevanagari' : null),
                fontSize: languageCode == 'ur' ? 15 : 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? Colors.white
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
                height: languageCode == 'ur' ? 1.8 : 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
