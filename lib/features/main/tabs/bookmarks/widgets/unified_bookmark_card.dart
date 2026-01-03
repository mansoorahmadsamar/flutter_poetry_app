import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/utils/language_typography.dart';
import 'package:flutter_poetry_app/features/main/tabs/bookmarks/models/unified_bookmark_model.dart';

/// Unified bookmark card with three variants: POEM, COUPLET, IMAGE
/// Polished for production: clean, paper-like, poetry-first aesthetic
class UnifiedBookmarkCard extends StatelessWidget {
  final UnifiedBookmark bookmark;
  final VoidCallback onTap;
  final bool isDark;

  const UnifiedBookmarkCard({
    super.key,
    required this.bookmark,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    switch (bookmark.type.toUpperCase()) {
      case 'POEM':
        return _PoemBookmarkCard(
          bookmark: bookmark,
          onTap: onTap,
          isDark: isDark,
        );
      case 'COUPLET':
        return _CoupletBookmarkCard(
          bookmark: bookmark,
          onTap: onTap,
          isDark: isDark,
        );
      case 'IMAGE':
        return _ImageBookmarkCard(
          bookmark: bookmark,
          onTap: onTap,
          isDark: isDark,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Poem bookmark card - Clean, minimal, poetry-first
class _PoemBookmarkCard extends StatelessWidget {
  final UnifiedBookmark bookmark;
  final VoidCallback onTap;
  final bool isDark;

  const _PoemBookmarkCard({
    required this.bookmark,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final langCode = bookmark.languageCode;
    final isUrdu = langCode == 'ur';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6, // Reduced from ~12 (AppSpacing.sm)
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12, // Reduced 20-25% from original
        ),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1A1A1A) // Slightly lighter, less contrast
              : const Color(0xFFFFFBF7), // Warm paper tone
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04) // Subtler
                : Colors.black.withValues(alpha: 0.03),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.15) // Much softer
                  : Colors.black.withValues(alpha: 0.025),
              blurRadius: 4, // Reduced from 8
              offset: const Offset(0, 1), // Minimal lift
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metadata chips - Minimal, low-contrast
            Row(
              children: [
                _MetadataChip(
                  label: 'Poem',
                  isDark: isDark,
                  color: AppColors.secondary.withValues(alpha: 0.1),
                ),
                const SizedBox(width: 6),
                _MetadataChip(
                  label: langCode.toUpperCase(),
                  isDark: isDark,
                  color: Colors.transparent,
                ),
                const Spacer(),
                Icon(
                  Icons.bookmark_rounded,
                  size: 13,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.15),
                ),
              ],
            ),

            const SizedBox(height: 10), // Tighter spacing

            // Title - Primary focus
            Directionality(
              textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
              child: Text(
                bookmark.poemTitle ?? '',
                style: GoogleFonts.notoNastaliqUrdu(
                  fontSize: isUrdu ? 17.5 : 16,
                  fontWeight: isUrdu ? FontWeight.w600 : FontWeight.w600,
                  height: isUrdu ? 1.58 : 1.4, // Compact vertical rhythm
                  letterSpacing: isUrdu ? -0.3 : 0,
                  color: isDark
                      ? const Color(0xFFE8E6E3)
                      : const Color(0xFF1A1A1A),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: isUrdu ? TextAlign.right : TextAlign.left,
              ),
            ),

            const SizedBox(height: 8),

            // Divider - Subtle separation
            Container(
              height: 0.5,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
            ),

            const SizedBox(height: 7),

            // Poet name - Low contrast, secondary
            Text(
              bookmark.poetName ?? 'Unknown',
              style: GoogleFonts.roboto(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                height: 1.3,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.35)
                    : Colors.black.withValues(alpha: 0.38),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Couplet bookmark card - Optimized for Urdu verse reading
class _CoupletBookmarkCard extends StatelessWidget {
  final UnifiedBookmark bookmark;
  final VoidCallback onTap;
  final bool isDark;

  const _CoupletBookmarkCard({
    required this.bookmark,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final langCode = bookmark.languageCode;
    final isUrdu = langCode == 'ur';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1A1A1A)
              : const Color(0xFFFFFBF7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : AppColors.primary.withValues(alpha: 0.06), // Hint of color for couplets
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.025),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Metadata chips
            Row(
              children: [
                _MetadataChip(
                  label: 'Couplet',
                  isDark: isDark,
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
                const SizedBox(width: 6),
                _MetadataChip(
                  label: langCode.toUpperCase(),
                  isDark: isDark,
                  color: Colors.transparent,
                ),
                const Spacer(),
                Icon(
                  Icons.bookmark_rounded,
                  size: 13,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.15),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Verse 1 - Primary content
            if (bookmark.coupletVerse1 != null)
              Directionality(
                textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                child: Text(
                  bookmark.coupletVerse1!,
                  style: GoogleFonts.notoNastaliqUrdu(
                    fontSize: isUrdu ? 16.5 : 15,
                    fontWeight: FontWeight.w500,
                    height: isUrdu ? 1.6 : 1.45, // Optimized line height
                    letterSpacing: isUrdu ? -0.25 : 0,
                    color: isDark
                        ? const Color(0xFFE8E6E3)
                        : const Color(0xFF1A1A1A),
                  ),
                  textAlign: isUrdu ? TextAlign.right : TextAlign.center,
                ),
              ),

            const SizedBox(height: 7), // Tight verse spacing

            // Verse 2
            if (bookmark.coupletVerse2 != null)
              Directionality(
                textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                child: Text(
                  bookmark.coupletVerse2!,
                  style: GoogleFonts.notoNastaliqUrdu(
                    fontSize: isUrdu ? 16.5 : 15,
                    fontWeight: FontWeight.w500,
                    height: isUrdu ? 1.6 : 1.45,
                    letterSpacing: isUrdu ? -0.25 : 0,
                    color: isDark
                        ? const Color(0xFFE8E6E3)
                        : const Color(0xFF1A1A1A),
                  ),
                  textAlign: isUrdu ? TextAlign.right : TextAlign.center,
                ),
              ),

            const SizedBox(height: 10),

            // Divider
            Container(
              height: 0.5,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
            ),

            const SizedBox(height: 8),

            // Metadata - Low contrast
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (bookmark.poetName != null)
                        Text(
                          bookmark.poetName!,
                          style: GoogleFonts.roboto(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.35)
                                : Colors.black.withValues(alpha: 0.38),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (bookmark.coupletPoemTitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          bookmark.coupletPoemTitle!,
                          style: GoogleFonts.roboto(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.25)
                                : Colors.black.withValues(alpha: 0.28),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Image bookmark card
class _ImageBookmarkCard extends StatelessWidget {
  final UnifiedBookmark bookmark;
  final VoidCallback onTap;
  final bool isDark;

  const _ImageBookmarkCard({
    required this.bookmark,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFBF7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.03),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.025),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image thumbnail
            if (bookmark.thumbnailUrl != null || bookmark.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: bookmark.thumbnailUrl ?? bookmark.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.black.withValues(alpha: 0.02),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.black.withValues(alpha: 0.02),
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metadata row
                  Row(
                    children: [
                      _MetadataChip(
                        label: 'Image',
                        isDark: isDark,
                        color: const Color(0xFF4A7C8E).withValues(alpha: 0.08),
                      ),
                      const SizedBox(width: 6),
                      _MetadataChip(
                        label: bookmark.languageCode.toUpperCase(),
                        isDark: isDark,
                        color: Colors.transparent,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.bookmark_rounded,
                        size: 13,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.15),
                      ),
                    ],
                  ),

                  if (bookmark.templateName != null &&
                      bookmark.templateName!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      bookmark.templateName!,
                      style: GoogleFonts.roboto(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.35)
                            : Colors.black.withValues(alpha: 0.38),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Minimal metadata chip - Subtle, non-decorative
class _MetadataChip extends StatelessWidget {
  final String label;
  final bool isDark;
  final Color color;

  const _MetadataChip({
    required this.label,
    required this.isDark,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: color == Colors.transparent
            ? Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
                width: 0.5,
              )
            : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.roboto(
          fontSize: 9.5,
          fontWeight: FontWeight.w500,
          height: 1.2,
          letterSpacing: 0.3,
          color: isDark
              ? Colors.white.withValues(alpha: 0.4)
              : Colors.black.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

/// Format count (K, M notation)
String _formatCount(int count) {
  if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1)}M';
  } else if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}K';
  }
  return count.toString();
}
