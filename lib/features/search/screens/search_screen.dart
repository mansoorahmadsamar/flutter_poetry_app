import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/widgets/search_app_bar.dart';
import 'package:flutter_poetry_app/features/search/widgets/search_discovery_content.dart';
import 'package:flutter_poetry_app/features/search/widgets/search_autocomplete_overlay.dart';
import 'package:flutter_poetry_app/features/search/widgets/search_results_content.dart';
import 'package:flutter_poetry_app/features/search/widgets/search_segment_tabs.dart';

/// Premium full-screen search experience
///
/// Features:
/// - Clean search bar at top (no hero section)
/// - Urdu-first typography with RTL support
/// - Rich discovery content before typing
/// - Autocomplete while typing
/// - Comprehensive results with sections after search
/// - Brand colors: Deep Green (#1B4D3E), Gold (#C5A059), Cream background
class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final query = widget.initialQuery;
      if (query != null && query.trim().isNotEmpty) {
        // Pre-fill and execute search for initial query
        _searchController.text = query;
        ref.read(globalSearchProvider.notifier).executeSearch(query: query);
      } else {
        // Auto-focus the search field when screen opens
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

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(globalSearchProvider);
    final languageCode = ref.watch(selectedLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = languageCode == 'ur' || languageCode == 'hi';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : const Color(0xFFFFFBF7), // Warm cream
        body: SafeArea(
          child: Column(
            children: [
              // Search App Bar
              SearchAppBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                languageCode: languageCode,
                isLoading: searchState.isLoadingAutocomplete,
                onChanged: (value) {
                  ref.read(globalSearchProvider.notifier).onQueryChanged(value);
                },
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    ref.read(globalSearchProvider.notifier).executeSearch(query: value);
                    _searchFocusNode.unfocus();
                  }
                },
                onClear: () {
                  _searchController.clear();
                  ref.read(globalSearchProvider.notifier).reset();
                },
                onBack: () {
                  // Clear search state before navigating back
                  ref.read(globalSearchProvider.notifier).reset();
                  Navigator.of(context).pop();
                },
              ),

              // Segment Tabs (only show when we have results)
              if (searchState.mode == SearchMode.results &&
                  searchState.unifiedResults != null)
                const SearchSegmentTabs(),

              // Main Content
              Expanded(
                child: _buildContent(context, searchState, isDark, languageCode),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    GlobalSearchState searchState,
    bool isDark,
    String languageCode,
  ) {
    switch (searchState.mode) {
      case SearchMode.idle:
      case SearchMode.typing:
        // Show discovery content (recent, trending, top poets, etc.)
        return const SearchDiscoveryContent();

      case SearchMode.autocompleting:
        // Show autocomplete suggestions over discovery content
        return Stack(
          children: [
            const SearchDiscoveryContent(),
            if (searchState.autocompleteResults != null)
              SearchAutocompleteOverlay(
                results: searchState.autocompleteResults!,
                onSelect: (query) {
                  _searchController.text = query;
                  ref.read(globalSearchProvider.notifier).executeSearch(query: query);
                  _searchFocusNode.unfocus();
                },
              ),
          ],
        );

      case SearchMode.searching:
        return _buildLoadingState(isDark);

      case SearchMode.results:
        return SearchResultsContent(
          results: searchState.unifiedResults,
          activeSegment: searchState.activeSegment,
          query: searchState.currentQuery,
          relatedSearches: searchState.relatedSearches,
          onRelatedSearchTap: (query) {
            _searchController.text = query;
            ref.read(globalSearchProvider.notifier).executeSearch(query: query);
          },
        );

      case SearchMode.error:
        return _buildErrorState(
          context,
          searchState.errorMessage,
          isDark,
        );
    }
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppColors.secondary : AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'تلاش جاری ہے...',
            style: TextStyle(
              fontFamily: 'Jameel Noori Nastaleeq',
              fontSize: 18,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? errorMessage, bool isDark) {
    return Center(
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
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                height: 1.8,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              errorMessage ?? 'کچھ غلط ہو گیا',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Jameel Noori Nastaleeq',
                fontSize: 16,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                height: 1.8,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () {
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
