import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';

class BookmarkPoemCard extends ConsumerWidget {
  final PoemModel poem;
  final VoidCallback onTap;
  final bool isHorizontal;

  const BookmarkPoemCard({
    super.key,
    required this.poem,
    required this.onTap,
    this.isHorizontal = false,
  });

  // Helper to detect if text contains Urdu/Arabic characters
  bool _isUrduText(String? text) {
    if (text == null || text.isEmpty) return false;
    // Check if text contains Arabic/Urdu Unicode range
    final urduRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');
    return urduRegex.hasMatch(text);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Detect if the poem content is in Urdu based on the text itself
    final isTitleUrdu = _isUrduText(poem.title);
    final isExcerptUrdu = _isUrduText(poem.excerpt);
    final isPoetNameUrdu = _isUrduText(poem.poetName);

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
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bookmark Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bookmark,
                          size: 10,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Saved',
                          style: GoogleFonts.roboto(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Poetry Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getPoetryTypeColor(poem.poetryType),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getPoetryTypeLabel(poem.poetryType),
                      style: GoogleFonts.roboto(
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Title or Excerpt
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (poem.title != null && poem.title!.isNotEmpty) ...[
                          Text(
                            poem.title!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: isTitleUrdu ? TextDirection.rtl : TextDirection.ltr,
                            style: isTitleUrdu
                                ? AppTypography.urduPoetNameStyle.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    height: 1.8,
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
                        ],

                        // Excerpt
                        if (poem.excerpt != null && poem.excerpt!.isNotEmpty)
                          Expanded(
                            child: Text(
                              poem.excerpt!,
                              maxLines: isHorizontal ? 3 : 4,
                              overflow: TextOverflow.ellipsis,
                              textDirection: isExcerptUrdu ? TextDirection.rtl : TextDirection.ltr,
                              style: isExcerptUrdu
                                  ? AppTypography.urduPoetNameStyle.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      height: 2.0,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : Colors.black.withValues(alpha: 0.6),
                                    )
                                  : GoogleFonts.roboto(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w400,
                                      height: 1.4,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : Colors.black.withValues(alpha: 0.6),
                                    ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Poet Name
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 10,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.black.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          poem.poetName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textDirection: isPoetNameUrdu ? TextDirection.rtl : TextDirection.ltr,
                          style: isPoetNameUrdu
                              ? AppTypography.urduPoetNameStyle.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  height: 1.8,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.6)
                                      : Colors.black.withValues(alpha: 0.5),
                                )
                              : GoogleFonts.roboto(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.6)
                                      : Colors.black.withValues(alpha: 0.5),
                                ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Stats Row
                  Row(
                    children: [
                      // View Count
                      if (poem.viewCount > 0) ...[
                        Icon(
                          Icons.visibility_outlined,
                          size: 9,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : Colors.black.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _formatNumber(poem.viewCount),
                          style: GoogleFonts.roboto(
                            fontSize: 8,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : Colors.black.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Like Count
                      if (poem.likeCount > 0) ...[
                        Icon(
                          Icons.favorite_border,
                          size: 9,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : Colors.black.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _formatNumber(poem.likeCount),
                          style: GoogleFonts.roboto(
                            fontSize: 8,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : Colors.black.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPoetryTypeColor(String poetryType) {
    switch (poetryType.toUpperCase()) {
      case 'GHAZAL':
        return const Color(0xFF8B5CF6); // Purple
      case 'NAZM':
        return const Color(0xFF3B82F6); // Blue
      case 'RUBAIYAT':
        return const Color(0xFF10B981); // Green
      case 'QASIDA':
        return const Color(0xFFEF4444); // Red
      case 'MARSIYA':
        return const Color(0xFF6B7280); // Gray
      case 'MASNAVI':
        return const Color(0xFFF59E0B); // Amber
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String _getPoetryTypeLabel(String poetryType) {
    return poetryType.toUpperCase();
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
