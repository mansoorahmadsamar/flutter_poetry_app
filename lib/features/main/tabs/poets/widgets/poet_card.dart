import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/poet_model.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';

/// Masterpiece poet card — manuscript-feel surface with gold halo portrait.
///
/// Layout (top to bottom):
///   [1] Gold-ringed circular portrait (40r) with halo effect
///   [2] Urdu-primary poet name — Nastaliq, bold, deep green
///   [3] English sub-name — uppercase, letter-spaced, low emphasis
///   [4] Life dates — subtle, muted
///   [5] Rich info row — stats in a tinted container
///
/// Surface: Paper cream (#FDFCF8) with soft shadow (20px blur).
/// Micro-interaction: scale 0.95 + haptic on tap.
class PoetCard extends ConsumerStatefulWidget {
  final PoetModel poet;
  final VoidCallback onTap;

  const PoetCard({
    super.key,
    required this.poet,
    required this.onTap,
  });

  @override
  ConsumerState<PoetCard> createState() => _PoetCardState();
}

class _PoetCardState extends ConsumerState<PoetCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(selectedLanguageProvider);
    final isUrdu = lang == 'ur';

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF242424)
                : const Color(0xFFFDFCF8), // Paper cream
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 14, 8, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Gold halo portrait
                  _buildPortrait(isDark),
                  const SizedBox(height: 10),

                  // Urdu-primary name
                  _buildName(isDark, isUrdu),
                  const SizedBox(height: 2),

                  // Life dates (low emphasis)
                  _buildDates(isDark),

                  const Spacer(),

                  // Rich info row
                  _buildInfoRow(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ──── Gold Halo Portrait ────

  Widget _buildPortrait(bool isDark) {
    final hasImage = widget.poet.profileImageUrl != null &&
        widget.poet.profileImageUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark
              ? const Color(0xFFD4AF37).withValues(alpha: 0.4)
              : const Color(0xFFD4AF37), // Gold halo
          width: 1.5,
        ),
      ),
      child: CircleAvatar(
        radius: 32,
        backgroundColor: isDark
            ? const Color(0xFF333333)
            : const Color(0xFFF0EDE6),
        child: ClipOval(
          child: hasImage
              ? CachedNetworkImage(
                  imageUrl: widget.poet.profileImageUrl!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  memCacheWidth: 200,
                  maxHeightDiskCache: 300,
                  maxWidthDiskCache: 300,
                  placeholder: (_, __) => Icon(
                    Icons.person_outline,
                    size: 24,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : AppColors.primary.withValues(alpha: 0.12),
                  ),
                  errorWidget: (_, __, ___) => _buildInitial(isDark),
                )
              : _buildInitial(isDark),
        ),
      ),
    );
  }

  Widget _buildInitial(bool isDark) {
    return Container(
      width: 64,
      height: 64,
      color: isDark ? const Color(0xFF333333) : const Color(0xFFF0EDE6),
      child: Center(
        child: Text(
          widget.poet.name.isNotEmpty ? widget.poet.name[0].toUpperCase() : '?',
          style: GoogleFonts.roboto(
            fontSize: 22,
            fontWeight: FontWeight.w300,
            color: isDark
                ? Colors.white.withValues(alpha: 0.25)
                : AppColors.primary.withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }

  // ──── Name (Urdu primary) ────

  Widget _buildName(bool isDark, bool isUrdu) {
    return Text(
      widget.poet.name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: isUrdu
          ? AppTypography.urduPoetNameStyle.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.7,
              color: isDark
                  ? const Color(0xFFEDEBE8)
                  : const Color(0xFF1B4332), // Deep green
            )
          : GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.3,
              letterSpacing: 0.1,
              color: isDark
                  ? const Color(0xFFEDEBE8)
                  : const Color(0xFF1B4332),
            ),
    );
  }

  // ──── Dates ────

  Widget _buildDates(bool isDark) {
    if (widget.poet.birthYear == 0) return const SizedBox.shrink();

    String dates;
    if (widget.poet.deathYear > 0) {
      dates = '${widget.poet.birthYear} – ${widget.poet.deathYear}';
    } else {
      dates = 'b. ${widget.poet.birthYear}';
    }

    return Text(
      dates,
      style: GoogleFonts.roboto(
        fontSize: 9,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        color: isDark
            ? Colors.white.withValues(alpha: 0.3)
            : Colors.grey.withValues(alpha: 0.6),
      ),
    );
  }

  // ──── Rich Info Row ────

  Widget _buildInfoRow(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF5F2EC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat(
            Icons.edit_note,
            '${widget.poet.poemCount}',
            isDark,
          ),
          if (widget.poet.viewCount > 0)
            _buildStat(
              Icons.visibility_outlined,
              _formatCount(widget.poet.viewCount),
              isDark,
            ),
          if (widget.poet.era != null)
            _buildStat(
              Icons.history_edu,
              _eraShortLabel(),
              isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: isDark
              ? const Color(0xFF8BB09A)
              : const Color(0xFF1B4332),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : const Color(0xFF3A3A3A),
          ),
        ),
      ],
    );
  }

  String _eraShortLabel() {
    switch (widget.poet.era) {
      case 'CLASSICAL':
        return 'Classic';
      case 'MODERN':
        return 'Modern';
      case 'CONTEMPORARY':
        return 'Contemp.';
      case 'EMERGING':
        return 'Emerging';
      default:
        return widget.poet.era ?? '';
    }
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
