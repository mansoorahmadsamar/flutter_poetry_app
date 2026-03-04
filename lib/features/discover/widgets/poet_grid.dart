import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/design_system/app_colors.dart';
import '../models/discover_bundle_model.dart';
import 'section_header.dart';

/// Featured poets grid with gradient avatars, soft elevation,
/// 2 columns on phone, 3 on tablet.
class PoetGrid extends StatelessWidget {
  final List<ContentCard> poets;
  final int totalCount;
  final bool isRtl;
  final Function(ContentCard) onPoetTap;
  final VoidCallback? onSeeMore;

  const PoetGrid({
    super.key,
    required this.poets,
    this.totalCount = 0,
    required this.isRtl,
    required this.onPoetTap,
    this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    if (poets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: isRtl ? 'نمایاں شعراء' : 'Featured Poets',
          icon: Icons.stars_rounded,
          iconColor: AppColors.secondary,
          isRtl: isRtl,
          itemCount: poets.length,
          totalCount: totalCount,
          onSeeMore: onSeeMore,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 2.6,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: poets.length,
                itemBuilder: (context, index) {
                  return _PoetTile(
                    poet: poets[index],
                    isRtl: isRtl,
                    gradientIndex: index,
                    onTap: () => onPoetTap(poets[index]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Gradient presets for poet avatar backgrounds
const _avatarGradients = [
  [Color(0xFF1B4D3E), Color(0xFF2A6F5C)],
  [Color(0xFFC5A059), Color(0xFFD4B374)],
  [Color(0xFF4A7C8E), Color(0xFF6A9CB0)],
  [Color(0xFF2D7A5A), Color(0xFF45A07A)],
  [Color(0xFFC84B31), Color(0xFFE06B50)],
  [Color(0xFFD4A259), Color(0xFFE8BC78)],
];

class _PoetTile extends StatefulWidget {
  final ContentCard poet;
  final bool isRtl;
  final int gradientIndex;
  final VoidCallback onTap;

  const _PoetTile({
    required this.poet,
    required this.isRtl,
    required this.gradientIndex,
    required this.onTap,
  });

  @override
  State<_PoetTile> createState() => _PoetTileState();
}

class _PoetTileState extends State<_PoetTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  bool _isUrduText(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  String _getInitials(String name) {
    if (_isUrduText(name)) {
      return name.trim().isNotEmpty ? name.trim()[0] : '';
    }
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUrdu = _isUrduText(widget.poet.primaryText);
    final gradientColors =
        _avatarGradients[widget.gradientIndex % _avatarGradients.length];

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(scale: _scale.value, child: child);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Gradient avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.poet.imageUrl != null
                        ? [
                            AppColors.primary.withValues(alpha: 0.06),
                            AppColors.primary.withValues(alpha: 0.06),
                          ]
                        : gradientColors,
                  ),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: widget.poet.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: widget.poet.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              _buildInitials(gradientColors),
                        )
                      : _buildInitials(gradientColors),
                ),
              ),
              const SizedBox(width: 10),
              // Name
              Expanded(
                child: Text(
                  widget.poet.primaryText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection:
                      isUrdu ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(
                    fontFamily:
                        isUrdu ? 'Jameel Noori Nastaleeq' : null,
                    fontSize: isUrdu ? 14 : 13,
                    fontWeight: FontWeight.w600,
                    height: isUrdu ? 1.6 : 1.3,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textDisabledLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitials(List<Color> gradientColors) {
    final initials = _getInitials(widget.poet.primaryText);
    final isUrdu = _isUrduText(initials);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
            fontSize: isUrdu ? 18 : 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: isUrdu ? 1.5 : 1.2,
          ),
        ),
      ),
    );
  }
}
