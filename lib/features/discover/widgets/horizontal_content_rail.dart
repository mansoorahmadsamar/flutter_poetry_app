import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/design_system/app_colors.dart';
import '../models/discover_bundle_model.dart';
import 'section_header.dart';

/// Horizontal scrolling rail for content cards (Editor's Picks, Recommended).
/// Premium card design with rich data display, pill badges, and tap feedback.
class HorizontalContentRail extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final List<ContentCard> items;
  final int totalCount;
  final bool isRtl;
  final Function(BuildContext, ContentCard) onItemTap;
  final VoidCallback? onSeeMore;
  final Widget? emptyStateWidget;

  const HorizontalContentRail({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    required this.items,
    this.totalCount = 0,
    required this.isRtl,
    required this.onItemTap,
    this.onSeeMore,
    this.emptyStateWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Expanded(
              child: SectionHeader(
                title: title,
                icon: icon,
                iconColor: iconColor,
                isRtl: isRtl,
                itemCount: items.length,
                totalCount: totalCount,
                onSeeMore: onSeeMore,
              ),
            ),
          ],
        ),
        // Content
        if (items.isEmpty && emptyStateWidget != null)
          emptyStateWidget!
        else if (items.isNotEmpty)
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _ContentCardView(
                  card: items[index],
                  isRtl: isRtl,
                  onTap: () => onItemTap(context, items[index]),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Premium content card with scale-on-tap, pill badge, and elevated shadow.
class _ContentCardView extends StatefulWidget {
  final ContentCard card;
  final bool isRtl;
  final VoidCallback onTap;

  const _ContentCardView({
    required this.card,
    required this.isRtl,
    required this.onTap,
  });

  @override
  State<_ContentCardView> createState() => _ContentCardViewState();
}

class _ContentCardViewState extends State<_ContentCardView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  bool _isUrduText(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  bool _hasValidUrl(String? url) {
    return url != null && url.isNotEmpty && url != '-';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = widget.card;
    final isCardRtl = card.direction == 'rtl';
    final hasBadge =
        card.badge != null && card.badge!.isNotEmpty && card.badge != '-';
    final hasSecondary = card.secondaryText != null &&
        card.secondaryText!.isNotEmpty &&
        card.secondaryText != '-';
    final hasImage = _hasValidUrl(card.imageUrl);
    final typeColor = _getTypeColor(card.type);
    final isUrduPrimary = _isUrduText(card.primaryText);

    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.forward(),
      onTapUp: (_) {
        _scaleCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Directionality(
          textDirection: isCardRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
            width: 190,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.borderDark
                    : typeColor.withValues(alpha: 0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : typeColor.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: pill badge + accent bar
                Row(
                  children: [
                    if (hasBadge)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            card.badge!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize:
                                  _isUrduText(card.badge!) ? 11 : 10,
                              fontFamily: _isUrduText(card.badge!)
                                  ? 'Jameel Noori Nastaleeq'
                                  : null,
                              fontWeight: FontWeight.w700,
                              color: typeColor,
                              height:
                                  _isUrduText(card.badge!) ? 1.4 : 1.2,
                              letterSpacing:
                                  _isUrduText(card.badge!) ? 0 : 0.3,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getTypeLabel(card.type),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: typeColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Container(
                      width: 24,
                      height: 3,
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Primary text — expanded to fill
                Expanded(
                  child: Text(
                    card.primaryText,
                    maxLines: isUrduPrimary ? 3 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily:
                          isUrduPrimary ? 'Jameel Noori Nastaleeq' : null,
                      fontSize: isUrduPrimary ? 20 : 14,
                      fontWeight: FontWeight.w500,
                      height: isUrduPrimary ? 1.6 : 1.4,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                // Divider
                const SizedBox(height: 4),
                Container(
                  height: 1,
                  color: isDark
                      ? AppColors.borderDark
                      : typeColor.withValues(alpha: 0.08),
                ),
                const SizedBox(height: 6),
                // Bottom: author/poet + smart metrics
                _buildBottomRow(isDark, hasSecondary, hasImage, typeColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomRow(
      bool isDark, bool hasSecondary, bool hasImage, Color typeColor) {
    final card = widget.card;
    final m = card.metrics;
    final likes = m?.likeCount ?? 0;
    final views = m?.viewCount ?? 0;
    final hasLikes = likes > 0;
    final hasViews = views > 0;
    final metricColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    if (hasSecondary) {
      return Row(
        children: [
          // Poet avatar
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.08),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: ClipOval(
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: card.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 14,
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.person_rounded,
                        size: 14,
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 6),
          // Author name
          Expanded(
            child: Text(
              card.secondaryText!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: _isUrduText(card.secondaryText!)
                    ? 'Jameel Noori Nastaleeq'
                    : null,
                fontSize: _isUrduText(card.secondaryText!) ? 14 : 12,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
                height: _isUrduText(card.secondaryText!) ? 1.5 : 1.3,
              ),
            ),
          ),
          // Smart metrics
          if (hasLikes) ...[
            const SizedBox(width: 4),
            Icon(Icons.favorite_rounded, size: 12, color: metricColor),
            const SizedBox(width: 2),
            Text(
              _formatCount(likes),
              style: TextStyle(fontSize: 10, color: metricColor),
            ),
          ] else if (hasViews) ...[
            const SizedBox(width: 4),
            Icon(Icons.visibility_rounded, size: 12, color: metricColor),
            const SizedBox(width: 2),
            Text(
              _formatCount(views),
              style: TextStyle(fontSize: 10, color: metricColor),
            ),
          ],
        ],
      );
    }

    // No secondary text — show type icon + label + metrics
    return Row(
      children: [
        Icon(
          _getTypeIcon(card.type),
          size: 14,
          color: typeColor.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 4),
        Text(
          _getTypeLabel(card.type),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: typeColor.withValues(alpha: 0.7),
          ),
        ),
        if (hasLikes) ...[
          const Spacer(),
          Icon(Icons.favorite_rounded, size: 12, color: metricColor),
          const SizedBox(width: 2),
          Text(
            _formatCount(likes),
            style: TextStyle(fontSize: 10, color: metricColor),
          ),
        ] else if (hasViews) ...[
          const Spacer(),
          Icon(Icons.visibility_rounded, size: 12, color: metricColor),
          const SizedBox(width: 2),
          Text(
            _formatCount(views),
            style: TextStyle(fontSize: 10, color: metricColor),
          ),
        ],
      ],
    );
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

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'POET':
        return Icons.person_rounded;
      case 'POEM':
        return Icons.auto_stories_rounded;
      case 'VERSE':
      case 'COUPLET':
        return Icons.format_quote_rounded;
      case 'CATEGORY':
        return Icons.category_rounded;
      case 'TAG':
        return Icons.label_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'POET':
        return 'POET';
      case 'POEM':
        return 'POEM';
      case 'VERSE':
        return 'VERSE';
      case 'COUPLET':
        return 'COUPLET';
      case 'CATEGORY':
        return 'CATEGORY';
      case 'TAG':
        return 'TAG';
      default:
        return type;
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
