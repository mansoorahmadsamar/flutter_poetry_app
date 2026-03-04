import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/main/tabs/bookmarks/models/unified_bookmark_model.dart';

/// Segmented control for primary bookmark type browsing.
/// Shows: All | Poems | Couplets | Images — each with count badge.
class AppBookmarkSegmentedControl extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;
  final BookmarkStats? stats;
  final bool isDark;

  const AppBookmarkSegmentedControl({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    this.stats,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          _Segment(
            label: 'All',
            value: 'ALL',
            count: stats?.totalBookmarks,
            isSelected: selectedType == 'ALL',
            onTap: () => onTypeChanged('ALL'),
            isDark: isDark,
            isFirst: true,
          ),
          _Segment(
            label: 'Poems',
            value: 'POEM',
            count: stats?.poemBookmarks,
            isSelected: selectedType == 'POEM',
            onTap: () => onTypeChanged(
              selectedType == 'POEM' ? 'ALL' : 'POEM',
            ),
            isDark: isDark,
          ),
          _Segment(
            label: 'Couplets',
            value: 'COUPLET',
            count: stats?.coupletBookmarks,
            isSelected: selectedType == 'COUPLET',
            onTap: () => onTypeChanged(
              selectedType == 'COUPLET' ? 'ALL' : 'COUPLET',
            ),
            isDark: isDark,
          ),
          _Segment(
            label: 'Images',
            value: 'IMAGE',
            count: stats?.imageBookmarks,
            isSelected: selectedType == 'IMAGE',
            onTap: () => onTypeChanged(
              selectedType == 'IMAGE' ? 'ALL' : 'IMAGE',
            ),
            isDark: isDark,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final String value;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final bool isFirst;
  final bool isLast;

  const _Segment({
    required this.label,
    required this.value,
    this.count,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : Colors.transparent,
            borderRadius: BorderRadius.horizontal(
              left: isFirst ? const Radius.circular(8) : Radius.zero,
              right: isLast ? const Radius.circular(8) : Radius.zero,
            ),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppColors.primary.withValues(alpha: 0.7)
                          : AppColors.primary),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                (count ?? 0).toString(),
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.8)
                      : (isDark
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : AppColors.primary.withValues(alpha: 0.6)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Unified filter bottom sheet for Language + Sort.
/// Opened by the filter icon in the app bar.
class AppBookmarkFilterSheet extends StatefulWidget {
  final String selectedLanguage;
  final String selectedSortBy;
  final String selectedSortDir;
  final Map<String, int>? byLanguage;
  final bool isDark;

  const AppBookmarkFilterSheet({
    super.key,
    required this.selectedLanguage,
    required this.selectedSortBy,
    required this.selectedSortDir,
    this.byLanguage,
    required this.isDark,
  });

  /// Show the filter bottom sheet. Returns a [FilterResult] or null if dismissed.
  static Future<FilterResult?> show(
    BuildContext context, {
    required String selectedLanguage,
    required String selectedSortBy,
    required String selectedSortDir,
    Map<String, int>? byLanguage,
    required bool isDark,
  }) {
    return showModalBottomSheet<FilterResult>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AppBookmarkFilterSheet(
        selectedLanguage: selectedLanguage,
        selectedSortBy: selectedSortBy,
        selectedSortDir: selectedSortDir,
        byLanguage: byLanguage,
        isDark: isDark,
      ),
    );
  }

  @override
  State<AppBookmarkFilterSheet> createState() => _AppBookmarkFilterSheetState();
}

class _AppBookmarkFilterSheetState extends State<AppBookmarkFilterSheet> {
  late String _language;
  late String _sortBy;
  late String _sortDir;

  @override
  void initState() {
    super.initState();
    _language = widget.selectedLanguage;
    _sortBy = widget.selectedSortBy;
    _sortDir = widget.selectedSortDir;
  }

  bool get _hasChanges =>
      _language != widget.selectedLanguage ||
      _sortBy != widget.selectedSortBy ||
      _sortDir != widget.selectedSortDir;

  bool get _isDefault =>
      _language == 'ALL' &&
      _sortBy == 'bookmarkedAt' &&
      _sortDir == 'desc';

  void _reset() {
    setState(() {
      _language = 'ALL';
      _sortBy = 'bookmarkedAt';
      _sortDir = 'desc';
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      FilterResult(
        language: _language,
        sortBy: _sortBy,
        sortDir: _sortDir,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: widget.isDark
                        ? Colors.white
                        : AppColors.textPrimaryLight,
                  ),
                ),
                if (!_isDefault)
                  TextButton(
                    onPressed: _reset,
                    child: Text(
                      'Reset All',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Language section
            Text(
              'Language',
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: widget.isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterOption(
                  label: 'All',
                  count: null,
                  isSelected: _language == 'ALL',
                  onTap: () => setState(() => _language = 'ALL'),
                  isDark: widget.isDark,
                ),
                _FilterOption(
                  label: 'Urdu',
                  count: widget.byLanguage?['ur'],
                  isSelected: _language == 'ur',
                  onTap: () => setState(() => _language = 'ur'),
                  isDark: widget.isDark,
                ),
                _FilterOption(
                  label: 'English',
                  count: widget.byLanguage?['en'],
                  isSelected: _language == 'en',
                  onTap: () => setState(() => _language = 'en'),
                  isDark: widget.isDark,
                ),
                _FilterOption(
                  label: 'Hindi',
                  count: widget.byLanguage?['hi'],
                  isSelected: _language == 'hi',
                  onTap: () => setState(() => _language = 'hi'),
                  isDark: widget.isDark,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sort section
            Text(
              'Sort By',
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: widget.isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterOption(
                  label: 'Newest',
                  isSelected: _sortBy == 'bookmarkedAt' && _sortDir == 'desc',
                  onTap: () => setState(() {
                    _sortBy = 'bookmarkedAt';
                    _sortDir = 'desc';
                  }),
                  isDark: widget.isDark,
                ),
                _FilterOption(
                  label: 'Oldest',
                  isSelected: _sortBy == 'bookmarkedAt' && _sortDir == 'asc',
                  onTap: () => setState(() {
                    _sortBy = 'bookmarkedAt';
                    _sortDir = 'asc';
                  }),
                  isDark: widget.isDark,
                ),
                _FilterOption(
                  label: 'Popular',
                  isSelected: _sortBy == 'likeCount',
                  onTap: () => setState(() {
                    _sortBy = 'likeCount';
                    _sortDir = 'desc';
                  }),
                  isDark: widget.isDark,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Apply button
            FilledButton(
              onPressed: _hasChanges ? _apply : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: widget.isDark
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.15),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual filter option chip used inside the bottom sheet.
class _FilterOption extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _FilterOption({
    required this.label,
    this.count,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textPrimaryLight),
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 6),
              Text(
                '($count)',
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.8)
                      : (isDark
                          ? AppColors.textDisabledDark
                          : AppColors.textDisabledLight),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Result returned from the filter bottom sheet.
class FilterResult {
  final String language;
  final String sortBy;
  final String sortDir;

  const FilterResult({
    required this.language,
    required this.sortBy,
    required this.sortDir,
  });
}
