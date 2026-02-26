import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';

/// Standard app bar with consistent styling across the app
class StandardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const StandardAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      bottom: bottom,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}

/// Standard sliver app bar with consistent styling across the app
class StandardSliverAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool floating;
  final bool snap;
  final bool pinned;
  final double? expandedHeight;
  final Widget? flexibleSpace;

  const StandardSliverAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.floating = true,
    this.snap = true,
    this.pinned = false,
    this.expandedHeight,
    this.flexibleSpace,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions,
      leading: leading,
      floating: floating,
      snap: snap,
      pinned: pinned,
      expandedHeight: expandedHeight,
      flexibleSpace: flexibleSpace,
      elevation: 0,
    );
  }
}
