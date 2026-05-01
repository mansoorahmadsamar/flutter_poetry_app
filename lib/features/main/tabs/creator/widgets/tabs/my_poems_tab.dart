import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/sukhan_chip.dart';
import '../../providers/creator_poems_provider.dart';
import '../../providers/creator_providers.dart';
import '../creator_poem_tile.dart';

/// "My Poems" tab content — paginated list with sort dropdown + compose FAB.
class MyPoemsTab extends ConsumerStatefulWidget {
  const MyPoemsTab({super.key});

  @override
  ConsumerState<MyPoemsTab> createState() => _MyPoemsTabState();
}

class _MyPoemsTabState extends ConsumerState<MyPoemsTab> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent * 0.8) {
      ref.read(creatorPoemsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(creatorPoemsProvider);
    final notifier = ref.read(creatorPoemsProvider.notifier);

    return Stack(
      children: [
        if (state.isLoading)
          const Center(child: CircularProgressIndicator(color: AppColors.primary))
        else if (state.isEmpty)
          _emptyState(context)
        else
          ListView.separated(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
            itemCount: state.poems.length + 2, // header + tiles + footer
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              if (i == 0) return _header(state, notifier);
              if (i == state.poems.length + 1) {
                if (state.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }
                if (!state.hasMore && state.poems.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text(
                        'You\'ve reached the end',
                        style: SukhanText.italic(
                          size: 11,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }
              final poem = state.poems[i - 1];
              return CreatorPoemTile(
                poem: poem,
                onTap: () => GoRouter.of(context)
                    .push('/main/poems/${poem.publicId}'),
                onMore: () async {
                  final messenger = ScaffoldMessenger.of(ctx);
                  final action = await showModalBottomSheet<String>(
                    context: ctx,
                    backgroundColor: AppColors.surfaceLight,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => CreatorPoemActionSheet(poem: poem),
                  );
                  if (action == 'toggle') {
                    try {
                      final updated = await ref
                          .read(creatorServiceProvider)
                          .updatePoem(poem.publicId, {'isPublic': !poem.isPublic});
                      ref.read(creatorPoemsProvider.notifier).replace(updated);
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Could not update: $e')),
                      );
                    }
                  } else if (action == 'delete') {
                    if (!ctx.mounted) return;
                    final ok = await _confirmDelete(ctx);
                    if (ok != true) return;
                    try {
                      await ref
                          .read(creatorServiceProvider)
                          .deletePoem(poem.publicId);
                      ref.read(creatorPoemsProvider.notifier).remove(poem.publicId);
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Could not delete: $e')),
                      );
                    }
                  }
                },
              );
            },
          ),
        Positioned(
          bottom: 18,
          right: 16,
          child: _ComposeFab(),
        ),
      ],
    );
  }

  Widget _header(CreatorPoemsState state, CreatorPoemsNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('${state.totalElements} POEMS',
              style: SukhanText.eyebrow(color: AppColors.secondary)),
          const Spacer(),
          PopupMenuButton<CreatorPoemsSort>(
            position: PopupMenuPosition.under,
            initialValue: state.sort,
            onSelected: notifier.setSort,
            itemBuilder: (_) => CreatorPoemsSort.values
                .map((s) => PopupMenuItem(
                      value: s,
                      child: Text(s.englishLabel),
                    ))
                .toList(),
            child: SukhanChip(
              label: '${state.sort.englishLabel} ▾',
              variant: SukhanChipVariant.outline,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 90),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.greenSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_note,
                  size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Text(
              'No poems yet',
              style: SukhanText.display(
                size: 18,
                color: AppColors.textPrimaryLight,
                weight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابھی کچھ نہیں لکھا',
              textDirection: TextDirection.rtl,
              style: SukhanText.nastaleeq(
                size: 14,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '"دل کی بات کرنے کا حوصلہ ابھی باقی ہے"',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: SukhanText.nastaleeq(
                size: 14,
                color: AppColors.primary,
                height: 1.9,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => GoRouter.of(context).push('/main/creator/compose'),
              icon: const Icon(Icons.edit_note, size: 16),
              label: const Text('Compose your first ghazal'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.backgroundLight,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: const StadiumBorder(),
                elevation: 0,
                textStyle: SukhanText.sans(
                  size: 12,
                  weight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete this poem?'),
        content: const Text(
          "It will be hidden from readers and removed from search. This can't be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ComposeFab extends StatelessWidget {
  const _ComposeFab();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => GoRouter.of(context).push('/main/creator/compose'),
      child: Container(
        width: 54,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.secondary,
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.5),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.edit_note,
            size: 22, color: AppColors.backgroundLight),
      ),
    );
  }
}
