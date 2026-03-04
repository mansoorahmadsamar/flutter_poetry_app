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
// Design tokens — centralised for easy tweaking
// ─────────────────────────────────────────────────────────────
class _CardTokens {
  _CardTokens._();

  // Surface
  static const Color surfaceLight = Color(0xFFFCFAF6);
  static const Color surfaceDark = Color(0xFF262626);
  static const Color borderLight = Color(0xFFEFE6DA);
  static const Color borderDark = Color(0xFF3A3A3A);
  static const Color placeholderLight = Color(0xFFF2EFE8);
  static const Color placeholderDark = Color(0xFF333333);

  // Shadows (dual)
  static List<BoxShadow> cardShadow(bool isDark) => isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ]
      : [
          // Ambient
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          // Lift
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ];

  static List<BoxShadow> cardShadowPressed(bool isDark) => isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ]
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ];

  // Radius
  static const double radius = 12.0;

  // Accent
  static const Color accent = Color(0xFF1F6F5B);

  // Chip
  static Color chipBg(bool isDark) =>
      isDark ? Colors.black.withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.92);
  static Color chipBorder(bool isDark) =>
      isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE0D8CC);
  static Color chipText(bool isDark) =>
      isDark ? const Color(0xFFE0DCD5) : const Color(0xFF4A4540);
}

// ─────────────────────────────────────────────────────────────
// Small stat widget (poem count / view count)
// ─────────────────────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool isDark;
  final String? semanticLabel;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.isDark,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          const SizedBox(width: 2),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey[300] : const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PoetCard — premium grid card
// ─────────────────────────────────────────────────────────────

/// Premium poet card for 3-column grid.
///
/// Image area with gradient readability overlay, era chip,
/// featured badge, country flag.  Content area with name + verified
/// badge, life dates, divider, stats + optional trending pill.
///
/// RTL-safe: uses [EdgeInsetsDirectional] and [CrossAxisAlignment.start].
/// Name auto-detects Urdu text and switches to Nastaliq font + RTL.
class PoetCard extends StatefulWidget {
  final PoetModel poet;
  final VoidCallback onTap;

  const PoetCard({
    super.key,
    required this.poet,
    required this.onTap,
  });

  @override
  State<PoetCard> createState() => _PoetCardState();
}

class _PoetCardState extends State<PoetCard> {
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
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            color: isDark ? _CardTokens.surfaceDark : _CardTokens.surfaceLight,
            borderRadius: BorderRadius.circular(_CardTokens.radius),
            border: Border.all(
              color: isDark ? _CardTokens.borderDark : _CardTokens.borderLight,
            ),
            boxShadow: _isPressed
                ? _CardTokens.cardShadowPressed(isDark)
                : _CardTokens.cardShadow(isDark),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image section ──
              _ImageSection(poet: widget.poet, isDark: isDark),

