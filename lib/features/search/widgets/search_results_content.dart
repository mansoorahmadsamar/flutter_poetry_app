import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poet_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/widgets/couplet_card.dart';
import 'package:flutter_poetry_app/features/search/utils/search_adapters.dart';

/// Search results content with segment-aware rendering
///
/// Features:
/// - Segment-based content display (All, Poets, Ghazals, Verses, Categories)
/// - Section headers with counts and "See All" buttons
/// - Rich, readable content with proper typography
/// - Related searches at bottom
class SearchResultsContent extends ConsumerWidget {
  final UnifiedSearchResponse? results;
  final DiscoverSegment activeSegment;
  final String query;
  final RelatedSearchesResponse? relatedSearches;
  final ValueChanged<String> onRelatedSearchTap;

  const SearchResultsContent({
    super.key,
    required this.results,
    required this.activeSegment,
    required this.query,
    this.relatedSearches,
    required this.onRelatedSearchTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(selectedLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (results == null || results!.totalResults == 0) {
      return _buildEmptyState(context, isDark, languageCode);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Query info
          _buildQueryInfo(isDark, languageCode),

          SizedBox(height: AppSpacing.md),

          // Segment-based content
          _buildSegmentContent(context, ref, isDark, languageCode),

          // Related Searches
          if (relatedSearches != null &&
              relatedSearches!.relatedSearches.isNotEmpty)
            _buildRelatedSearches(isDark, languageCode),

          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildQueryInfo(bool isDark, String languageCode) {
    final isUrdu = _isUrduText(query);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Text(
        _getResultsText(languageCode),
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
        style: TextStyle(
          fontFamily: languageCode == 'ur' ? 'Jameel Noori Nastaleeq' : null,
          fontSize: languageCode == 'ur' ? 14 : 13,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          height: languageCode == 'ur' ? 1.8 : 1.4,
        ),
      ),
    );
  }

  String _getResultsText(String languageCode) {
    switch (languageCode) {
      case 'ur':
        return '"$query" کے لیے ${results!.totalResults} نتائج';
      case 'hi':
        return '"$query" के लिए ${results!.totalResults} परिणाम';
      default:
        return '${results!.totalResults} results for "$query"';
    }
  }

  Widget _buildSegmentContent(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    String languageCode,
  ) {
    switch (activeSegment) {
      case DiscoverSegment.all:
        return _buildAllResults(context, ref, isDark, languageCode);
      case DiscoverSegment.poets:
        return _buildPoetsResults(context, isDark, languageCode);
      case DiscoverSegment.poems:
        return _buildPoemsResults(context, isDark, languageCode);
      case DiscoverSegment.verses:
        return _buildVersesResults(context, ref, isDark, languageCode);
      case DiscoverSegment.categories:
        return _buildCategoriesResults(context, isDark, languageCode);
      case DiscoverSegment.dictionary:
      case DiscoverSegment.watch:
        return const SizedBox.shrink();
    }
  }

  /// Build "All" segment - shows top 5 from each category
  Widget _buildAllResults(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    String languageCode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Poets Section
        if (results!.poets.isNotEmpty)
          _buildSection(
            context: context,
            ref: ref,
            title: _getPoetsTitle(languageCode),
            count: results!.poetCount,
            icon: Icons.person_rounded,
            isDark: isDark,
            languageCode: languageCode,
            onSeeAll: results!.poets.length > 5
                ? () => ref.read(globalSearchProvider.notifier)
                    .setActiveSegment(DiscoverSegment.poets)
                : null,
            child: _buildPoetsHorizontalList(
              context,
              results!.poets.take(5).toList(),
              isDark,
              languageCode,
            ),
          ),

        // Verses Section
        if (results!.couplets.isNotEmpty)
          _buildSection(
            context: context,
            ref: ref,
            title: _getVersesTitle(languageCode),
            count: results!.coupletCount,
            icon: Icons.format_quote_rounded,
            isDark: isDark,
            languageCode: languageCode,
            onSeeAll: results!.couplets.length > 5
                ? () => ref.read(globalSearchProvider.notifier)
                    .setActiveSegment(DiscoverSegment.verses)
                : null,
            child: Column(
              children: results!.couplets.take(5).map((couplet) {
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: CoupletCard(
                    couplet: convertSearchResultToCoupletModel(couplet),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  /// Build Poets-only results
  Widget _buildPoetsResults(
    BuildContext context,
    bool isDark,
    String languageCode,
  ) {
    if (results!.poets.isEmpty) {
      return _buildEmptySegmentState(
        _getNoPoetsText(languageCode),
        isDark,
        languageCode,
      );
    }

    return Column(
      children: results!.poets.map((poet) {
        return _PoetResultCard(
          poet: poet,
          isDark: isDark,
          languageCode: languageCode,
          onTap: () => context.push('/main/poets/${poet.publicId}'),
        );
      }).toList(),
    );
  }

  /// Build Poems/Ghazals results
  Widget _buildPoemsResults(
    BuildContext context,
    bool isDark,
    String languageCode,
  ) {
    return _buildEmptySegmentState(
      _getComingSoonText(languageCode),
      isDark,
      languageCode,
    );
  }

  /// Build Verses results
  Widget _buildVersesResults(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    String languageCode,
  ) {
    if (results!.couplets.isEmpty) {
      return _buildEmptySegmentState(
        _getNoVersesText(languageCode),
        isDark,
        languageCode,
      );
    }

    return Column(
      children: results!.couplets.map((couplet) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: CoupletCard(
            couplet: convertSearchResultToCoupletModel(couplet),
          ),
        );
      }).toList(),
    );
  }

  /// Build Categories results
  Widget _buildCategoriesResults(
    BuildContext context,
    bool isDark,
    String languageCode,
  ) {
    return _buildEmptySegmentState(
      _getComingSoonText(languageCode),
      isDark,
      languageCode,
    );
  }

  /// Build a section with header and content
  Widget _buildSection({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required int count,
    required IconData icon,
    required bool isDark,
    required String languageCode,
    required Widget child,
    VoidCallback? onSeeAll,
  }) {
    final isUrdu = languageCode == 'ur';

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                        fontSize: isUrdu ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        height: isUrdu ? 1.8 : 1.4,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (onSeeAll != null)
                  TextButton(
                    onPressed: onSeeAll,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getSeeAllText(languageCode),
                          style: TextStyle(
                            fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                            fontSize: isUrdu ? 14 : 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                            height: isUrdu ? 1.8 : 1.4,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.md),

          // Content
          child,
        ],
      ),
    );
  }

  /// Build horizontal poets list
  Widget _buildPoetsHorizontalList(
    BuildContext context,
    List<PoetModel> poets,
    bool isDark,
    String languageCode,
  ) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: poets.length,
        itemBuilder: (context, index) {
          final poet = poets[index];
          return Padding(
            padding: EdgeInsetsDirectional.only(end: AppSpacing.md),
            child: _PoetMiniCard(
              name: poet.name,
              imageUrl: poet.profileImageUrl,
              isDark: isDark,
              languageCode: languageCode,
              onTap: () => context.push('/main/poets/${poet.publicId}'),
            ),
          );
        },
      ),
    );
  }

  /// Build related searches section
  Widget _buildRelatedSearches(bool isDark, String languageCode) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.manage_search_rounded,
                size: 20,
                color: AppColors.secondary,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                _getRelatedSearchesTitle(languageCode),
                style: TextStyle(
                  fontFamily: languageCode == 'ur'
                      ? 'Jameel Noori Nastaleeq'
                      : null,
                  fontSize: languageCode == 'ur' ? 16 : 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  height: languageCode == 'ur' ? 1.8 : 1.4,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: relatedSearches!.relatedSearches.map((search) {
              final searchQuery = search.query;
              final isUrdu = _isUrduText(searchQuery);
              return GestureDetector(
                onTap: () => onRelatedSearchTap(searchQuery),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.verseBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Text(
                    searchQuery,
                    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    style: TextStyle(
                      fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                      fontSize: isUrdu ? 14 : 13,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      height: isUrdu ? 1.8 : 1.4,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    String languageCode,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: isDark
                  ? AppColors.textDisabledDark
                  : AppColors.textDisabledLight,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              _getNoResultsTitle(languageCode),
              style: TextStyle(
                fontFamily: languageCode == 'ur'
                    ? 'Jameel Noori Nastaleeq'
                    : null,
                fontSize: languageCode == 'ur' ? 20 : 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                height: languageCode == 'ur' ? 1.8 : 1.4,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              _getNoResultsSubtitle(languageCode),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: languageCode == 'ur'
                    ? 'Jameel Noori Nastaleeq'
                    : null,
                fontSize: languageCode == 'ur' ? 16 : 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                height: languageCode == 'ur' ? 1.8 : 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySegmentState(
    String message,
    bool isDark,
    String languageCode,
  ) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: languageCode == 'ur' ? 'Jameel Noori Nastaleeq' : null,
            fontSize: languageCode == 'ur' ? 16 : 14,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            height: languageCode == 'ur' ? 1.8 : 1.4,
          ),
        ),
      ),
    );
  }

  // Localized strings
  String _getPoetsTitle(String lang) =>
      lang == 'ur' ? 'شعراء' : (lang == 'hi' ? 'कवि' : 'Poets');
  String _getVersesTitle(String lang) =>
      lang == 'ur' ? 'اشعار' : (lang == 'hi' ? 'शेर' : 'Verses');
  String _getSeeAllText(String lang) =>
      lang == 'ur' ? 'سب دیکھیں' : (lang == 'hi' ? 'सभी देखें' : 'See All');
  String _getRelatedSearchesTitle(String lang) =>
      lang == 'ur' ? 'متعلقہ تلاش' : (lang == 'hi' ? 'संबंधित खोज' : 'Related Searches');
  String _getNoResultsTitle(String lang) =>
      lang == 'ur' ? 'کوئی نتیجہ نہیں ملا' : (lang == 'hi' ? 'कोई परिणाम नहीं मिला' : 'No Results Found');
  String _getNoResultsSubtitle(String lang) =>
      lang == 'ur' ? 'مختلف الفاظ استعمال کریں' : (lang == 'hi' ? 'अलग शब्द आज़माएं' : 'Try different keywords');
  String _getNoPoetsText(String lang) =>
      lang == 'ur' ? 'کوئی شاعر نہیں ملا' : (lang == 'hi' ? 'कोई कवि नहीं मिला' : 'No poets found');
  String _getNoVersesText(String lang) =>
      lang == 'ur' ? 'کوئی شعر نہیں ملا' : (lang == 'hi' ? 'कोई शेर नहीं मिला' : 'No verses found');
  String _getComingSoonText(String lang) =>
      lang == 'ur' ? 'جلد آرہا ہے' : (lang == 'hi' ? 'जल्द आ रहा है' : 'Coming Soon');

  bool _isUrduText(String text) {
    final urduPattern = RegExp(r'[\u0600-\u06FF]');
    return urduPattern.hasMatch(text);
  }
}

/// Poet result card (full width)
class _PoetResultCard extends StatelessWidget {
  final PoetModel poet;
  final bool isDark;
  final String languageCode;
  final VoidCallback onTap;

  const _PoetResultCard({
    required this.poet,
    required this.isDark,
    required this.languageCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUrdu = _isUrduText(poet.name);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: poet.profileImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: poet.profileImageUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _buildPlaceholder(),
                      errorWidget: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),

            SizedBox(width: AppSpacing.md),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poet.name,
                    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    style: TextStyle(
                      fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                      fontSize: isUrdu ? 18 : 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      height: isUrdu ? 1.8 : 1.4,
                    ),
                  ),
                  if (poet.birthYear > 0) ...[
                    SizedBox(height: 4),
                    Text(
                      _formatEra(poet.birthYear, poet.deathYear),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDark
                  ? AppColors.textDisabledDark
                  : AppColors.textDisabledLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        size: 28,
        color: AppColors.primary.withValues(alpha: 0.5),
      ),
    );
  }

  String _formatEra(int birthYear, int deathYear) {
    if (deathYear == 0) return '$birthYear - Present';
    return '$birthYear - $deathYear';
  }

  bool _isUrduText(String text) {
    final urduPattern = RegExp(r'[\u0600-\u06FF]');
    return urduPattern.hasMatch(text);
  }
}

/// Poet mini card for horizontal scroll
class _PoetMiniCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool isDark;
  final String languageCode;
  final VoidCallback onTap;

  const _PoetMiniCard({
    required this.name,
    this.imageUrl,
    required this.isDark,
    required this.languageCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUrdu = _isUrduText(name);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      width: 90,
                      height: 70,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _buildPlaceholder(),
                      errorWidget: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),

            // Name
            Padding(
              padding: EdgeInsets.all(AppSpacing.xs),
              child: Text(
                name,
                textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                  fontSize: isUrdu ? 12 : 11,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  height: isUrdu ? 1.5 : 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 90,
      height: 70,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Icon(
        Icons.person_rounded,
        size: 28,
        color: AppColors.primary.withValues(alpha: 0.5),
      ),
    );
  }

  bool _isUrduText(String text) {
    final urduPattern = RegExp(r'[\u0600-\u06FF]');
    return urduPattern.hasMatch(text);
  }
}
