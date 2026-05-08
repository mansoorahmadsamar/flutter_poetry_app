import 'package:flutter/material.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';

enum CreatorTab { poems, gallery, books, stats }

extension CreatorTabX on CreatorTab {
  String get englishLabel {
    switch (this) {
      case CreatorTab.poems:
        return 'My Poems';
      case CreatorTab.gallery:
        return 'Gallery';
      case CreatorTab.books:
        return 'Books';
      case CreatorTab.stats:
        return 'Stats';
    }
  }

  String get urduLabel {
    switch (this) {
      case CreatorTab.poems:
        return 'میری شاعری';
      case CreatorTab.gallery:
        return 'گیلری';
      case CreatorTab.books:
        return 'کتب';
      case CreatorTab.stats:
        return 'تجزیہ';
    }
  }

  IconData get icon {
    switch (this) {
      case CreatorTab.poems:
        return Icons.edit_note;
      case CreatorTab.gallery:
        return Icons.photo_library_outlined;
      case CreatorTab.books:
        return Icons.menu_book_outlined;
      case CreatorTab.stats:
        return Icons.auto_graph;
    }
  }
}

/// Sticky 4-tab bar for the creator dashboard. Default style is "underline"
/// matching the existing app aesthetic; pill and icon variants stay
/// available for future iterations.
enum CreatorTabBarStyle { underline, pill, icon }

class CreatorTabBar extends StatelessWidget implements PreferredSizeWidget {
  const CreatorTabBar({
    super.key,
    required this.active,
    required this.onChanged,
    this.style = CreatorTabBarStyle.underline,
  });

  final CreatorTab active;
  final ValueChanged<CreatorTab> onChanged;
  final CreatorTabBarStyle style;

  static const _tabs = CreatorTab.values;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case CreatorTabBarStyle.pill:
        return _pill(context);
      case CreatorTabBarStyle.icon:
        return _icon(context);
      case CreatorTabBarStyle.underline:
        return _underline(context);
    }
  }

  Widget _underline(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paperSurface,
        border: Border(
          bottom: BorderSide(color: AppColors.dividerLight),
        ),
      ),
      child: Row(
        children: _tabs.map((t) {
          final on = t == active;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(t),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 11, 4, 9),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t.englishLabel,
                          style: SukhanText.sans(
                            size: 12,
                            weight: on ? FontWeight.w600 : FontWeight.w500,
                            color: on ? AppColors.primary : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.urduLabel,
                          textDirection: TextDirection.rtl,
                          style: SukhanText.nastaleeq(
                            size: 11,
                            color: on ? AppColors.secondary : AppColors.inkSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (on)
                    Container(
                      height: 2,
                      width: 36,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _pill(BuildContext context) {
    return Container(
      color: AppColors.paperSurface,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.dividerLight),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: _tabs.map((t) {
            final on = t == active;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(t),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: on ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    t.englishLabel,
                    style: SukhanText.sans(
                      size: 12,
                      weight: on ? FontWeight.w600 : FontWeight.w500,
                      color: on ? AppColors.backgroundLight : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _icon(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paperSurface,
        border: Border(bottom: BorderSide(color: AppColors.dividerLight)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: _tabs.map((t) {
          final on = t == active;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(t),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          t.icon,
                          size: 18,
                          color: on ? AppColors.primary : AppColors.inkSubtle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.englishLabel,
                          style: SukhanText.sans(
                            size: 10,
                            weight: on ? FontWeight.w600 : FontWeight.w500,
                            color: on ? AppColors.primary : AppColors.inkSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (on)
                    Container(
                      width: 26,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
