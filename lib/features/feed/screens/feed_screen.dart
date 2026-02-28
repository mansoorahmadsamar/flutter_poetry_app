import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/widgets/standard_app_bar.dart';
import '../providers/feed_provider.dart';
import '../widgets/feed_item_builder.dart';
import '../widgets/feed_shimmer.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => FeedScreenState();
}

class FeedScreenState extends ConsumerState<FeedScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final ScrollController scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(feedProvider.notifier).flushEvents();
    }
  }

  void _onScroll() {
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 600) {
      ref.read(feedProvider.notifier).loadNextPage();
    }
  }

  void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(feedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        color: AppColors.primary,
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            StandardSliverAppBar(
              title: 'For You',
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // TODO: Show notifications
                  },
                ),
              ],
            ),

            // Content
            if (state.isInitial || (state.isLoading && state.items.isEmpty))
              const SliverFillRemaining(
                hasScrollBody: true,
                child: FeedShimmer(),
              )
            else if (state.error != null && state.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _ErrorView(
                  error: state.error!,
                  onRetry: () =>
                      ref.read(feedProvider.notifier).loadFirstPage(),
                  isDark: isDark,
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Feed items
                    if (index < state.items.length) {
                      return FeedItemBuilder(item: state.items[index]);
                    }

                    // Footer (index == items.length)
                    if (state.isLoadingMore) {
                      return const _LoadingMore();
                    }
                    if (state.error != null) {
                      return _InlineRetry(
                        error: state.error!,
                        onRetry: () =>
                            ref.read(feedProvider.notifier).loadNextPage(),
                        isDark: isDark,
                      );
                    }
                    if (!state.hasMore) {
                      return _EndOfFeed(isDark: isDark);
                    }
                    return const SizedBox.shrink();
                  },
                  childCount: state.items.length + 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final bool isDark;

  const _ErrorView({
    required this.error,
    required this.onRetry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Could not load feed',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Check your connection and try again.',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingMore extends StatelessWidget {
  const _LoadingMore();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _InlineRetry extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final bool isDark;

  const _InlineRetry({
    required this.error,
    required this.onRetry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Text(
            'Failed to load more',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Tap to retry'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EndOfFeed extends StatelessWidget {
  final bool isDark;

  const _EndOfFeed({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: Text(
          'You\'re all caught up!',
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}
