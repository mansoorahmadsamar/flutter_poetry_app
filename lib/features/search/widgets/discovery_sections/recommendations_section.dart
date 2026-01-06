import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/widgets/localized_text.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';

/// Recommendations discovery section
///
/// Features:
/// - Horizontal scrollable cards
/// - Urdu text prominent and large
/// - Poet name secondary and subtle
/// - Gentle shadows, rounded corners
/// - Literary aesthetic
class RecommendationsSection extends ConsumerWidget {
  const RecommendationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(globalSearchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (searchState.recommendations == null ||
        searchState.recommendations!.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final recommendations = searchState.recommendations!.items;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              'Recommended For You',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),

          SizedBox(height: AppSpacing.md),

          // Horizontal scrollable recommendations
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final item = recommendations[index];
                return _buildRecommendationCard(
                  context,
                  ref,
                  item.title,
                  item.poetName ?? '',
                  item.publicId,
                  isDark,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build a single recommendation card
  Widget _buildRecommendationCard(
    BuildContext context,
    WidgetRef ref,
    String title,
    String poetName,
    String publicId,
    bool isDark,
  ) {
    final isUrdu = _isUrduText(title);

    return Container(
      width: 180,
      margin: EdgeInsets.only(right: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to content detail based on publicId
          // For now, execute search with title
          ref.read(globalSearchProvider.notifier).executeSearch(query: title);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Poetry title - Hero element
              Expanded(
                child: LocalizedText(
                  title,
                  style: TextStyle(
                    fontSize: isUrdu ? 17 : 15,
                    fontFamily: isUrdu ? 'JameelNoori' : null,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                    height: isUrdu ? 1.8 : 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              SizedBox(height: AppSpacing.xs),

              // Poet name - Secondary element
              Row(
                children: [
                  Expanded(
                    child: Text(
                      poetName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ],
          ),
        ),
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
