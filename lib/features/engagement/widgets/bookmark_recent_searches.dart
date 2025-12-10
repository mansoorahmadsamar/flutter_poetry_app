import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/features/engagement/providers/bookmark_search_history_provider.dart';

class BookmarkRecentSearches extends ConsumerWidget {
  final void Function(String) onSearchTap;

  const BookmarkRecentSearches({
    super.key,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchHistory = ref.watch(bookmarkSearchHistoryProvider);

    if (searchHistory.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(bookmarkSearchHistoryProvider.notifier).clearAll();
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...searchHistory.take(5).map((query) {
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  leading: const Icon(Icons.history, color: Colors.grey),
                  title: Text(query),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      ref
                          .read(bookmarkSearchHistoryProvider.notifier)
                          .removeSearch(query);
                    },
                  ),
                  onTap: () => onSearchTap(query),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
