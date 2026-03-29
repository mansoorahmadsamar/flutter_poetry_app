import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/features/engagement/providers/couplet_providers.dart';
import 'package:flutter_poetry_app/features/engagement/providers/reaction_providers.dart';
import 'package:flutter_poetry_app/features/engagement/widgets/reaction_button.dart';
import 'package:flutter_poetry_app/features/image_poetry/widgets/share_options_sheet.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/couplet_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';

const String _urduFontFamily = 'Jameel Noori Nastaleeq';

class PoemReadingCard extends ConsumerWidget {
  final PoemModel poem;
  final List<CoupletModel>? couplets;
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
    final content = poem.getContentForLanguage(selectedScript);
    final List<String> parsedShers =
        (!useCouplets && content != null && content.fullText.isNotEmpty)
            ? _parseShers(content.fullText)
            : [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
              ? _buildCoupletList(context, ref)
              : parsedShers.isNotEmpty
                  ? _buildParsedSherList(context, ref, parsedShers)
                  : _buildRawText(context, content?.fullText ?? ''),
    );
  }

  Widget _buildLoading() {
    return const SizedBox(
      height: 120,
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // API couplets path
  // ────────────────────────────────────────────────────────────

  Widget _buildCoupletList(BuildContext context, WidgetRef ref) {
    final items = <Widget>[];
    for (int i = 0; i < couplets!.length; i++) {
      items.add(_buildCoupletBlock(context, ref, i, couplets![i]));
      if (i < couplets!.length - 1) items.add(_sherDivider());
    }
    return Column(children: items);
  }

  Widget _buildCoupletBlock(
      BuildContext context, WidgetRef ref, int index, CoupletModel couplet) {
    final isSelected = selectedSherIndex == index;
    final typeCode = couplet.coupletType; // MATLA | MAQTA | REGULAR | etc.
    final showLabel = typeCode == 'MATLA' || typeCode == 'MAQTA';
    final label = typeCode == 'MATLA' ? 'مطلع' : 'مقطع';

    return GestureDetector(
      onTap: () => onSherSelected(isSelected ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.07)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Stack(
          children: [
            // Verse lines — full width, centered
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top padding when label is present so it doesn't overlap
                if (showLabel) const SizedBox(height: 4),
                ..._versesFor(couplet),
                if (isSelected) ...[
                  const SizedBox(height: 8),
                  _buildCoupletActionTray(context, ref, couplet),
                ],
              ],
            ),

            // Label pinned to top-right
            if (showLabel)
              Positioned(
                top: 0,
                right: 0,
                child: _buildCoupletTypeTag(label),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoupletTypeTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.15),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(6),
          bottomLeft: Radius.circular(6),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: _urduFontFamily,
          fontSize: 11,
          color: AppColors.secondary,
          height: 1.5,
        ),
      ),
    );
  }

  List<Widget> _versesFor(CoupletModel couplet) {
    return couplet.verses.map((v) => _verseLine(v.text)).toList();
  }

  // ────────────────────────────────────────────────────────────
  // Couplet action tray — top 3 reactions with counts + icon-only bookmark/share
  // ────────────────────────────────────────────────────────────

  Widget _buildCoupletActionTray(
      BuildContext context, WidgetRef ref, CoupletModel couplet) {
    final isBookmarked = couplet.isBookmarkedByCurrentUser ?? false;
    final userReaction = couplet.reactions?['userReaction'] as String?;
    final totalReactions = (couplet.reactions?['total'] as int?) ?? 0;
    final reactionsByType = couplet.reactions?['byType'] != null
        ? Map<String, int>.from(couplet.reactions!['byType'] as Map)
        : null;

    final reactionTypes = ref.watch(reactionTypesProvider).valueOrNull ?? [];

    // Build top-3 reaction entries sorted by count
    List<MapEntry<String, int>> topReactions = [];
    if (reactionsByType != null && reactionsByType.isNotEmpty) {
      topReactions = reactionsByType.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      if (topReactions.length > 3) topReactions = topReactions.take(3).toList();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Reaction button (tap=LOVE toggle, long-press=picker)
          ReactionButton(
            userReaction: userReaction,
            totalCount: totalReactions,
            reactionsByType: reactionsByType,
            size: ReactionButtonSize.compact,
            onReact: (reactionType) async {
              try {
                await ref.read(reactionActionProvider.notifier).react(
                      targetType: 'couplets',
                      publicId: couplet.publicId,
                      reactionType: reactionType,
                    );
              } catch (_) {}
            },
          ),

          // Individual top-3 reaction emoji+count chips
          if (topReactions.isNotEmpty) ...[
            const SizedBox(width: 6),
            ...topReactions.map((e) {
              final rt = reactionTypes.isNotEmpty
                  ? reactionTypes.firstWhere(
                      (r) => r.key == e.key,
                      orElse: () => reactionTypes.first,
                    )
                  : null;
              final emoji = rt?.emoji ?? '❤️';
              return _reactionChip(emoji, e.value);
            }),
          ],

          const Spacer(),

          // Bookmark — icon only
          _iconTrayButton(
            icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: isBookmarked ? AppColors.primary : AppColors.textSecondaryLight,
            onPressed: () async {
              try {
                await ref
                    .read(coupletActionProvider.notifier)
                    .toggleBookmark(couplet.publicId, lang: selectedScript);
              } catch (_) {}
            },
          ),

          // Share — icon only
          _iconTrayButton(
            icon: Icons.share_outlined,
            color: AppColors.textSecondaryLight,
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => ShareOptionsSheet(coupletId: couplet.publicId),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reactionChip(String emoji, int count) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 3),
          Text(
            _fmtCount(count),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconTrayButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Icon(icon, size: 19, color: color),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Parsed shers path (fullText split by \n\n)
  // ────────────────────────────────────────────────────────────

  Widget _buildParsedSherList(
      BuildContext context, WidgetRef ref, List<String> shers) {
    final items = <Widget>[];
    for (int i = 0; i < shers.length; i++) {
      items.add(_buildParsedSherBlock(context, ref, i, shers[i]));
      if (i < shers.length - 1) items.add(_sherDivider());
    }
    return Column(children: items);
  }

  Widget _buildParsedSherBlock(
      BuildContext context, WidgetRef ref, int index, String sherText) {
    final isSelected = selectedSherIndex == index;
    final userReaction = poem.reactions?['userReaction'] as String?;
    final totalReactions = (poem.reactions?['total'] as int?) ?? 0;
    final reactionsByType = poem.reactions?['byType'] != null
        ? Map<String, int>.from(poem.reactions!['byType'] as Map)
        : null;

    return GestureDetector(
      onTap: () => onSherSelected(isSelected ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.07)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ..._sherLines(sherText),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ReactionButton(
                    userReaction: userReaction,
                    totalCount: totalReactions,
                    reactionsByType: reactionsByType,
                    size: ReactionButtonSize.compact,
                    onReact: (reactionType) async {
                      try {
                        await ref.read(reactionActionProvider.notifier).react(
                              targetType: 'poems',
                              publicId: poem.publicId,
                              reactionType: reactionType,
                            );
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to react')),
                          );
                        }
                      }
                    },
                  ),
                  _iconTrayButton(
                    icon: Icons.copy_outlined,
                    color: AppColors.textSecondaryLight,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: sherText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('کاپی ہو گیا'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  _iconTrayButton(
                    icon: Icons.share_outlined,
                    color: AppColors.textSecondaryLight,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: sherText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('شعر کاپی ہو گیا'),
                          duration: Duration(seconds: 1),
                        ),
                      );
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
    final lines = block
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    return lines.map((line) => _verseLine(line)).toList();
  }

  // ────────────────────────────────────────────────────────────
  // Raw text fallback
  // ────────────────────────────────────────────────────────────

  Widget _buildRawText(BuildContext context, String text) {
    return _scriptText(text, _verseStyle());
  }

  // ────────────────────────────────────────────────────────────
  // Shared helpers
  // ────────────────────────────────────────────────────────────

  Widget _verseLine(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: _scriptText(text, _verseStyle()),
    );
  }

  Widget _sherDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Divider(height: 1, color: AppColors.dividerLight, thickness: 0.5),
    );
  }

  Widget _scriptText(String text, TextStyle style) {
    final isUrdu = selectedScript == 'ur';
    return Text(
      text,
      style: isUrdu ? style.copyWith(fontFamily: _urduFontFamily) : style,
      textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
      textAlign: isUrdu ? TextAlign.justify : TextAlign.center,
    );
  }

  TextStyle _verseStyle() {
    if (selectedScript == 'ur') {
      return const TextStyle(
        fontSize: 25,
        height: 1.9,
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

  static String _fmtCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}