              // ── Content section ──
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(8, 7, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + verified
                    _NameRow(poet: widget.poet, isDark: isDark, isUrdu: nameIsUrdu),
                    const SizedBox(height: 2),

                    // Years
                    Text(
                      _formatDates(widget.poet),
                      style: GoogleFonts.roboto(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : Colors.black54,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Divider
                    Container(
                      height: 0.5,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE8E2D8),
                    ),
                    const SizedBox(height: 5),

                    // Stats row + trending
                    _StatsRow(poet: widget.poet, isDark: isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDates(PoetModel p) {
    if (p.birthYear == 0) return '—';
    final death = (p.deathYear > 0) ? '${p.deathYear}' : (p.isActive ? 'Present' : '—');
    return '${p.birthYear} – $death';
  }
}

// ─────────────────────────────────────────────────────────────
// Image section (Stack: image, gradient, era, featured, flag)
// ─────────────────────────────────────────────────────────────
class _ImageSection extends StatelessWidget {
  final PoetModel poet;
  final bool isDark;

  const _ImageSection({required this.poet, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final hasImage = poet.profileImageUrl != null && poet.profileImageUrl!.isNotEmpty && poet.profileImageUrl != '-';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(_CardTokens.radius)),
      child: AspectRatio(
        aspectRatio: 1.0, // Square image for compact 3-column grid
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            if (hasImage)
              Hero(
                tag: 'poet_image_${poet.publicId}',
                child: CachedNetworkImage(
                  imageUrl: poet.profileImageUrl!,
                  fit: BoxFit.cover,
                  memCacheWidth: 280,
                  maxWidthDiskCache: 280,
                  fadeInDuration: const Duration(milliseconds: 200),
                  placeholder: (_, __) => _placeholder(),
                  errorWidget: (_, __, ___) => _placeholder(),
                ),
              )
            else
              _placeholder(),

            // Top gradient overlay for badge readability
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Era chip — top-start
            if (poet.era != null)
              PositionedDirectional(
                top: 5,
                start: 5,
                child: _Chip(label: _eraLabel(poet.era!), isDark: isDark),
              ),

            // Featured badge — top-end
            if (poet.isFeatured)
              PositionedDirectional(
                top: 5,
                end: 5,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _CardTokens.chipBg(isDark),
                    shape: BoxShape.circle,
                    border: Border.all(color: _CardTokens.chipBorder(isDark), width: 0.5),
                  ),
                  child: const Center(
                    child: Text('⭐', style: TextStyle(fontSize: 10)),
                  ),
                ),
              ),

            // Country flag — bottom-end
            if (poet.countryFlag != null && poet.countryFlag != '-' && poet.countryFlag!.isNotEmpty)
              PositionedDirectional(
                bottom: 5,
                end: 5,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: _CardTokens.chipBg(isDark),
                    shape: BoxShape.circle,
                    border: Border.all(color: _CardTokens.chipBorder(isDark), width: 0.5),
                  ),
                  child: Text(
                    poet.countryFlag!,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: isDark ? _CardTokens.placeholderDark : _CardTokens.placeholderLight,
      child: Center(
        child: Icon(
          Icons.person_outline_rounded,
          size: 24,
          color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.25),
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
}

// ─────────────────────────────────────────────────────────────
// Small reusable chip for image overlay
// ─────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final bool isDark;

  const _Chip({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: _CardTokens.chipBg(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _CardTokens.chipBorder(isDark), width: 0.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.roboto(
          fontSize: 7,
          fontWeight: FontWeight.w700,
          color: _CardTokens.chipText(isDark),
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Name row (name text + verified badge)
// ─────────────────────────────────────────────────────────────
class _NameRow extends StatelessWidget {
  final PoetModel poet;
  final bool isDark;
  final bool isUrdu;

  const _NameRow({required this.poet, required this.isDark, this.isUrdu = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            poet.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
            style: isUrdu
                ? TextStyle(
                    fontFamily: _urduFontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: isDark ? const Color(0xFFF0ECE6) : const Color(0xFF1A1A1A),
                    height: 1.6,
                  )
                : GoogleFonts.roboto(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFFF0ECE6) : const Color(0xFF1A1A1A),
                    height: 1.25,
                  ),
          ),
        ),
        if (poet.isVerified) ...[
          const SizedBox(width: 3),
          Semantics(
            label: 'Verified poet',
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: _CardTokens.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 8, color: Colors.white),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Stats row (poems, views, optional trending pill)
// ─────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final PoetModel poet;
  final bool isDark;

  const _StatsRow({required this.poet, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MiniStat(
          icon: Icons.menu_book_rounded,
          value: _fmt(poet.poemCount),
          isDark: isDark,
          semanticLabel: '${poet.poemCount} poems',
        ),
        const SizedBox(width: 8),
        _MiniStat(
          icon: Icons.visibility_outlined,
          value: _fmt(poet.viewCount),
          isDark: isDark,
          semanticLabel: '${poet.viewCount} views',
        ),
        const Spacer(),
        if (poet.isTrending)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.orange.withValues(alpha: 0.15)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.whatshot_rounded, size: 8, color: Colors.orange[700]),
                const SizedBox(width: 2),
                Text(
                  'Trending',
                  style: GoogleFonts.roboto(
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
