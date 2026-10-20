import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_typography.dart';

enum PortraitHue { gold, green }

/// Circular avatar with optional ring and an Urdu/Roman initial fallback.
/// If [imageUrl] is non-null, the network image takes priority.
class Portrait extends StatelessWidget {
  const Portrait({
    super.key,
    this.size = 56,
    this.initial = 'م',
    this.hue = PortraitHue.green,
    this.ring = false,
    this.imageUrl,
  });

  final double size;
  final String initial;
  final PortraitHue hue;
  final bool ring;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final isGold = hue == PortraitHue.gold;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isGold
          ? const [AppColors.secondaryDark, AppColors.secondary]
          : const [AppColors.primaryDark, AppColors.primary],
    );

    Widget content;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      content = ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _initialChild(gradient, isGold),
          errorWidget: (_, __, ___) => _initialChild(gradient, isGold),
        ),
      );
    } else {
      content = _initialChild(gradient, isGold);
    }

    if (!ring) return content;

    return Container(
      width: size + 4,
      height: size + 4,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isGold ? AppColors.secondary : AppColors.primary,
          width: 2,
        ),
      ),
      child: content,
    );
  }

  Widget _initialChild(Gradient gradient, bool isGold) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: gradient,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: AppTypography.urduFontFamily,
          fontSize: size * 0.42,
          color: isGold ? AppColors.backgroundLight : AppColors.secondaryLight,
          height: 1,
        ),
      ),
    );
  }
}
