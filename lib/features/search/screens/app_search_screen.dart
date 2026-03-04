import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:flutter_poetry_app/features/search/widgets/app_search_bar.dart';
import 'package:flutter_poetry_app/features/search/widgets/app_search_segment_tabs.dart';
import 'package:flutter_poetry_app/features/search/widgets/app_search_idle_content.dart';
import 'package:flutter_poetry_app/features/search/widgets/app_search_suggestions.dart';
import 'package:flutter_poetry_app/features/search/widgets/app_search_preview_results.dart';
import 'package:flutter_poetry_app/features/search/widgets/app_search_filtered_results.dart';

/// Unified search screen — replaces both SearchScreen and GlobalSearchScreen.
///
/// Layout:
/// ```
/// Scaffold(bg: #FFFBF7 light / #1A1A1A dark)
///   SafeArea → Column
///     [1] AppSearchBar                  ← Fixed, never scrolls
///     [2] AppSearchSegmentTabs          ← Only visible in preview/filtered modes
///     [3] Expanded(AnimatedSwitcher)    ← Content keyed by mapped mode
///           → AppSearchIdleContent
///           → AppSearchSuggestions      (INLINE, not overlay)
///           → AppSearchPreviewResults   (Sliver-based grouped overview)
///           → AppSearchFilteredResults  (ListView.builder, virtualized)
/// ```
///
/// Performance: Uses selective `ref.watch(provider.select(...))` to minimize
/// widget rebuilds. Only watches mode + query at root level.
class AppSearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const AppSearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<AppSearchScreen> createState() => _AppSearchScreenState();
}

