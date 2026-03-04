import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';

/// Empty state widget for bookmarks screen.
/// English title + subtitle, with CTA button.
class AppBookmarkEmptyState extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onDiscoverTap;
  final String? activeFilter;

  const AppBookmarkEmptyState({
    super.key,
    required this.isDark,
    this.onDiscoverTap,
    this.activeFilter,
  });

  @override
  Widget build(BuildContext context) {
    final isFiltered = activeFilter != null && activeFilter != 'ALL';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltered
                    ? Icons.filter_list_off_rounded
                    : Icons.bookmark_border_rounded,
                size: 56,
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.primary.withValues(alpha: 0.3),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              isFiltered ? _filteredTitle() : 'No bookmarks yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : AppColors.textPrimaryLight,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              isFiltered
                  ? 'No bookmarks match this filter'
                  : 'Tap the bookmark icon on any poem or couplet to save it here',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : AppColors.textSecondaryLight,
              ),
            ),

            if (!isFiltered && onDiscoverTap != null) ...[
              const SizedBox(height: 24),

              FilledButton(
                onPressed: onDiscoverTap,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Discover poetry',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _filteredTitle() {
    switch (activeFilter?.toUpperCase()) {
      case 'POEM':
        return 'No poems bookmarked';
      case 'COUPLET':
        return 'No couplets bookmarked';
      case 'IMAGE':
        return 'No images bookmarked';
      default:
        return 'No bookmarks found';
    }
  }
}

/// Search empty state
class AppBookmarkSearchEmpty extends StatelessWidget {
  final String query;
  final bool isDark;

  const AppBookmarkSearchEmpty({
    super.key,
    required this.query,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 16),
            Text(
              'No bookmarks found for "$query"',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.5,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state with retry
class AppBookmarkErrorState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;

  const AppBookmarkErrorState({
    super.key,
    required this.isDark,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load bookmarks',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(
                'Try again',
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
