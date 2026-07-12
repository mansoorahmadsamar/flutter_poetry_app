import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_poetry_app/core/auth/auth_provider.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import '../../profile/providers/app_content_providers.dart';
import '../../profile/screens/app_content_detail_screen.dart';
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
                Text("Couldn't load your creator dashboard",
                    style: SukhanText.display(
                      size: 16,
                      color: AppColors.textPrimaryLight,
                      weight: FontWeight.w600,
                    )),
                const SizedBox(height: 8),
                Text('Pull down to retry, or check your connection.',
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
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Profile',
                  style: SukhanText.display(
                    size: 18,
                    color: AppColors.backgroundLight,
                    weight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert,
                    color: AppColors.backgroundLight),
                onPressed: () => _showMenu(context),
              ),
            ],
          ),
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
      builder: (sheetCtx) => _CreatorMenuSheet(
        onLogout: () async {
          final router = GoRouter.of(context);
          Navigator.of(sheetCtx).pop();
          await ref.read(authProvider.notifier).logout();
          router.go('/login');
        },
        onLanguagePicker: () {
          Navigator.of(sheetCtx).pop();
          _showLanguageSheet(context);
        },
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _CreatorLanguageSheet(),
    );
  }

}

/// Bottom-sheet body shown by the dashboard's overflow menu. Watches the
/// app-content + language providers so the About items load on demand
/// (the dashboard otherwise skips the profile-tab path that would have
/// fetched them).
class _CreatorMenuSheet extends ConsumerWidget {
  const _CreatorMenuSheet({
    required this.onLogout,
    required this.onLanguagePicker,
  });

  final VoidCallback onLogout;
  final VoidCallback onLanguagePicker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aboutAsync = ref.watch(appContentListProvider);
    final selectedLang = ref.watch(selectedLanguageNotifierProvider);
    final availableLangs =
        ref.watch(availableLanguagesProvider).valueOrNull ?? const [];
    final selectedLanguageName = availableLangs
            .where((l) => l.code == selectedLang.code)
            .map((l) => l.nativeName)
            .firstOrNull ??
        selectedLang.code.toUpperCase();

    return SafeArea(
      child: SingleChildScrollView(
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

              // ── Creator actions ──
              const _SectionLabel(label: 'Creator'),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit profile'),
                onTap: () {
                  Navigator.of(context).pop();
                  GoRouter.of(context).push('/main/creator/profile/edit');
                },
              ),

              const Divider(height: 1),

              // ── Settings ──
              const _SectionLabel(label: 'Settings'),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Reading language'),
                subtitle: Text(
                  selectedLanguageName,
                  style: SukhanText.italic(
                    size: 11,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                onTap: onLanguagePicker,
              ),

              const Divider(height: 1),

              // ── About (dynamic from backend) ──
              const _SectionLabel(label: 'About'),
              ...aboutAsync.when(
                loading: () => const [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
                error: (_, __) => [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About'),
                    subtitle: Text(
                      "Couldn't load — pull down to retry.",
                      style: SukhanText.italic(
                        size: 11,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
                data: (items) {
                  if (items.isEmpty) {
                    return const [
                      ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text('No content available'),
                      ),
                    ];
                  }
                  return [
                    for (final item in items)
                      ListTile(
                        leading: Icon(_iconForContentKey(item.contentKey)),
                        title: Text(item.title),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AppContentDetailScreen(
                                contentKey: item.contentKey,
                                title: item.title,
                              ),
                            ),
                          );
                        },
                      ),
                  ];
                },
              ),

              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text('Log out',
                    style: TextStyle(color: AppColors.error)),
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForContentKey(String key) {
    switch (key) {
      case 'ABOUT_APP':
        return Icons.info_outline;
      case 'PRIVACY_POLICY':
        return Icons.privacy_tip_outlined;
      case 'TERMS_OF_SERVICE':
        return Icons.description_outlined;
      case 'CONTACT_US':
        return Icons.contact_mail_outlined;
      case 'FAQ':
        return Icons.help_outline;
      default:
        return Icons.article_outlined;
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label.toUpperCase(),
          style: SukhanText.eyebrow(color: AppColors.secondary),
        ),
      ),
    );
  }
}

/// Language picker re-implemented inside the dashboard sheet to avoid
/// importing the private `_LanguageBottomSheet` from profile_tab.dart.
class _CreatorLanguageSheet extends ConsumerWidget {
  const _CreatorLanguageSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languagesAsync = ref.watch(availableLanguagesProvider);
    final selected = ref.watch(selectedLanguageNotifierProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.language, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'Reading language',
                  style: SukhanText.display(
                    size: 18,
                    color: AppColors.textPrimaryLight,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Pick your preferred language for poetry and UI.',
              style: SukhanText.italic(
                size: 12,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const Divider(height: 24),
            languagesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  "Couldn't load languages. Try again later.",
                  style: SukhanText.italic(
                    size: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
              data: (langs) => Column(
                children: langs.map((l) {
                  final on = l.code == selected.code;
                  return ListTile(
                    leading: Icon(
                      Icons.language,
                      size: 22,
                      color: on ? AppColors.primary : AppColors.inkSubtle,
                    ),
                    title: Text(
                      l.name,
                      style: TextStyle(
                        fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(l.nativeName),
                    trailing: on
                        ? const Icon(Icons.check_circle,
                            color: AppColors.primary)
                        : null,
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await ref
                          .read(selectedLanguageNotifierProvider.notifier)
                          .setLanguage(l.code);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Language changed to ${l.name}'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ],
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
    // Pin the child to exactly maxExtent. The tab bar's intrinsic height can
    // otherwise exceed its declared preferredSize (two text lines + Nastaleeq
    // + padding), which makes the pinned sliver report a layoutExtent larger
    // than its paintExtent and throw "SliverGeometry is not valid" each frame.
    return SizedBox(
      height: maxExtent,
      child: Container(
        color: AppColors.paperSurface,
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
      oldDelegate.tabBar.active != tabBar.active ||
      oldDelegate.tabBar.style != tabBar.style;
}
