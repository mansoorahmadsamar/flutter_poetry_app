import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poet_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/widgets/couplet_card.dart';
import 'package:flutter_poetry_app/features/search/utils/search_adapters.dart';
import 'package:flutter_poetry_app/features/search/widgets/poet_result_card.dart';
import 'package:flutter_poetry_app/features/search/widgets/couplet_sort_dropdown.dart';

/// Search results section with segment-aware rendering
///
/// Features:
/// - Segment-based content display (All, Poets, Poems, Verses, Categories)
/// - Sort dropdown for Verses segment
/// - Generous spacing between couplets
/// - Urdu text as hero element
/// - Related searches at bottom
class SearchResultsSection extends ConsumerWidget {
  const SearchResultsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(globalSearchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (searchState.unifiedResults == null) {
      return const SizedBox.shrink();
    }

    final results = searchState.unifiedResults!;
    final activeSegment = searchState.activeSegment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Query text display
        _buildQueryDisplay(
          context,
          searchState.currentQuery,
          results.totalResults,
          isDark,
        ),

        SizedBox(height: AppSpacing.md),

        // Sort dropdown for Verses segment
        if (activeSegment == DiscoverSegment.verses)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CoupletSortDropdown(),
              ],
            ),
          ),

        SizedBox(height: AppSpacing.lg),

        // Segment-based content rendering
        _buildSegmentContent(context, ref, searchState, results, isDark),

        // Related searches
        if (searchState.relatedSearches != null &&
            searchState.relatedSearches!.relatedSearches.isNotEmpty) ...[
          _buildRelatedSearches(
            context,
            ref,
            searchState.relatedSearches!.relatedSearches,
            isDark,
          ),
          SizedBox(height: AppSpacing.xl),
        ],
      ],
    );
  }

  /// Build content based on active segment
  Widget _buildSegmentContent(
    BuildContext context,
    WidgetRef ref,
    GlobalSearchState searchState,
    UnifiedSearchResponse results,
    bool isDark,
  ) {
    switch (searchState.activeSegment) {
      case DiscoverSegment.all:
        return _buildAllResults(context, ref, results, isDark);

      case DiscoverSegment.poets:
        return _buildPoetsOnlyResults(context, results.poets, isDark);

      case DiscoverSegment.poems:
        return _buildPoemsOnlyResults(context, results.poems, isDark);

      case DiscoverSegment.verses:
        return _buildVersesOnlyResults(context, ref, results.couplets, isDark);

      case DiscoverSegment.categories:
        return _buildCategoriesResults(context, isDark);

      case DiscoverSegment.dictionary:
      case DiscoverSegment.watch:
        // Should never reach here as these are handled in SearchTab
        return const SizedBox.shrink();
    }
  }

  /// Build "All" segment results (mixed content)
  Widget _buildAllResults(
    BuildContext context,
    WidgetRef ref,
    UnifiedSearchResponse results,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Poet cards (horizontal scroll)
        if (results.poets.isNotEmpty) ...[
          _buildSectionTitle(context, 'Poets', isDark),
          SizedBox(height: AppSpacing.md),
          _buildPoetsSection(context, results.poets, isDark),
          SizedBox(height: AppSpacing.lg),
        ],

        // Couplets/Verses
        if (results.couplets.isNotEmpty) ...[
          _buildSectionTitle(context, 'Verses', isDark),
          SizedBox(height: AppSpacing.md),
          ...results.couplets.map((couplet) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: _buildCoupletResultCard(context, ref, couplet),
              )),
          SizedBox(height: AppSpacing.xl),
        ],
      ],
    );
  }

  /// Build Poets-only results (compact list)
  Widget _buildPoetsOnlyResults(
    BuildContext context,
    List<PoetModel> poets,
    bool isDark,
  ) {
    if (poets.isEmpty) {
      return _buildEmptySegmentState(context, 'No poets found', isDark);
    }

    return Column(
      children: poets.map((poet) {
        final poetSummary = PoetSummary(
          publicId: poet.publicId,
          name: poet.name,
          profileImageUrl: poet.profileImageUrl,
        );
        final eraText = _formatEra(poet.birthYear, poet.deathYear);
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
          child: PoetResultCard(
            poet: poetSummary,
            era: eraText,
          ),
        );
      }).toList(),
    );
  }

  /// Build Poems-only results
  Widget _buildPoemsOnlyResults(
    BuildContext context,
    List<dynamic> poems,
    bool isDark,
  ) {
    if (poems.isEmpty) {
      return _buildEmptySegmentState(context, 'No poems found', isDark);
    }

    // TODO: Implement poem cards when poem model is ready
    return _buildEmptySegmentState(
      context,
      'Poem results coming soon',
      isDark,
    );
  }

  /// Build Verses-only results (sorted)
  Widget _buildVersesOnlyResults(
    BuildContext context,
    WidgetRef ref,
    List<CoupletSearchResult> couplets,
    bool isDark,
  ) {
    if (couplets.isEmpty) {
      return _buildEmptySegmentState(context, 'No verses found', isDark);
    }

    return Column(
      children: couplets.map((couplet) => Padding(
            padding: EdgeInsets.only(
              bottom: AppSpacing.md,
            ),
            child: _buildCoupletResultCard(context, ref, couplet),
          )).toList(),
    );
  }

  /// Build Categories results
  Widget _buildCategoriesResults(
    BuildContext context,
    bool isDark,
  ) {
    // TODO: Implement when categories API is available
    return _buildEmptySegmentState(
      context,
      'Category results coming soon',
      isDark,
    );
  }

  /// Build empty segment state
  Widget _buildEmptySegmentState(
    BuildContext context,
    String message,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  /// Build query display (subtle, not dominant like screenshot)
  Widget _buildQueryDisplay(
    BuildContext context,
    String query,
    int totalResults,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Text(
        'Showing results for "$query"',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: isDark
              ? Colors.white.withValues(alpha: 0.5)
              : Colors.black.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  /// Build section title
  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  /// Build poets section (horizontal scroll)
  Widget _buildPoetsSection(
    BuildContext context,
    List<PoetModel> poets,
    bool isDark,
  ) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: poets.length,
        itemBuilder: (context, index) {
          final poet = poets[index];
          // Convert PoetModel to PoetSummary for the card
          final poetSummary = PoetSummary(
            publicId: poet.publicId,
            name: poet.name,
            profileImageUrl: poet.profileImageUrl,
          );
          // Format era from birth/death years
          final eraText = _formatEra(poet.birthYear, poet.deathYear);
          return PoetResultCard(
            poet: poetSummary,
            era: eraText,
          );
        },
      ),
    );
  }

  /// Format era text from birth and death years
  String? _formatEra(int birthYear, int deathYear) {
    if (birthYear == 0) return null;
    if (deathYear == 0) {
      return '$birthYear - Present';
    }
    return '$birthYear - $deathYear';
  }

  /// Build couplet result card
  Widget _buildCoupletResultCard(
    BuildContext context,
    WidgetRef ref,
    CoupletSearchResult couplet,
  ) {
    return CoupletCard(
      couplet: convertSearchResultToCoupletModel(couplet),
      // TODO: Add navigation when poem publicId is available from search API
      // For now, keep null to disable tap (user can still use like/bookmark/share actions)
      onTap: null,
    );
  }

  /// Build related searches section
  Widget _buildRelatedSearches(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> relatedSearches,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Related Searches',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.9)
                  : Colors.black.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: relatedSearches.map((search) {
              final query = search.query ?? search.toString();
              final isUrdu = _isUrduText(query);
              return ActionChip(
                label: Text(
                  query,
                  style: TextStyle(
                    fontSize: isUrdu ? 16 : 13,
                    fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                    height: isUrdu ? 1.8 : 1.4,
                  ),
                ),
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 1,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: isUrdu ? AppSpacing.xs + 2 : AppSpacing.xs,
                ),
                onPressed: () {
                  ref.read(globalSearchProvider.notifier).executeSearch(
                    query: query,
                  );
                },
              );
            }).toList(),
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
