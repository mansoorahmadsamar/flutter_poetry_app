import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_poetry_app/core/auth/auth_provider.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import '../models/owned_poet_model.dart';
import '../providers/creator_providers.dart';
import '../widgets/creator_hero.dart';
import '../widgets/creator_tab_bar.dart';
import '../widgets/tabs/books_tab.dart';
import '../widgets/tabs/gallery_tab.dart';
import '../widgets/tabs/my_poems_tab.dart';
import '../widgets/tabs/stats_tab.dart';

/// 4-tab creator dashboard shown when the user has a verified poet.
/// Hero stays as a sliver above; tab bar is sticky.
class CreatorDashboardScreen extends ConsumerStatefulWidget {
  const CreatorDashboardScreen({super.key});

  @override
  ConsumerState<CreatorDashboardScreen> createState() =>
      _CreatorDashboardScreenState();
}

class _CreatorDashboardScreenState
    extends ConsumerState<CreatorDashboardScreen> {
  CreatorTab _active = CreatorTab.poems;

  @override
  Widget build(BuildContext context) {
    final ownedAsync = ref.watch(ownedPoetProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: ownedAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: AppColors.error.withValues(alpha: 0.7)),
                const SizedBox(height: 12),
                Text('Could not load creator dashboard',
                    style: SukhanText.display(
                      size: 16,
                      color: AppColors.textPrimaryLight,
                      weight: FontWeight.w600,
                    )),
                const SizedBox(height: 8),
                Text('$e',
                    style: SukhanText.italic(
                      size: 12,
                      color: AppColors.textSecondaryLight,
                    )),
              ],
            ),
          ),
        ),
        data: (poet) {
          if (poet == null) {
            return const Center(child: Text('No creator profile found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(ownedPoetProvider);
              await ref.read(ownedPoetProvider.future);
            },
            color: AppColors.primary,
            child: NestedScrollView(
              headerSliverBuilder: (_, __) => [
                SliverToBoxAdapter(child: _topBar(poet)),
                SliverToBoxAdapter(child: CreatorHero(poet: poet)),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    tabBar: CreatorTabBar(
                      active: _active,
                      onChanged: (t) => setState(() => _active = t),
                    ),
                  ),
                ),
              ],
              body: IndexedStack(
                index: _active.index,
                children: const [
                  MyPoemsTab(),
                  GalleryTab(),
                  BooksTab(),
                  StatsTab(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _topBar(OwnedPoet poet) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Creator',
                        style: SukhanText.eyebrow(
                          color: AppColors.secondaryLight,
                        )),
                    Text(
                      poet.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SukhanText.display(
                        size: 16,
                        color: AppColors.backgroundLight,
                        weight: FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: AppColors.backgroundLight),
              onPressed: () => _showMenu(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
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
                title: const Text('Edit profile'),
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  GoRouter.of(context).push('/main/creator/profile/edit');
                },
              ),
              ListTile(
                leading: const Icon(Icons.translate_outlined),
                title: const Text('Manage translations'),
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  GoRouter.of(context).push('/main/creator/translations/en');
                },
              ),
              ListTile(
                leading: const Icon(Icons.fact_check_outlined),
                title: const Text('Edit facts'),
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  GoRouter.of(context).push('/main/creator/facts');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text('Log out',
                    style: TextStyle(color: AppColors.error)),
                onTap: () async {
                  final router = GoRouter.of(context);
                  Navigator.of(sheetCtx).pop();
                  await ref.read(authProvider.notifier).logout();
                  router.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate({required this.tabBar});
  final CreatorTabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.paperSurface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
      oldDelegate.tabBar.active != tabBar.active ||
      oldDelegate.tabBar.style != tabBar.style;
}