class _AppSearchScreenState extends ConsumerState<AppSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final query = widget.initialQuery;
      if (query != null && query.trim().isNotEmpty) {
        _searchController.text = query;
        ref.read(globalSearchProvider.notifier).executeSearch(query: query);
      } else {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Map 6-value SearchMode → 4 logical display modes
  // ---------------------------------------------------------------------------
  // Old enum still has 6 values (idle, typing, autocompleting, searching,
  // results, error) because other screens reference it. The new screen maps
  // these into 4 display modes internally. The enum will be simplified in
  // Phase 6 cleanup.
  _DisplayMode _mapMode(SearchMode mode, DiscoverSegment segment) {
    switch (mode) {
      case SearchMode.idle:
        return _DisplayMode.idle;

      case SearchMode.typing:
      case SearchMode.autocompleting:
        return _DisplayMode.suggesting;

      case SearchMode.searching:
      case SearchMode.results:
      case SearchMode.error:
        // If on "all" segment, show smart grouped preview.
        // Otherwise, show filtered single-segment list.
        if (segment == DiscoverSegment.all) {
          return _DisplayMode.preview;
        }
        return _DisplayMode.filtered;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Selective watching — only rebuild on mode/segment/query changes
    final mode = ref.watch(globalSearchProvider.select((s) => s.mode));
    final segment = ref.watch(
      globalSearchProvider.select((s) => s.activeSegment),
    );
    final languageCode = ref.watch(selectedLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = languageCode == 'ur' || languageCode == 'hi';
    final displayMode = _mapMode(mode, segment);

    // Show segment tabs in preview or filtered mode
    final showTabs = displayMode == _DisplayMode.preview ||
        displayMode == _DisplayMode.filtered;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : const Color(0xFFFFFBF7),
        body: SafeArea(
          child: Column(
            children: [
              // [1] Search bar — always fixed at top
              AppSearchBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                languageCode: languageCode,
                isLoading: ref.watch(
                  globalSearchProvider.select((s) => s.isLoadingAutocomplete),
                ),
                showBackButton: true,
                onChanged: (value) {
                  ref.read(globalSearchProvider.notifier).onQueryChanged(value);
                },
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    ref
                        .read(globalSearchProvider.notifier)
                        .executeSearch(query: value);
                    _searchFocusNode.unfocus();
                  }
                },
                onClear: () {
                  _searchController.clear();
                  ref.read(globalSearchProvider.notifier).reset();
                },
                onBack: () {
                  ref.read(globalSearchProvider.notifier).reset();
                  Navigator.of(context).pop();
                },
              ),

              // [2] Segment tabs — visible only in preview/filtered
              if (showTabs) const AppSearchSegmentTabs(),

              // [3] Content area — AnimatedSwitcher for smooth transitions
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: _buildContent(displayMode, isDark, languageCode),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    _DisplayMode displayMode,
    bool isDark,
    String languageCode,
  ) {
    switch (displayMode) {
      case _DisplayMode.idle:
        return AppSearchIdleContent(
          key: const ValueKey('idle'),
          onRecentTap: _executeQuery,
          onTrendingTap: _executeQuery,
          onPoetTap: (poet) {
            context.pushNamed(
              'poet-detail',
              pathParameters: {'publicId': poet.publicId},
            );
          },
          onCategoryTap: (category) {
            _executeQuery(category.primaryText);
          },
        );

      case _DisplayMode.suggesting:
        return AppSearchSuggestions(
          key: const ValueKey('suggesting'),
          onSuggestionTap: _executeQuery,
          onSearchTap: () {
            final query = ref.read(globalSearchProvider).currentQuery;
            if (query.isNotEmpty) {
              _executeQuery(query);
            }
          },
        );

      case _DisplayMode.preview:
        // Check for error state with no results
        final errorMessage = ref.watch(
          globalSearchProvider.select((s) => s.errorMessage),
        );
        final isLoading = ref.watch(
          globalSearchProvider.select((s) => s.isLoadingResults),
        );
        final hasResults = ref.watch(
          globalSearchProvider.select((s) => s.unifiedResults),
        ) != null;

        if (errorMessage != null && !hasResults && !isLoading) {
          return _buildErrorState(isDark, errorMessage);
        }

        return AppSearchPreviewResults(
          key: const ValueKey('preview'),
          onRelatedSearchTap: _executeQuery,
        );

      case _DisplayMode.filtered:
        final activeSegment = ref.watch(
          globalSearchProvider.select((s) => s.activeSegment),
        );

        return AppSearchFilteredResults(
          key: ValueKey('filtered_${activeSegment.name}'),
          segment: activeSegment,
          onPoetTap: (poet) {
            context.pushNamed(
              'poet-detail',
              pathParameters: {'publicId': poet.publicId},
            );
          },
          onPoemTap: (poem) {
            context.pushNamed(
              'poem-detail',
              pathParameters: {'publicId': poem.publicId},
            );
          },
          onCoupletTap: (couplet) {
            // Navigate to poem detail with the couplet's poem
            if (couplet.poem != null) {
              context.pushNamed(
                'poem-detail',
                pathParameters: {'publicId': couplet.poem!.publicId},
              );
            }
          },
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _executeQuery(String query) {
    _searchController.text = query;
    ref.read(globalSearchProvider.notifier).executeSearch(query: query);
    _searchFocusNode.unfocus();
  }

  Widget _buildErrorState(bool isDark, String errorMessage) {
    return Center(
      key: const ValueKey('error'),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.7),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'تلاش میں خرابی',
              style: TextStyle(
                fontFamily: 'Jameel Noori Nastaleeq',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                height: 1.8,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Jameel Noori Nastaleeq',
                fontSize: 16,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                height: 1.8,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(globalSearchProvider.notifier).clearError();
                ref.read(globalSearchProvider.notifier).executeSearch();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'دوبارہ کوشش کریں',
                style: TextStyle(
                  fontFamily: 'Jameel Noori Nastaleeq',
                  fontSize: 16,
                  height: 1.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal display mode (maps 6-value enum to 4 display states)
// ---------------------------------------------------------------------------

enum _DisplayMode {
  idle,
  suggesting,
  preview,
  filtered,
}
