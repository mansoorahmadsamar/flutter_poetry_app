import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/poet_model.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
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
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image with Badges Overlay
            Stack(
              children: [
                _buildProfileImage(isDark),
                // Badges positioned on top-right of image
                if (poet.isTrending || poet.isFeatured)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildBadgesHeader(),
                  ),
              ],
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Era Badge
                    if (poet.era != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getEraBadgeColor(poet.era),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getEraLabel(poet.era!),
                          style: GoogleFonts.roboto(
                            fontSize: 7,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),

                    // Poet Name
                    Text(
                      poet.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: isUrdu
                          ? AppTypography.urduPoetNameStyle.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              height: 1.7,
                              color: isDark ? Colors.white : Colors.black87,
                            )
                          : GoogleFonts.roboto(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                    ),
                    const SizedBox(height: 4),

                    // Life Dates
                    if (_buildLifeDates(isDark) != null) ...[
                      _buildLifeDates(isDark)!,
                      const SizedBox(height: 4),
                    ],

                    // Location with Country Flag
                    if (_buildLocationRow(isDark, isUrdu) != null) ...[
                      _buildLocationRow(isDark, isUrdu)!,
                      const SizedBox(height: 4),
                    ],

                    const Spacer(),

                    // Stats Row
                    Row(
                      children: [
                        // Poem Count
                        Icon(
                          Icons.auto_stories_outlined,
                          size: 9,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.6)
                              : Colors.black.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            '${poet.poemCount}',
                            style: GoogleFonts.roboto(
                              fontSize: 8,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : Colors.black.withValues(alpha: 0.5),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        // View Count
                        if (poet.viewCount > 0) ...[
                          Icon(
                            Icons.visibility_outlined,
                            size: 9,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : Colors.black.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              _formatNumber(poet.viewCount),
                              style: GoogleFonts.roboto(
                                fontSize: 8,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : Colors.black.withValues(alpha: 0.5),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesHeader() {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (poet.isTrending)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.4),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    size: 8,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Hot',
                    style: GoogleFonts.roboto(
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          if (poet.isTrending && poet.isFeatured)
            const SizedBox(width: 4),
          if (poet.isFeatured)
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.amber.shade400,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.5),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.star_rounded,
                size: 9,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(bool isDark) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(16),
      ),
      child: poet.profileImageUrl != null && poet.profileImageUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: poet.profileImageUrl!,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              maxHeightDiskCache: 400,
              maxWidthDiskCache: 400,
              placeholder: (context, url) => Container(
                height: 120,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.secondary,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) {
                return Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.3),
                        AppColors.primary.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person_outline,
                      size: 60,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                );
              },
            )
          : Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.primary.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.person_outline,
                  size: 60,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
            ),
    );
  }

  Widget? _buildLifeDates(bool isDark) {
    if (poet.birthYear == 0) return null;

    String lifeDates;
    if (poet.deathYear != null && poet.deathYear! > 0) {
      lifeDates = '${poet.birthYear} - ${poet.deathYear}';
    } else {
      lifeDates = 'b. ${poet.birthYear}';
    }

    return Text(
      lifeDates,
      style: GoogleFonts.roboto(
        fontSize: 8,
        fontWeight: FontWeight.w400,
        color: isDark
            ? Colors.white.withValues(alpha: 0.6)
            : Colors.black.withValues(alpha: 0.5),
        letterSpacing: 0.2,
      ),
    );
  }

  Widget? _buildLocationRow(bool isDark, bool isUrdu) {
    if (poet.birthPlace == null && poet.country == null) return null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Country Flag
        if (poet.countryFlag != null)
          Text(
            poet.countryFlag!,
            style: const TextStyle(fontSize: 10),
          ),
        if (poet.countryFlag != null &&
            (poet.birthPlace != null || poet.country != null))
          const SizedBox(width: 4),

        // Birth Place or Country
        Flexible(
          child: Text(
            poet.birthPlace ?? poet.country!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
            style: isUrdu
                ? AppTypography.urduPoetNameStyle.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.black.withValues(alpha: 0.5),
                  )
                : GoogleFonts.roboto(
                    fontSize: 8,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.black.withValues(alpha: 0.5),
                    letterSpacing: 0.2,
                  ),
          ),
        ),
      ],
    );
  }

  Color _getEraBadgeColor(String? era) {
    switch (era) {
      case 'CLASSICAL':
        return const Color(0xFF8B5CF6); // Purple
      case 'MODERN':
        return const Color(0xFF3B82F6); // Blue
      case 'CONTEMPORARY':
        return const Color(0xFF10B981); // Green
      case 'EMERGING':
        return const Color(0xFF14B8A6); // Teal
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String _getEraLabel(String era) {
    switch (era) {
      case 'CLASSICAL':
        return 'CLASSICAL';
      case 'MODERN':
        return 'MODERN';
      case 'CONTEMPORARY':
        return 'CONTEMPORARY';
      case 'EMERGING':
        return 'EMERGING';
      default:
        return era.toUpperCase();
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
