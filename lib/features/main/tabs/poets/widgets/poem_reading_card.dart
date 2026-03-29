import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/features/engagement/providers/like_providers.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/couplet_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';

const String _urduFontFamily = 'Jameel Noori Nastaleeq';

/// Single reading surface for a poem.
///
/// Handles three states:
/// - [couplets] == null → loading spinner
/// - [couplets].isNotEmpty → real API couplets, one block per CoupletModel
/// - [couplets].isEmpty → fallback: parse fullText by \n\n into sher blocks
///
/// Script rendering is driven by [selectedScript], independent of the global
/// selectedLanguageProvider, so it works correctly when the user toggles scripts
/// on this screen without mutating global state.
class PoemReadingCard extends ConsumerWidget {
  final PoemModel poem;
  final List<CoupletModel>? couplets; // null = loading, empty = use fullText
  final String selectedScript;
  final int? selectedSherIndex;
  final ValueChanged<int?> onSherSelected;

  const PoemReadingCard({
    super.key,
    required this.poem,
    required this.couplets,
    required this.selectedScript,
    required this.selectedSherIndex,
    required this.onSherSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool useCouplets = couplets != null && couplets!.isNotEmpty;

    // Resolve content for the selected script
    final content = poem.getContentForLanguage(selectedScript);

    // Parse shers from fullText when no API couplets available
    final List<String> parsedShers = (!useCouplets && content != null && content.fullText.isNotEmpty)
        ? _parseShers(content.fullText)
        : [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.verseBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: couplets == null
          ? _buildLoading()
          : useCouplets
              ? _buildCoupletList(context, ref, isDark)
              : parsedShers.isNotEmpty
                  ? _buildParsedSherList(context, ref, parsedShers)
                  : _buildRawText(context, content?.fullText ?? ''),
    );
  }

  Widget _buildLoading() {
    return const SizedBox(
      height: 120,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // API couplets path
  // ────────────────────────────────────────────────────────────

  Widget _buildCoupletList(BuildContext context, WidgetRef ref, bool isDark) {
    final items = <Widget>[];
    for (int i = 0; i < couplets!.length; i++) {
      items.add(_buildCoupletBlock(context, ref, i, couplets![i]));
      if (i < couplets!.length - 1) {
        items.add(_sherDivider());
      }
    }
    return Column(children: items);
  }

  Widget _buildCoupletBlock(BuildContext context, WidgetRef ref, int index, CoupletModel couplet) {
    final isSelected = selectedSherIndex == index;

    return GestureDetector(
      onTap: () => onSherSelected(isSelected ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.07) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Couplet type label — subtle, inline-start
            if (couplet.coupletTypeName != null)
              _buildTypeLabel(couplet.coupletTypeName!),

            ..._versesFor(couplet),

            if (isSelected) ...[
              const SizedBox(height: 8),
              _buildCoupletActionTray(context, ref, couplet),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _versesFor(CoupletModel couplet) {
    return couplet.verses.map((v) => _verseLine(v.text)).toList();
  }

  /// Clean ❤️ / Save / Share tray shown under a selected API couplet.
  Widget _buildCoupletActionTray(BuildContext context, WidgetRef ref, CoupletModel couplet) {
    final isLiked = couplet.isLikedByCurrentUser;
    final isBookmarked = couplet.isBookmarkedByCurrentUser;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _trayButton(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? AppColors.feedLiked : AppColors.textSecondaryLight,
          label: couplet.likeCount > 0 ? '${couplet.likeCount}' : 'Like',
          onPressed: () async {
            try {
              await ref.read(likeActionProvider.notifier).toggleLike(poem.publicId);
            } catch (_) {}
          },
        ),
        const SizedBox(width: 8),
        _trayButton(
          icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          color: isBookmarked ? AppColors.primary : AppColors.textSecondaryLight,
          label: 'Save',
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        _trayButton(
          icon: Icons.share_outlined,
          color: AppColors.textSecondaryLight,
          label: 'Share',
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _trayButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Parsed shers path (fullText split by \n\n)
  // ────────────────────────────────────────────────────────────

  Widget _buildParsedSherList(BuildContext context, WidgetRef ref, List<String> shers) {
    final items = <Widget>[];
    for (int i = 0; i < shers.length; i++) {
      items.add(_buildParsedSherBlock(context, ref, i, shers[i]));
      if (i < shers.length - 1) {
        items.add(_sherDivider());
      }
    }
    return Column(children: items);
  }

  Widget _buildParsedSherBlock(BuildContext context, WidgetRef ref, int index, String sherText) {
    final isSelected = selectedSherIndex == index;
    final isLiked = poem.isLikedByCurrentUser ?? false;

    return GestureDetector(
      onTap: () => onSherSelected(isSelected ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.07) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ..._sherLines(sherText),

            // Action tray when selected — poem-level like + copy + share
            if (isSelected) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isLiked ? AppColors.feedLiked : AppColors.textSecondaryLight,
                    ),
                    onPressed: () async {
                      try {
                        await ref.read(likeActionProvider.notifier).toggleLike(poem.publicId);
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to like poem')),
                          );
                        }
                      }
                    },
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.copy_outlined, size: 20, color: AppColors.textSecondaryLight),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: sherText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.share_outlined, size: 20, color: AppColors.textSecondaryLight),
                    onPressed: () {
                      // TODO: share sher text
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _sherLines(String block) {
    final lines = block.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    return lines.map((line) => _verseLine(line)).toList();
  }

  // ────────────────────────────────────────────────────────────
  // Raw text fallback (single block, no \n\n separators)
  // ────────────────────────────────────────────────────────────

  Widget _buildRawText(BuildContext context, String text) {
    return _scriptText(text, _verseStyle());
  }

  // ────────────────────────────────────────────────────────────
  // Shared helpers
  // ────────────────────────────────────────────────────────────

  Widget _verseLine(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: _scriptText(text, _verseStyle()),
    );
  }

  Widget _buildTypeLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 9,
          letterSpacing: 0.4,
          color: AppColors.textSecondaryLight.withValues(alpha: 0.55),
        ),
      ),
    );
  }

  Widget _sherDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        height: 1,
        color: AppColors.dividerLight,
        thickness: 0.5,
      ),
    );
  }

  /// Renders text with script-aware font and direction, bypassing LocalizedText
  /// which reads the global selectedLanguageProvider (would be out of sync with
  /// the screen-local _selectedScript).
  Widget _scriptText(String text, TextStyle style) {
    final isUrdu = selectedScript == 'ur';
    return Text(
      text,
      style: isUrdu ? style.copyWith(fontFamily: _urduFontFamily) : style,
      textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
      textAlign: TextAlign.center,
    );
  }

  TextStyle _verseStyle() {
    if (selectedScript == 'ur') {
      return const TextStyle(
        fontSize: 26,
        height: 2.0,
        fontWeight: FontWeight.w400,
      );
    }
    return const TextStyle(
      fontSize: 18,
      height: 1.7,
      fontWeight: FontWeight.w400,
    );
  }

  static List<String> _parseShers(String fullText) {
    return fullText
        .split('\n\n')
        .map((block) => block.trim())
        .where((block) => block.isNotEmpty)
        .toList();
  }
}
