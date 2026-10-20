import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/routing/content_locations.dart';
import '../../../core/utils/language_typography.dart';
import '../models/couplet_theme.dart';
import '../utils/localized_name.dart';

/// A theme chip to show: the theme and its label in the app language.
typedef VisibleTheme = ({CoupletTheme theme, LocalizedLabel label});

/// A couplet's themes as tappable chips (`#ہجر`, `#Separation`, `#हिज्र`):
/// at most [kMaxCoupletThemes], named in the app language (fallback Urdu,
/// then English), each opening the theme's hashtag page `/hashtags/:slug`.
///
/// Renders nothing when there are no themes to show — which is every couplet
/// on production until the backend sends `themes`.
class CoupletThemeChips extends ConsumerWidget {
  const CoupletThemeChips({
    super.key,
    required this.themes,
    this.excludeSlug,
    this.alignment = WrapAlignment.center,
    this.padding = EdgeInsets.zero,
  });

  final List<CoupletTheme> themes;

  /// A theme not to show, e.g. the hashtag page the couplet is listed on
  /// (its chip would reopen the same page).
  final String? excludeSlug;

  final WrapAlignment alignment;

  /// Space around the chips, applied only when there are chips.
  final EdgeInsetsGeometry padding;

  /// Key of the chip for theme [slug].
  static Key chipKey(String slug) => ValueKey('theme-chip-$slug');

  /// The chips to show for [themes] in [appLanguage]: server order, without
  /// [excludeSlug] and themes with no name in any language, at most
  /// [kMaxCoupletThemes].
  static List<VisibleTheme> visibleThemes(
    List<CoupletTheme> themes,
    String appLanguage, {
    String? excludeSlug,
  }) {
    final visible = <VisibleTheme>[];
    for (final theme in themes) {
      if (visible.length == kMaxCoupletThemes) break;
      if (theme.slug == excludeSlug) continue;
      final label = theme.labelFor(appLanguage);
      if (label != null) visible.add((theme: theme, label: label));
    }
    return visible;
  }

  /// What a screen reader announces for a chip, in the app language.
  static String semanticsLabel(String appLanguage, String name) =>
      switch (appLanguage) {
        'ur' => 'موضوع: $name',
        'hi' => 'विषय: $name',
        _ => 'Theme: $name',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLanguage = ref.watch(selectedLanguageProvider);
    final visible =
        visibleThemes(themes, appLanguage, excludeSlug: excludeSlug);
    if (visible.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: Directionality(
        textDirection: LanguageTypography.getTextDirection(appLanguage),
        child: Wrap(
          alignment: alignment,
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final entry in visible)
              _ThemeChip(
                key: chipKey(entry.theme.slug),
                slug: entry.theme.slug,
                label: entry.label,
                semanticsLabel: semanticsLabel(appLanguage, entry.label.text),
              ),
          ],
        ),
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    super.key,
    required this.slug,
    required this.label,
    required this.semanticsLabel,
  });

  final String slug;
  final LocalizedLabel label;
  final String semanticsLabel;

  static const double _radius = 14;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.primaryLight : AppColors.primary;
    void open() => context.push(ContentLocations.hashtag(slug));

    // One node for screen readers: "Theme: Separation", a button that opens
    // the theme (the visible "#" text is not read).
    return Semantics(
      button: true,
      label: semanticsLabel,
      onTap: open,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: open,
          borderRadius: BorderRadius.circular(_radius),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.14 : 0.06),
              borderRadius: BorderRadius.circular(_radius),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Text(
              '#${label.text}',
              textDirection:
                  LanguageTypography.getTextDirection(label.languageCode),
              style: LanguageTypography.labelStyleFor(
                languageCode: label.languageCode,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
