import 'package:flutter/material.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/utils/api_placeholder.dart';
import '../../../core/widgets/localized_text.dart';
import '../../main/tabs/poets/models/couplet_model.dart';
import 'couplet_theme_chips.dart';
import 'hashtag_pill.dart';

/// One couplet in a hashtag's اشعار / Couplets tab.
///
/// [onTap] opens the couplet's poem and is null when the couplet has no poem
/// id (production's `CoupletDto` sends none, T-177): the tile then has no tap
/// handler and no chevron. The poet name and poem title are shown only when
/// present.
class HashtagCoupletTile extends StatelessWidget {
  final CoupletDetailResponse couplet;
  final bool isDark;
  final bool isRtl;
  final VoidCallback? onTap;

  /// The hashtag page this tile is listed on; its own theme chip is hidden
  /// (it would reopen the same page).
  final String? hashtagSlug;

  const HashtagCoupletTile({
    required this.couplet,
    required this.isDark,
    required this.isRtl,
    this.onTap,
    this.hashtagSlug,
    super.key,
  });

  /// The couplet's lines joined one per row, without blank or `"-"` lines.
  static String verseText(CoupletDetailResponse couplet) => couplet.verses
      .map((v) => presentOrNull(v.text))
      .whereType<String>()
      .join('\n');

  /// Whether the couplet has any line to show; a tile without one would be an
  /// empty card.
  static bool hasVerseText(CoupletDetailResponse couplet) =>
      verseText(couplet).isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LocalizedText(
                verseText(couplet),
                style: TextStyle(
                  fontSize: isRtl ? 18 : 16,
                  fontWeight: FontWeight.w500,
                  height: isRtl ? 2.0 : 1.6,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              if (couplet.tagSlugs.isNotEmpty) ...[
                const SizedBox(height: 8),
                HashtagSlugRow(slugs: couplet.tagSlugs),
              ],
              // Theme chips (nothing when the couplet has no themes)
              CoupletThemeChips(
                themes: couplet.themes,
                excludeSlug: hashtagSlug,
                alignment: WrapAlignment.start,
                padding: const EdgeInsets.only(top: 8),
              ),
              _CoupletSourceRow(
                poetName: couplet.poetName,
                poemTitle: couplet.poemTitle,
                isRtl: isRtl,
                secondary: secondary,
                canOpenPoem: onTap != null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "poet — poem title" plus the open-poem chevron; nothing when there is
/// neither a name, a title nor a poem to open.
class _CoupletSourceRow extends StatelessWidget {
  final String? poetName;
  final String? poemTitle;
  final bool isRtl;
  final Color secondary;
  final bool canOpenPoem;

  const _CoupletSourceRow({
    required this.poetName,
    required this.poemTitle,
    required this.isRtl,
    required this.secondary,
    required this.canOpenPoem,
  });

  @override
  Widget build(BuildContext context) {
    if (poetName == null && poemTitle == null && !canOpenPoem) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          if (poetName != null)
            Flexible(
              child: LocalizedText(
                poetName!,
                style: TextStyle(
                  fontSize: isRtl ? 14 : 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  height: isRtl ? 1.6 : 1.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (poetName != null && poemTitle != null)
            Text(' — ', style: TextStyle(fontSize: 12, color: secondary)),
          if (poemTitle != null)
            Expanded(
              child: LocalizedText(
                poemTitle!,
                style: TextStyle(
                  fontSize: isRtl ? 13 : 12,
                  color: secondary,
                  height: isRtl ? 1.6 : 1.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Spacer(),
          if (canOpenPoem)
            Icon(
              isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
              size: 20,
              color: secondary,
              semanticLabel: isRtl ? 'نظم کھولیں' : 'Open poem',
            ),
        ],
      ),
    );
  }
}
