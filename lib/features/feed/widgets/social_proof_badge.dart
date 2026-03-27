import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import '../models/social_context.dart';

/// Renders social proof indicators from a [SocialContext].
/// Returns nothing when [socialContext] is null — never allocates widgets
/// for items without social data.
class SocialProofBadge extends StatelessWidget {
  final SocialContext? socialContext;

  const SocialProofBadge({super.key, this.socialContext});

  @override
  Widget build(BuildContext context) {
    if (socialContext == null) return const SizedBox.shrink();
    final sc = socialContext!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasTrending = sc.trendingLabel != null;
    final hasVelocity = sc.velocityLabel != null;
    if (!hasTrending && !hasVelocity) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasTrending) _buildTrendingChip(sc.trendingLabel!, isDark),
          if (hasTrending && hasVelocity) const SizedBox(height: 4),
          if (hasVelocity) _buildVelocityLabel(sc.velocityLabel!, isDark),
        ],
      ),
    );
  }

  Widget _buildTrendingChip(String label, bool isDark) {
    final (Color bg, Color fg) = _trendingColors(label, isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_trendingIcon(label), size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVelocityLabel(String label, bool isDark) {
    final lowerLabel = label.toLowerCase();
    final IconData icon;
    if (lowerLabel.contains('trending')) {
      icon = Icons.local_fire_department;
    } else if (lowerLabel.contains('shared')) {
      icon = Icons.share;
    } else {
      icon = Icons.trending_up;
    }

    final color = isDark
        ? const Color(0xFFFFB74D) // amber 300
        : const Color(0xFFE65100); // deep orange 900

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  (Color, Color) _trendingColors(String label, bool isDark) {
    final lower = label.toLowerCase();
    if (lower.contains('popular')) {
      return isDark
          ? (const Color(0x33FFB300), const Color(0xFFFFD54F))
          : (const Color(0x1AFFB300), const Color(0xFFE65100));
    }
    if (lower.contains('rising')) {
      return isDark
          ? (const Color(0x3343A047), const Color(0xFF81C784))
          : (const Color(0x1A43A047), const Color(0xFF2E7D32));
    }
    if (lower.contains('followed')) {
      return isDark
          ? (const Color(0x331E88E5), const Color(0xFF64B5F6))
          : (const Color(0x1A1E88E5), const Color(0xFF1565C0));
    }
    // Default: primary green
    return isDark
        ? (AppColors.primary.withValues(alpha: 0.2),
            AppColors.primaryLight)
        : (AppColors.primary.withValues(alpha: 0.1), AppColors.primary);
  }

  IconData _trendingIcon(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('popular')) return Icons.whatshot;
    if (lower.contains('rising')) return Icons.trending_up;
    if (lower.contains('followed')) return Icons.people_outline;
    return Icons.auto_awesome;
  }
}

/// Renders social proof for cards with a dark/gradient background
/// (e.g., PoetSpotlightFeedCard) using light-on-dark colors.
class SocialProofBadgeDark extends StatelessWidget {
  final SocialContext? socialContext;

  const SocialProofBadgeDark({super.key, this.socialContext});

  @override
  Widget build(BuildContext context) {
    if (socialContext == null) return const SizedBox.shrink();
    final sc = socialContext!;

    final hasTrending = sc.trendingLabel != null;
    final hasVelocity = sc.velocityLabel != null;
    if (!hasTrending && !hasVelocity) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasTrending)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusRound),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.9)),
                  const SizedBox(width: 4),
                  Text(
                    sc.trendingLabel!,
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          if (hasTrending && hasVelocity) const SizedBox(height: 4),
          if (hasVelocity)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_fire_department,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.7)),
                const SizedBox(width: 4),
                Text(
                  sc.velocityLabel!,
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
