import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/core/widgets/localized_text.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';

/// Recommendations discovery section
///
/// Features:
/// - Horizontal scrollable list
/// - Content cards with title and poet
/// - Tap to navigate/search
/// - Language-aware labels
/// - Paper aesthetic with minimal design
class RecommendationsSection extends ConsumerWidget {
  const RecommendationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(globalSearchProvider);
    final languageCode = ref.watch(selectedLanguageProvider);
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
            child: Row(
              children: [
                Icon(
                  Icons.recommend_outlined,
                  size: 18,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.black.withValues(alpha: 0.7),
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  _getLabel('Recommended For You', languageCode),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.black.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.sm),

          // Horizontal scrollable recommendations
          SizedBox(
            height: 120,
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
    String subtitle,
    String publicId,
    bool isDark,
  ) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to content detail based on publicId
          // For now, execute search with title
          ref.read(globalSearchProvider.notifier).executeSearch(query: title);
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              LocalizedText(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: AppSpacing.xs),

              // Subtitle (poet name)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : Colors.black.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // View button
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get localized label
  String _getLabel(String key, String languageCode) {
    final labels = {
      'ur': {
        'Recommended For You': 'آپ کے لیے تجویز کردہ',
      },
      'hi': {
        'Recommended For You': 'आपके लिए अनुशंसित',
      },
      'en': {
        'Recommended For You': 'Recommended For You',
      },
    };

    return labels[languageCode]?[key] ?? labels['en']![key]!;
  }
}
