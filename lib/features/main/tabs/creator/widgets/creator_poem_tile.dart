import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/sukhan_chip.dart';
import '../models/creator_poem_model.dart';

/// One row in the My Poems list.
/// - Public poems show eye/heart counts + green "PUBLIC" dot
/// - Drafts show italic "Saved Xd ago · Continue →"
class CreatorPoemTile extends StatelessWidget {
  const CreatorPoemTile({
    super.key,
    required this.poem,
    required this.onTap,
    required this.onMore,
  });

  final CreatorPoem poem;
  final VoidCallback onTap;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final type = PoetryType.byKey(poem.poetryType);
    // Resolve a display title: real title when present, otherwise a typed
    // Urdu placeholder ("بے عنوان · {type}") so the tile never shows a bare
    // "-" or empty heading for untitled/scraped poems.
    final hasTitle = poem.title.trim().isNotEmpty;
    final displayTitle =
        hasTitle ? poem.title : 'بے عنوان · ${type.urduLabel}';
    final isUrduTitle = _isRtl(displayTitle);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        // Mirror the entire tile body for Urdu titles so the title sits on
        // the right, the type chip + more-icon on the left, and the
        // engagement row (views/likes ↔ PUBLIC) flips to match. Flutter
        // handles the row/column reordering automatically via Directionality.
        child: Directionality(
          textDirection:
              isUrduTitle ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.dividerLight),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                displayTitle,
                                textDirection: isUrduTitle
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                style: isUrduTitle
                                    ? SukhanText.nastaleeq(
                                        size: 18,
                                        color: hasTitle
                                            ? AppColors.textPrimaryLight
                                            : AppColors.inkSubtle,
                                        height: 1.2,
                                      )
                                    : SukhanText.display(
                                        size: 16,
                                        color: hasTitle
                                            ? AppColors.textPrimaryLight
                                            : AppColors.inkSubtle,
                                        weight: FontWeight.w600,
                                        height: 1.2,
                                      ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            if (!poem.isPublic) ...[
                              const SizedBox(width: 8),
                              const SukhanChip(
                                label: 'DRAFT',
                                variant: SukhanChipVariant.ghost,
                                fontSize: 9,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _subtitle(poem),
                          style: SukhanText.italic(
                            size: 11,
                            color: AppColors.inkSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SukhanChip(
                    label: type.urduLabel,
                    variant: SukhanChipVariant.gold,
                    fontSize: 10,
                    fontFamily: AppTypography.urduFontFamily,
                    textDirection: TextDirection.rtl,
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert,
                        size: 18, color: AppColors.inkSubtle),
                    onPressed: onMore,
                    visualDensity: VisualDensity.compact,
                    splashRadius: 18,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.hairline,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (poem.isPublic)
                Row(
                  children: [
                    _Stat(
                        icon: Icons.visibility_outlined, value: poem.viewCount),
                    const SizedBox(width: 14),
                    _Stat(icon: Icons.favorite_border, value: poem.likeCount),
                    const Spacer(),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'PUBLIC',
                      style: SukhanText.eyebrow(
                        color: AppColors.primary,
                        size: 9,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _draftSubtitle(poem),
                        style: SukhanText.italic(
                          size: 11,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    Text(
                      'Continue →',
                      style: SukhanText.italic(
                        size: 12,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isRtl(String s) {
    if (s.isEmpty) return false;
    final c = s.runes.first;
    return (c >= 0x0600 && c <= 0x06FF) ||
        (c >= 0x0750 && c <= 0x077F) ||
        (c >= 0xFB50 && c <= 0xFDFF) ||
        (c >= 0xFE70 && c <= 0xFEFF);
  }

  String _subtitle(CreatorPoem p) {
    final dt = p.createdAt ?? p.updatedAt;
    if (dt == null) return p.languageCode.toUpperCase();
    return _shortDate(dt);
  }

  String _draftSubtitle(CreatorPoem p) {
    final dt = p.updatedAt ?? p.createdAt;
    if (dt == null) return 'Draft';
    final d = DateTime.now().difference(dt).inDays;
    if (d == 0) return 'Saved today';
    if (d == 1) return 'Saved yesterday';
    return 'Saved $d days ago';
  }

  String _shortDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value});
  final IconData icon;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondaryLight),
        const SizedBox(width: 4),
        Text(_fmt(value),
            style: SukhanText.sans(
              size: 11,
              color: AppColors.textSecondaryLight,
            )),
      ],
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}m';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}k';
    return '$n';
  }
}

/// Bottom-sheet menu shown when the user taps the 3-dot icon on a poem.
class CreatorPoemActionSheet extends StatelessWidget {
  const CreatorPoemActionSheet({super.key, required this.poem});
  final CreatorPoem poem;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dividerLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit details'),
              onTap: () {
                Navigator.of(context).pop();
                GoRouter.of(context)
                    .push('/main/creator/poems/${poem.publicId}/edit');
              },
            ),
            ListTile(
              leading: Icon(
                poem.isPublic ? Icons.lock_outline : Icons.public,
              ),
              title: Text(poem.isPublic ? 'Make draft' : 'Publish now'),
              onTap: () => Navigator.of(context).pop('toggle'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Delete', style: TextStyle(color: AppColors.error)),
              onTap: () => Navigator.of(context).pop('delete'),
            ),
          ],
        ),
      ),
    );
  }
}
