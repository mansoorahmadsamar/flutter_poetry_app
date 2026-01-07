import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';

/// Recommendations discovery section
///
/// Features:
/// - 2-column grid layout
/// - Hybrid recommendations (personalized + trending)
/// - Urdu text prominent and large (18-20px Nastaliq)
/// - Poet name secondary and subtle
/// - Language badge (ur/en/hi)
/// - Soft shadows, rounded corners (18-22px radius)
/// - Literary aesthetic
class RecommendationsSection extends ConsumerWidget {
  const RecommendationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(globalSearchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

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
            child: Row(
              children: [
                Text(
                  'Recommended For You',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  '/ آپ کے لیے تجویز کردہ',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Jameel Noori Nastaleeq',
                    fontWeight: FontWeight.w500,
                    color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.6),
                    height: 1.8,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.md),

          // 2-column grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.85,
              ),
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
                  screenWidth,
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
    double screenWidth,
  ) {
    final isUrdu = _isUrduText(title);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(20),
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
                : Colors.black.withValues(alpha: 0.06),
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
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Poetry title - Hero element
              Expanded(
                child: Text(
                  title,
                  textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                  textAlign: isUrdu ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontSize: isUrdu ? 19 : 15,
                    fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
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
