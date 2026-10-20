import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/utils/language_typography.dart';
import 'package:flutter_poetry_app/features/hashtags/widgets/couplet_theme_chips.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/utils/highlighted_text.dart';

/// A single matching verse (misra) in search results — `verses[]` from
/// `/api/search`.
///
/// Shows the line in its own script (Nastaliq RTL for Urdu, LTR otherwise)
/// and, when the API sends one, its Roman transliteration, both with the
/// query highlighted — so a Roman query like `jigar` highlights the Roman
/// line. Below: poet avatar, poet name and poem title when known.
///
/// Same frame as the couplet result card. Tappable (with a chevron)
/// only when [onTap] is set; callers set it only for verses with a parent
/// poem id, which the tap opens.
class AppSearchVerseCard extends StatelessWidget {
  /// Key of the chevron shown on tappable cards.
  static const chevronKey = Key('search-verse-chevron');

  /// Key of the Roman transliteration line.
  static const romanKey = Key('search-verse-roman');

  final VerseSearchResult result;
  final String searchQuery;
  final VoidCallback? onTap;

  const AppSearchVerseCard({
    super.key,
    required this.result,
    this.searchQuery = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = result.verse.text;
    final roman = result.romanizedText;
    final textLang = LanguageTypography.languageCodeForScript(text);
    final primary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          child: Ink(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.dividerLight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HighlightedText(
                  text: text,
                  query: searchQuery,
                  textDirection: LanguageTypography.getTextDirection(textLang),
                  textAlign: TextAlign.center,
                  style: LanguageTypography.createStyle(
                    baseFontSize: 17,
                    languageCode: textLang,
                    color: primary,
                  ),
                ),
                if (roman != null && roman != text) ...[
                  SizedBox(height: AppSpacing.xs),
                  HighlightedText(
                    key: romanKey,
                    text: roman,
                    query: searchQuery,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: LanguageTypography.createStyle(
                      baseFontSize: 13,
                      languageCode: 'en',
                      color: secondary,
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
                // Theme chips (nothing when the verse has no themes)
                CoupletThemeChips(
                  themes: result.themes,
                  padding: EdgeInsets.only(top: AppSpacing.sm),
                ),
                SizedBox(height: AppSpacing.md),
                _Attribution(
                  result: result,
                  searchQuery: searchQuery,
                  isDark: isDark,
                  showChevron: onTap != null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Attribution extends StatelessWidget {
  const _Attribution({
    required this.result,
    required this.searchQuery,
    required this.isDark,
    required this.showChevron,
  });

  final VerseSearchResult result;
  final String searchQuery;
  final bool isDark;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final poetName = result.poetName;
    final poemTitle = result.poemTitle;

    return Row(
      children: [
        _Avatar(imageUrl: result.poetProfileImageUrl),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (poetName != null)
                _line(poetName, 13, FontWeight.w600, AppColors.secondary),
              if (poemTitle != null)
                _line(
                  poemTitle,
                  11,
                  FontWeight.w400,
                  isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
            ],
          ),
        ),
        if (showChevron)
          Padding(
            padding: EdgeInsetsDirectional.only(start: AppSpacing.sm),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              key: AppSearchVerseCard.chevronKey,
              size: 14,
              color: isDark
                  ? AppColors.textDisabledDark
                  : AppColors.textDisabledLight,
            ),
          ),
      ],
    );
  }

  Widget _line(String text, double size, FontWeight weight, Color color) {
    final lang = LanguageTypography.languageCodeForScript(text);
    return HighlightedText(
      text: text,
      query: searchQuery,
      textDirection: LanguageTypography.getTextDirection(lang),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: LanguageTypography.createStyle(
        baseFontSize: size,
        languageCode: lang,
        fontWeight: weight,
        color: color,
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageUrl});

  /// Already placeholder-filtered by [VerseSearchResult].
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return ClipOval(
      child: url != null
          ? CachedNetworkImage(
              imageUrl: url,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              memCacheWidth: 64,
              placeholder: (_, __) => const _AvatarPlaceholder(),
              errorWidget: (_, __, ___) => const _AvatarPlaceholder(),
            )
          : const _AvatarPlaceholder(),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Icon(
        Icons.person_rounded,
        size: 16,
        color: AppColors.primary.withValues(alpha: 0.5),
      ),
    );
  }
}
