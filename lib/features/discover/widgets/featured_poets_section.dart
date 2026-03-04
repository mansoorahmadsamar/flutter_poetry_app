import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/design_system/app_colors.dart';
import '../models/discover_bundle_model.dart';

/// Horizontal scrolling section for featured poets
/// Compact cards with Jameel Noori Nastaleeq font for Urdu names
class FeaturedPoetsSection extends StatelessWidget {
  final List<ContentCard> poets;
  final bool isRtl;
  final Function(ContentCard) onPoetTap;
  final VoidCallback? onSeeAll;

  const FeaturedPoetsSection({
    super.key,
    required this.poets,
    required this.isRtl,
    required this.onPoetTap,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (poets.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Urdu support
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.stars_outlined,
                    size: 20,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRtl ? 'نمایاں شعراء' : 'Featured Poets',
                    style: TextStyle(
                      fontSize: isRtl ? 18 : 16,
                      fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
                      fontWeight: FontWeight.w600,
                      height: isRtl ? 1.8 : 1.4,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              if (onSeeAll != null && poets.length > 5)
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
          // Poets horizontal scroll - compact
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: poets.take(10).length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final poet = poets[index];
                return _PoetCard(
                  poet: poet,
                  isRtl: isRtl,
                  onTap: () => onPoetTap(poet),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PoetCard extends StatelessWidget {
  final ContentCard poet;
  final bool isRtl;
  final VoidCallback onTap;

  const _PoetCard({
    required this.poet,
    required this.isRtl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUrduName = _isUrduText(poet.primaryText);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 90,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar - compact
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondary,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: poet.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: poet.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              _buildInitialsPlaceholder(poet.primaryText, isDark),
                          errorWidget: (context, url, error) =>
                              _buildInitialsPlaceholder(poet.primaryText, isDark),
                        )
                      : _buildInitialsPlaceholder(poet.primaryText, isDark),
                ),
              ),
              const SizedBox(height: 8),
              // Name - Jameel Noori Nastaleeq for Urdu
              Text(
                poet.primaryText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                textDirection: isUrduName ? TextDirection.rtl : TextDirection.ltr,
                style: TextStyle(
                  fontSize: isUrduName ? 14 : 12,
                  fontFamily: isUrduName ? 'Jameel Noori Nastaleeq' : null,
                  fontWeight: FontWeight.w600,
                  height: isUrduName ? 1.6 : 1.3,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsPlaceholder(String name, bool isDark) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          _getInitials(name),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  bool _isUrduText(String text) {
    final urduPattern = RegExp(r'[\u0600-\u06FF]');
    return urduPattern.hasMatch(text);
  }
}
