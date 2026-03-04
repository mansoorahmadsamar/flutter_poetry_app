import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/poet_model.dart';

/// Detect if text contains Urdu/Arabic script characters.
bool _isUrduText(String text) {
  return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
}

const String _urduFontFamily = 'Jameel Noori Nastaleeq';

// ─────────────────────────────────────────────────────────────
// Design tokens — matches PoetCard for visual consistency
// ─────────────────────────────────────────────────────────────
class _Tokens {
  _Tokens._();

  static const Color surfaceLight = Color(0xFFFCFAF6);
  static const Color surfaceDark = Color(0xFF262626);
  static const Color borderLight = Color(0xFFEFE6DA);
  static const Color borderDark = Color(0xFF3A3A3A);
  static const Color placeholderLight = Color(0xFFF2EFE8);
  static const Color placeholderDark = Color(0xFF333333);
  static const double radius = 10.0;

  static Color chipBg(bool isDark) =>
      isDark ? Colors.black.withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.92);
  static Color chipBorder(bool isDark) =>
      isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE0D8CC);
  static Color chipText(bool isDark) =>
      isDark ? const Color(0xFFE0DCD5) : const Color(0xFF4A4540);

  static List<BoxShadow> shadow(bool isDark) => isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ]
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ];
}

/// Compact poet card for horizontal discovery sections.
///
/// Fixed width (120px), rectangular layout:
/// - Image (top, ~95px)
/// - Name (1 line, Urdu-aware)
/// - Dates (1 line)
/// - Stats row (poems + views)
class PoetHorizontalCard extends StatefulWidget {
  final PoetModel poet;
  final VoidCallback onTap;

  const PoetHorizontalCard({
    super.key,
    required this.poet,
    required this.onTap,
  });

  @override
  State<PoetHorizontalCard> createState() => _PoetHorizontalCardState();
}

class _PoetHorizontalCardState extends State<PoetHorizontalCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameIsUrdu = _isUrduText(widget.poet.name);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: SizedBox(
          width: 120,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? _Tokens.surfaceDark : _Tokens.surfaceLight,
              borderRadius: BorderRadius.circular(_Tokens.radius),
              border: Border.all(
                color: isDark ? _Tokens.borderDark : _Tokens.borderLight,
              ),
              boxShadow: _Tokens.shadow(isDark),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image ──
                _buildImage(isDark),

                // ── Content ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(7, 6, 7, 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        widget.poet.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: nameIsUrdu ? TextDirection.rtl : TextDirection.ltr,
                        style: nameIsUrdu
                            ? const TextStyle(
                                fontFamily: _urduFontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF1A1A1A),
                                height: 1.5,
                              )
                            : GoogleFonts.roboto(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? const Color(0xFFF0ECE6)
                                    : const Color(0xFF1A1A1A),
                                height: 1.25,
                              ),
                      ),
                      const SizedBox(height: 2),

                      // Dates
                      Text(
                        _formatDates(widget.poet),
                        style: GoogleFonts.roboto(
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Stats + trending
                      Row(
                        children: [
                          Icon(Icons.menu_book_rounded,
                              size: 9,
                              color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          const SizedBox(width: 2),
                          Text(
                            _fmt(widget.poet.poemCount),
                            style: GoogleFonts.roboto(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey[300] : const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.visibility_outlined,
                              size: 9,
                              color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          const SizedBox(width: 2),
                          Text(
                            _fmt(widget.poet.viewCount),
                            style: GoogleFonts.roboto(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey[300] : const Color(0xFF1A1A1A),
                            ),
                          ),
                          if (widget.poet.isTrending) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.orange.withValues(alpha: 0.15)
                                    : Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.whatshot_rounded, size: 7, color: Colors.orange[700]),
                                  const SizedBox(width: 1),
                                  Text(
                                    'Trending',
                                    style: GoogleFonts.roboto(
                                      fontSize: 6,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                ],
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
        ),
      ),
    );
  }

  Widget _buildImage(bool isDark) {
    final poet = widget.poet;
    final hasImage = poet.profileImageUrl != null && poet.profileImageUrl!.isNotEmpty && poet.profileImageUrl != '-';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(_Tokens.radius)),
      child: SizedBox(
        height: 95,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              Hero(
                tag: 'poet_image_${poet.publicId}',
                child: CachedNetworkImage(
                  imageUrl: poet.profileImageUrl!,
                  fit: BoxFit.cover,
                  memCacheWidth: 240,
                  maxWidthDiskCache: 240,
                  fadeInDuration: const Duration(milliseconds: 200),
                  placeholder: (_, __) => _placeholder(isDark),
                  errorWidget: (_, __, ___) => _placeholder(isDark),
                ),
              )
            else
              _placeholder(isDark),

            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Era chip
            if (poet.era != null)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: _Tokens.chipBg(isDark),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _Tokens.chipBorder(isDark), width: 0.5),
                  ),
                  child: Text(
                    _eraLabel(poet.era!),
                    style: GoogleFonts.roboto(
                      fontSize: 6,
                      fontWeight: FontWeight.w700,
                      color: _Tokens.chipText(isDark),
                    ),
                  ),
                ),
              ),

            // Featured badge
            if (poet.isFeatured)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _Tokens.chipBg(isDark),
                    shape: BoxShape.circle,
                    border: Border.all(color: _Tokens.chipBorder(isDark), width: 0.5),
                  ),
                  child: const Center(
                    child: Text('\u2B50', style: TextStyle(fontSize: 8)),
                  ),
                ),
              ),

            // Country flag
            if (poet.countryFlag != null && poet.countryFlag != '-' && poet.countryFlag!.isNotEmpty)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: _Tokens.chipBg(isDark),
                    shape: BoxShape.circle,
                    border: Border.all(color: _Tokens.chipBorder(isDark), width: 0.5),
                  ),
                  child: Text(
                    poet.countryFlag!,
                    style: const TextStyle(fontSize: 9),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(bool isDark) {
    return Container(
      color: isDark ? _Tokens.placeholderDark : _Tokens.placeholderLight,
      child: Center(
        child: Icon(
          Icons.person_outline_rounded,
          size: 20,
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.grey.withValues(alpha: 0.25),
        ),
      ),
    );
  }

  static String _eraLabel(String raw) {
    switch (raw) {
      case 'CLASSICAL':
        return 'Classical';
      case 'MODERN':
        return 'Modern';
      case 'CONTEMPORARY':
        return 'Contemporary';
      case 'EMERGING':
        return 'Emerging';
      default:
        return raw;
    }
  }

  static String _formatDates(PoetModel p) {
    if (p.birthYear == 0) return '\u2014';
    final death = (p.deathYear > 0) ? '${p.deathYear}' : (p.isActive ? 'Present' : '\u2014');
    return '${p.birthYear} \u2013 $death';
  }

  static String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
