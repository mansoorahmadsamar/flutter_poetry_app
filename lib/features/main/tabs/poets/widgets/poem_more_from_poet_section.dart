import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/discover/widgets/section_header.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/providers/poem_providers.dart';
import 'poem_horizontal_card.dart';

/// Horizontal "More from [Poet]" section shown at the bottom of the poem
/// detail screen. Fetches the first page of poems by the same poet (same
/// poetry type) and excludes the currently viewed poem.
class PoemMoreFromPoetSection extends ConsumerWidget {
  final String poetPublicId;
  final String poetName;
  final String poetryType;
  final String currentPoemPublicId;
  final String selectedScript;

  const PoemMoreFromPoetSection({
    super.key,
    required this.poetPublicId,
    required this.poetName,
    required this.poetryType,
    required this.currentPoemPublicId,
    required this.selectedScript,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poemsAsync = ref.watch(poetPoemsProvider((
      poetPublicId: poetPublicId,
      poetryType: poetryType,
      page: 0,
    )));

    final poems = poemsAsync.maybeWhen(
      data: (response) => response.content
          .where((p) => p.publicId != currentPoemPublicId)
          .take(6)
          .toList(),
      orElse: () => null, // null = still loading
    );

    // Hide section entirely when loaded but empty
    if (poems != null && poems.isEmpty) return const SizedBox.shrink();

    final isUrdu = selectedScript == 'ur';
    final title = isUrdu ? 'مزید شاعری' : 'More from ${_shortName(poetName)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          icon: Icons.auto_stories_outlined,
          iconColor: AppColors.secondary,
          isRtl: isUrdu,
          itemCount: poems?.length ?? 0,
          totalCount: 99, // always show "See more"
          onSeeMore: () => context.push('/main/poets/$poetPublicId'),
        ),
        SizedBox(
          height: 160,
          child: poems == null
              ? _buildSkeleton()
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: poems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) => PoemHorizontalCard(
                    poem: poems[i],
                    selectedScript: selectedScript,
                    onTap: () => context.push('/main/poems/${poems[i].publicId}'),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (_, __) => Container(
        width: 150,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Takes first name/word for a shorter "More from X" label in English.
  String _shortName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    // For Urdu names passed with English script, take last word (family name convention)
    // For English, first word suffices
    return parts.first;
  }
}
