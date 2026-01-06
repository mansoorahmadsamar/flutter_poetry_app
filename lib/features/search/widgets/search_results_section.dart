import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poet_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/widgets/couplet_card.dart';
import 'package:flutter_poetry_app/features/search/utils/search_adapters.dart';
import 'package:flutter_poetry_app/features/search/widgets/poet_result_card.dart';

/// Search results section with editorial layout
///
/// Features:
/// - Strong query heading with confident typography
/// - Subtle results count
/// - Secondary filters
/// - Generous spacing between couplets
/// - Urdu text as hero element
class SearchResultsSection extends ConsumerWidget {
  const SearchResultsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(globalSearchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    debugPrint('🎨 SearchResultsSection build - mode: ${searchState.mode}');
    debugPrint('🎨 unifiedResults null? ${searchState.unifiedResults == null}');

    if (searchState.unifiedResults == null) {
      debugPrint('🎨 Returning empty - unifiedResults is null');
      return const SizedBox.shrink();
    }

    final results = searchState.unifiedResults!;
    final poets = results.poets;
    final couplets = results.couplets;

    debugPrint('🎨 SearchResultsSection - totalResults: ${results.totalResults}');
    debugPrint('🎨 Poets: ${poets.length}, Poems: ${results.poems.length}, Couplets: ${couplets.length}');

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

        SizedBox(height: AppSpacing.sm),

        // Filter chips
        _buildFilterChips(context, ref, isDark),

        SizedBox(height: AppSpacing.lg),

        // "Relevant Results" section header
        _buildSectionTitle(context, 'Relevant Results', isDark),

        SizedBox(height: AppSpacing.md),

        // Poet cards (horizontal scroll)
        if (poets.isNotEmpty) ...[
          _buildPoetsSection(context, poets, isDark),
          SizedBox(height: AppSpacing.lg),
        ],

        // Couplets with generous spacing
        if (couplets.isNotEmpty) ...[
          ...couplets.map((couplet) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.lg),
                child: _buildCoupletResultCard(context, ref, couplet),
              )),

          // Load more button removed for now - unified search doesn't support pagination yet

          SizedBox(height: AppSpacing.xl),
        ],

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

  /// Build filter chips (All, Read, Watch, Dictionary)
  Widget _buildFilterChips(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    final filters = ['All', 'Read', 'Watch', 'Dictionary'];
    const selectedFilter = 'All'; // For now, always All is selected

    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selectedFilter;

          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                // TODO: Implement filter selection
              },
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
              ),
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              selectedColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.1)),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
            ),
          );
        },
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
                    fontSize: isUrdu ? 15 : 13,
                    fontFamily: isUrdu ? 'JameelNoori' : null,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                    height: isUrdu ? 1.6 : 1.3,
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
