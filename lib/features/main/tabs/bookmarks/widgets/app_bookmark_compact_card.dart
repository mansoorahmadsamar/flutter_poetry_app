import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/main/tabs/bookmarks/models/unified_bookmark_model.dart';
import 'package:flutter_poetry_app/features/search/utils/highlighted_text.dart';

/// Editorial-style bookmark card with clear 3-tier visual hierarchy:
///
///   Line 1: Poetry text — largest, darkest, primary focus
///   Line 2: Poet name + genre pill — medium, softer
///   Line 3: Language badge + time — smallest, most subtle
///
/// Layered surface design with soft border (no shadow).
/// Full-card tap with scale 0.98 + ripple. No standalone chevron.
/// Swipe actions handled by parent Dismissible.
class AppBookmarkCompactCard extends StatefulWidget {
  final UnifiedBookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isDark;
  final bool isSelected;
  final bool isSelecting;
  final String? searchQuery;

  const AppBookmarkCompactCard({
    super.key,
    required this.bookmark,
    required this.onTap,
    this.onLongPress,
    required this.isDark,
    this.isSelected = false,
    this.isSelecting = false,
    this.searchQuery,
  });

  @override
  State<AppBookmarkCompactCard> createState() => _AppBookmarkCompactCardState();
}

class _AppBookmarkCompactCardState extends State<AppBookmarkCompactCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isRtl = widget.bookmark.languageCode == 'ur';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onLongPress: () {
          HapticFeedback.mediumImpact();
          widget.onLongPress?.call();
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(16),
                splashColor: AppColors.primary.withValues(alpha: 0.06),
                highlightColor: AppColors.primary.withValues(alpha: 0.03),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? (widget.isDark
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : AppColors.primary.withValues(alpha: 0.05))
                        : (widget.isDark
                            ? const Color(0xFF242424)
                            : const Color(0xFFF6F3EC)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.isSelected
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : (widget.isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.04)),
                      width: 1,
                    ),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Selection checkbox
                        if (widget.isSelecting) ...[
                          AnimatedScale(
                            scale: widget.isSelecting ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutBack,
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: widget.isSelected,
                                onChanged: (_) => widget.onTap(),
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: BorderSide(
                                  color: widget.isDark
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : Colors.black.withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],

                        // Image thumbnail for IMAGE bookmarks
                        if (widget.bookmark.type.toUpperCase() == 'IMAGE' &&
                            (widget.bookmark.thumbnailUrl != null ||
                                widget.bookmark.imageUrl != null)) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 56,
                              height: 56,
                              child: CachedNetworkImage(
                                imageUrl: widget.bookmark.thumbnailUrl ??
                                    widget.bookmark.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: widget.isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.04),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: widget.isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.04),
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 20,
                                    color: widget.isDark
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : Colors.black.withValues(alpha: 0.15),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],

                        // Content
                        Expanded(child: _buildContent()),

                        // Trailing: lang badge (top) + date (bottom)
                        const SizedBox(width: 12),
                        _buildTrailing(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Line 1: Poetry text — primary focus
        _buildTitle(),

        // Line 2: Poet + genre
        const SizedBox(height: 10),
        _buildPoetRow(),
      ],
    );
  }

  Widget _buildTrailing() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _LangBadge(lang: widget.bookmark.languageCode, isDark: widget.isDark),
        Text(
          _formatDate(widget.bookmark.bookmarkedAt),
          style: GoogleFonts.roboto(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.25)
                : const Color(0xFF888888),
          ),
        ),
      ],
    );
  }

  // ──── Line 1: Poetry Text ────

  Widget _buildTitle() {
    final title = _getTitleText();
    final style = _titleStyle();

    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      return HighlightedText(
        text: title,
        query: widget.searchQuery!,
        style: style,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Text(
      title,
      style: style,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _getTitleText() {
    switch (widget.bookmark.type.toUpperCase()) {
      case 'POEM':
        return widget.bookmark.poemTitle ?? '';
      case 'COUPLET':
        final v1 = widget.bookmark.coupletVerse1 ?? '';
        final v2 = widget.bookmark.coupletVerse2 ?? '';
        if (v2.isNotEmpty) return '$v1\n$v2';
        return v1;
      case 'IMAGE':
        return widget.bookmark.templateName ?? 'Image Poetry';
      default:
        return '';
    }
  }

  // ──── Line 2: Poet + Genre ────

  Widget _buildPoetRow() {
    final poet = widget.bookmark.poetName;
    final genre = widget.bookmark.contentSubTypeUrdu;

    return Row(
      children: [
        if (poet != null && poet.isNotEmpty) ...[
          Flexible(
            child: widget.searchQuery != null && widget.searchQuery!.isNotEmpty
                ? HighlightedText(
                    text: poet,
                    query: widget.searchQuery!,
                    style: _poetStyle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    poet,
                    style: _poetStyle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
        if (genre != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              genre,
              style: GoogleFonts.notoNastaliqUrdu(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: widget.isDark
                    ? AppColors.textDisabledDark
                    : AppColors.textSecondaryLight.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ──── Typography System ────

  /// Line 1: Poetry text — largest, darkest, primary focus.
  TextStyle _titleStyle() {
    final lang = widget.bookmark.languageCode;
    final color = widget.isDark
        ? const Color(0xFFEDEBE8)
        : const Color(0xFF1A1A1A);

    if (lang == 'ur') {
      return GoogleFonts.notoNastaliqUrdu(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.9,
        letterSpacing: -0.2,
        color: color,
      );
    } else if (lang == 'hi') {
      return GoogleFonts.notoSansDevanagari(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: color,
      );
    } else {
      return GoogleFonts.roboto(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: color,
      );
    }
  }

  /// Line 2: Poet name — medium size, softer color.
  TextStyle _poetStyle() {
    final lang = widget.bookmark.languageCode;
    final color = widget.isDark
        ? Colors.white.withValues(alpha: 0.5)
        : const Color(0xFF555555);

    if (lang == 'ur') {
      return GoogleFonts.notoNastaliqUrdu(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.6,
        color: color,
      );
    } else if (lang == 'hi') {
      return GoogleFonts.notoSansDevanagari(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color,
      );
    } else {
      return GoogleFonts.roboto(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: color,
      );
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    if (date.year == DateTime.now().year) {
      return '${months[date.month - 1]} ${date.day}, $hour:$minute $period';
    }
    return '${months[date.month - 1]} ${date.day}, ${date.year}, $hour:$minute $period';
  }
}

/// Elegant language badge — capsule shape with language-tinted background.
///
/// UR → soft sage   |  HI → soft peach  |  EN → soft blue-grey
class _LangBadge extends StatelessWidget {
  final String lang;
  final bool isDark;

  const _LangBadge({required this.lang, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _badgeColor(),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        lang.toUpperCase(),
        style: GoogleFonts.roboto(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: _textColor(),
        ),
      ),
    );
  }

  Color _badgeColor() {
    if (isDark) {
      switch (lang.toLowerCase()) {
        case 'ur':
          return const Color(0xFF2A3D32); // dark sage
        case 'hi':
          return const Color(0xFF3D2E2A); // dark peach
        case 'en':
          return const Color(0xFF2A3340); // dark blue-grey
        default:
          return const Color(0xFF2C2C2C);
      }
    }
    switch (lang.toLowerCase()) {
      case 'ur':
        return const Color(0xFFE8EFEA); // soft sage
      case 'hi':
        return const Color(0xFFF0E8E4); // soft peach
      case 'en':
        return const Color(0xFFE4E9EF); // soft blue-grey
      default:
        return const Color(0xFFECECEC);
    }
  }

  Color _textColor() {
    if (isDark) {
      switch (lang.toLowerCase()) {
        case 'ur':
          return const Color(0xFF8BB09A);
        case 'hi':
          return const Color(0xFFB08E82);
        case 'en':
          return const Color(0xFF8295AB);
        default:
          return const Color(0xFF999999);
      }
    }
    switch (lang.toLowerCase()) {
      case 'ur':
        return const Color(0xFF4A7A5C);
      case 'hi':
        return const Color(0xFF8A5E4A);
      case 'en':
        return const Color(0xFF4A6580);
      default:
        return const Color(0xFF666666);
    }
  }
}
