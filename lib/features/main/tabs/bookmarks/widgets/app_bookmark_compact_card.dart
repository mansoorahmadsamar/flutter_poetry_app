import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/main/tabs/bookmarks/models/unified_bookmark_model.dart';
import 'package:flutter_poetry_app/features/search/utils/highlighted_text.dart';

/// Dense list-item card for the bookmarks feed.
///
/// Layout:
///   Line 1: Title (2 lines max) — language-adaptive font
///   Line 2: Poet name + optional subtle genre pill + time
///   Trailing: Language pill + chevron
///
/// No per-row type icon. No per-row bookmark icon.
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
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(10),
              splashColor: AppColors.primary.withValues(alpha: 0.08),
              highlightColor: AppColors.primary.withValues(alpha: 0.04),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? (widget.isDark
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.05))
                      : (widget.isDark
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFFFFFBF7)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.isSelected
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : (widget.isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.black.withValues(alpha: 0.03)),
                    width: 0.5,
                  ),
                ),
                child: Row(
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
                      const SizedBox(width: 10),
                    ],

                    // Content — title + metadata row
                    Expanded(child: _buildContent()),

                    // Chevron
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: widget.isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.15),
                    ),
                  ],
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
        // Line 1: Title (2 lines max)
        _buildTitle(),
        const SizedBox(height: 4),
        // Line 2: Poet + optional genre pill + time
        _buildSubtitle(),
      ],
    );
  }

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
        if (v2.isNotEmpty) return '$v1 · $v2';
        return v1;
      case 'IMAGE':
        return widget.bookmark.templateName ?? 'Image Poetry';
      default:
        return '';
    }
  }

  Widget _buildSubtitle() {
    final poet = widget.bookmark.poetName;
    final genre = widget.bookmark.contentSubTypeUrdu;
    final timeAgo = _formatTimeAgo(widget.bookmark.bookmarkedAt);
    final lang = widget.bookmark.languageCode;

    return Row(
      children: [
        // Poet name — language-appropriate font, prominent
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
        // Genre pill — subtle inline
        if (genre != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              genre,
              style: GoogleFonts.notoNastaliqUrdu(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: widget.isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
        const Spacer(),
        // Lang pill + time — compact trailing metadata
        _LangPill(lang: lang, isDark: widget.isDark),
        const SizedBox(width: 6),
        Text(
          timeAgo,
          style: GoogleFonts.roboto(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: widget.isDark
                ? AppColors.textDisabledDark
                : AppColors.textDisabledLight,
          ),
        ),
      ],
    );
  }

  /// Returns a language-appropriate title TextStyle.
  TextStyle _titleStyle() {
    final lang = widget.bookmark.languageCode;
    final color = widget.isDark
        ? const Color(0xFFE8E6E3)
        : AppColors.textPrimaryLight;

    if (lang == 'ur') {
      return GoogleFonts.notoNastaliqUrdu(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.7,
        color: color,
      );
    } else if (lang == 'hi') {
      return GoogleFonts.notoSansDevanagari(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: color,
      );
    } else {
      return GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );
    }
  }

  /// Language-appropriate poet name style — prominent, not generic Roboto.
  TextStyle _poetStyle() {
    final lang = widget.bookmark.languageCode;
    final color = widget.isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    if (lang == 'ur') {
      return GoogleFonts.notoNastaliqUrdu(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.6,
        color: color,
      );
    } else if (lang == 'hi') {
      return GoogleFonts.notoSansDevanagari(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color,
      );
    } else {
      return GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: color,
      );
    }
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo';
    return '${(diff.inDays / 365).floor()}y';
  }
}

/// Compact language pill (border-only, e.g. "UR", "EN", "HI").
class _LangPill extends StatelessWidget {
  final String lang;
  final bool isDark;

  const _LangPill({required this.lang, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.25)
              : AppColors.primary.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        lang.toUpperCase(),
        style: GoogleFonts.roboto(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AppColors.primary.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
