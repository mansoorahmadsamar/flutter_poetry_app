import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/providers/search_providers.dart';

class SearchSuggestionsSection extends ConsumerWidget {
  const SearchSuggestionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestedPoets = ref.watch(suggestedPoetsProvider);
    final languageCode = ref.watch(selectedLanguageProvider);

    return suggestedPoets.when(
      data: (response) {
        if (response.content.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLocalizedTitle(languageCode),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: response.content.length,
                    itemBuilder: (context, index) {
                      final poet = response.content[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < response.content.length - 1
                              ? AppSpacing.md
                              : 0,
                        ),
                        child: _SuggestedPoetCard(
                          imageUrl: poet.profileImageUrl,
                          name: poet.name,
                          era: poet.era,
                          poemCount: poet.poemCount,
                          birthPlace: poet.birthPlace,
                          country: poet.country,
                          countryFlag: poet.countryFlag,
                          onTap: () {
                            context.push('/main/poets/${poet.publicId}');
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
        ),
      ),
      error: (error, stack) => const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      ),
    );
  }

  /// Get localized title for the section
  String _getLocalizedTitle(String languageCode) {
    switch (languageCode) {
      case 'ur':
        return 'تجویز کردہ شعراء';
      case 'hi':
        return 'सुझाए गए कवि';
      default:
        return 'Suggested Poets';
    }
  }
}

class _SuggestedPoetCard extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final String? era;
  final int poemCount;
  final String? birthPlace;
  final String? country;
  final String? countryFlag;
  final VoidCallback onTap;

  const _SuggestedPoetCard({
    this.imageUrl,
    required this.name,
    this.era,
    required this.poemCount,
    this.birthPlace,
    this.country,
    this.countryFlag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDark ? Colors.grey[850]! : Colors.grey[100]!,
              isDark ? Colors.grey[900]! : Colors.grey[50]!,
            ],
          ),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poet Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusMd),
              ),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 100,
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 100,
                        color: AppColors.primary,
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.secondary,
                        ),
                      ),
                    )
                  : Container(
                      height: 100,
                      color: AppColors.primary,
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.secondary,
                      ),
                    ),
            ),
            // Poet Info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    era ?? 'Unknown',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.secondary,
                          fontSize: 11,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Location with Country Flag
                  if (birthPlace != null || country != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (countryFlag != null)
                          Text(
                            countryFlag!,
                            style: const TextStyle(fontSize: 10),
                          ),
                        if (countryFlag != null &&
                            (birthPlace != null || country != null))
                          const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            birthPlace ?? country!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                          ),
                        ),
                      ],
                    ),
                  if (birthPlace != null || country != null)
                    const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.book,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$poemCount poems',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
