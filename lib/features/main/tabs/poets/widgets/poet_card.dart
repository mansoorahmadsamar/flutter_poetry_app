import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/poet_model.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';

class PoetCard extends ConsumerWidget {
  final PoetModel poet;
  final VoidCallback onTap;

  const PoetCard({
    super.key,
    required this.poet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(selectedLanguageProvider);
    final isUrdu = lang == 'ur';

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: AppSpacing.elevationMd,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                isDark ? AppColors.surfaceDark.withValues(alpha: 0.8) : AppColors.surfaceLight,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poet Image
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusMd),
                ),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: poet.profileImageUrl ?? '',
                      fit: BoxFit.cover,
                      height: 150,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        height: 150,
                        color: isDark ? Colors.grey[800] : Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 150,
                        color: isDark ? Colors.grey[800] : Colors.grey[300],
                        child: Icon(
                          Icons.person_outline,
                          size: 60,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                      ),
                    ),
                    // Era Badge
                    Positioned(
                      top: AppSpacing.md,
                      right: AppSpacing.md,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: _getEraBadgeColor(poet.era),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text(
                          _getEraLabel(poet.era),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poet Name
                      Text(
                        poet.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: isUrdu
                            ? AppTypography.urduPoetNameStyle
                            : Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      // Bio
                      Text(
                        poet.shortBio,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: isUrdu
                            ? AppTypography.getUrduTextTheme(context).bodySmall?.copyWith(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              )
                            : TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                height: 1.4,
                              ),
                      ),
                      const Spacer(),
                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatItem(
                            icon: Icons.edit,
                            label: '${poet.poemCount}',
                            isDark: isDark,
                          ),
                          _StatItem(
                            icon: Icons.visibility,
                            label: _formatNumber(poet.viewCount),
                            isDark: isDark,
                          ),
                          if (poet.isTrending)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusSm),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.trending_up,
                                    size: 12,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    'Trending',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getEraBadgeColor(String era) {
    switch (era) {
      case 'CLASSICAL':
        return Colors.purple;
      case 'MODERN':
        return Colors.blue;
      case 'CONTEMPORARY':
        return Colors.green;
      case 'EMERGING':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getEraLabel(String era) {
    switch (era) {
      case 'CLASSICAL':
        return 'Classical';
      case 'MODERN':
        return 'Modern';
      case 'CONTEMPORARY':
        return 'Contemporary';
      case 'EMERGING':
        return 'Emerging';
      default:
        return era;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _StatItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 12,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
