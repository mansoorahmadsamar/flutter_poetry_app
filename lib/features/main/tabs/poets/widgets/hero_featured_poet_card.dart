import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import '../models/poet_model.dart';
import 'follow_button.dart';

/// Large hero card for the featured poet at the top of PoetsListScreen.
///
/// Layout:
///   - Full-width card with gradient overlay on the image
///   - Poet name, short bio, stats row (poems, views, followers)
///   - Trending/Featured badges
///   - Follow button
///   - Gradient placeholder with initial letter when no image
class HeroFeaturedPoetCard extends ConsumerWidget {
  final PoetModel poet;
  final VoidCallback onTap;

  const HeroFeaturedPoetCard({
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
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.4)
                  : AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image or gradient placeholder
              _buildBackground(isDark),

              // Gradient overlay for text readability
              _buildGradientOverlay(),

              // Content
              _buildContent(context, isDark, isUrdu),

              // Badges (top-right)
              _buildBadges(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    final hasImage =
        poet.profileImageUrl != null && poet.profileImageUrl!.isNotEmpty;

    if (hasImage) {
      return CachedNetworkImage(
        imageUrl: poet.profileImageUrl!,
        fit: BoxFit.cover,
        memCacheWidth: 800,
        maxWidthDiskCache: 800,
        placeholder: (_, __) => _buildGradientPlaceholder(isDark),
        errorWidget: (_, __, ___) => _buildGradientPlaceholder(isDark),
      );
    }

    return _buildGradientPlaceholder(isDark);
  }

  Widget _buildGradientPlaceholder(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1B4D3E),
                  const Color(0xFF0F2D24),
                  const Color(0xFF0A1F18),
                ]
              : [
                  const Color(0xFF2A6F5C),
                  const Color(0xFF1B4D3E),
                  const Color(0xFF12372A),
                ],
        ),
      ),
      child: Center(
        child: Text(
          poet.name.isNotEmpty ? poet.name[0].toUpperCase() : '?',
          style: GoogleFonts.roboto(
            fontSize: 72,
            fontWeight: FontWeight.w200,
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.4, 1.0],
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.85),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark, bool isUrdu) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poet name
          Text(
            poet.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: isUrdu
                ? AppTypography.urduPoetNameStyle.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  )
                : GoogleFonts.roboto(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
          ),
          const SizedBox(height: 4),

          // Short bio
          if (poet.shortBio.isNotEmpty)
            Text(
              poet.shortBio,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          const SizedBox(height: 12),

          // Stats row + Follow button
          Row(
            children: [
              // Stats
              _buildStatChip(
                Icons.edit_note,
                '${poet.poemCount} poems',
              ),
              const SizedBox(width: 12),
              if (poet.followerCount > 0) ...[
                _buildStatChip(
                  Icons.people_outline,
                  '${_formatCount(poet.followerCount)} followers',
                ),
                const SizedBox(width: 12),
              ],
              if (poet.countryFlag != null) ...[
                Text(
                  poet.countryFlag!,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 4),
                if (poet.country != null)
                  Text(
                    poet.country!,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
              ],

              const Spacer(),

              // Follow button
              FollowButton(
                publicId: poet.publicId,
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.white.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildBadges() {
    final badges = <Widget>[];

    if (poet.isTrending) {
      badges.add(_buildBadge('Trending', const Color(0xFFFF6B35)));
    }
    if (poet.isFeatured) {
      badges.add(_buildBadge('Featured', AppColors.secondary));
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 12,
      right: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: badges
            .map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: b,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.roboto(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
