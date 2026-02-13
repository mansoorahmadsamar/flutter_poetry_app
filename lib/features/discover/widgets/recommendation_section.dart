import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/design_system/app_colors.dart';
import '../models/discover_bundle_model.dart';

/// Section for displaying content recommendations (Editor's Picks, Recommended, etc.)
/// Compact cards with poet avatar and Jameel Noori Nastaleeq font for Urdu
class RecommendationSection extends StatelessWidget {
  final String title;
  final List<ContentCard> items;
  final bool isRtl;
  final Function(BuildContext, ContentCard) onItemTap;
  final VoidCallback? onSeeAll;

  const RecommendationSection({
    super.key,
    required this.title,
    required this.items,
    required this.isRtl,
    required this.onItemTap,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Urdu title support
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isRtl ? 18 : 16,
                  fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
                  fontWeight: FontWeight.w600,
                  height: isRtl ? 1.8 : 1.4,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              if (onSeeAll != null && items.length > 5)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isRtl ? 'سب دیکھیں' : 'See All',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: isRtl ? 14 : 13,
                          fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
                          height: isRtl ? 1.6 : 1.4,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isRtl ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                        size: 12,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Content cards - compact horizontal scroll
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.take(10).length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return _ContentCardWidget(
                  card: item,
                  isRtl: isRtl,
                  onTap: () => onItemTap(context, item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentCardWidget extends StatelessWidget {
  final ContentCard card;
  final bool isRtl;
  final VoidCallback onTap;

  const _ContentCardWidget({
    required this.card,
    required this.isRtl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPoetInfo = card.secondaryText != null && card.secondaryText!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? AppColors.borderDark
                  : AppColors.primary.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Badge
              if (card.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getTypeColor(card.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    card.badge!,
                    style: TextStyle(
                      fontSize: isRtl ? 11 : 9,
                      fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
                      fontWeight: FontWeight.w600,
                      color: _getTypeColor(card.type),
                      height: isRtl ? 1.4 : 1.2,
                    ),
                  ),
                ),

              const SizedBox(height: 6),

              // Primary text (poem title/verse) - Urdu in Jameel Noori
              Expanded(
                child: Text(
                  card.primaryText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection: card.isRtl ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(
                    fontSize: isRtl ? 15 : 13,
                    fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
                    fontWeight: FontWeight.w500,
                    height: isRtl ? 1.6 : 1.3,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),

              // Bottom row: Poet info with avatar
              if (hasPoetInfo) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Poet avatar
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: ClipOval(
                        child: card.imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: card.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => _buildAvatarPlaceholder(),
                                errorWidget: (_, __, ___) => _buildAvatarPlaceholder(),
                              )
                            : _buildAvatarPlaceholder(),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Poet name - Jameel Noori for Urdu
                    Expanded(
                      child: Text(
                        card.secondaryText!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isRtl ? 12 : 11,
                          fontFamily: _isUrduText(card.secondaryText!)
                              ? 'Jameel Noori Nastaleeq'
                              : null,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondary,
                          height: isRtl ? 1.5 : 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Metrics row (compact)
              if (card.metrics != null &&
                  (card.metrics!.likeCount > 0 || card.metrics!.viewCount > 0)) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (card.metrics!.likeCount > 0) ...[
                      Icon(
                        Icons.favorite,
                        size: 10,
                        color: AppColors.error.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _formatCount(card.metrics!.likeCount),
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                    if (card.metrics!.likeCount > 0 && card.metrics!.viewCount > 0)
                      const SizedBox(width: 8),
                    if (card.metrics!.viewCount > 0) ...[
                      Icon(
                        Icons.visibility,
                        size: 10,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _formatCount(card.metrics!.viewCount),
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.person,
          size: 12,
          color: AppColors.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  bool _isUrduText(String text) {
    final urduPattern = RegExp(r'[\u0600-\u06FF]');
    return urduPattern.hasMatch(text);
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'POET':
        return AppColors.primary;
      case 'POEM':
        return AppColors.secondary;
      case 'VERSE':
      case 'COUPLET':
        return AppColors.urduTextAccent;
      case 'CATEGORY':
        return AppColors.info;
      case 'TAG':
        return AppColors.warning;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
