import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/app_colors.dart';
import '../models/hashtag_model.dart';

/// Renders a single hashtag pill. Tapping navigates to the hashtag page.
class HashtagPill extends StatelessWidget {
  final HashtagDto hashtag;
  final bool dense;

  const HashtagPill({
    required this.hashtag,
    this.dense = false,
    super.key,
  });

  /// Convenience constructor from a plain slug string (no color/metadata).
  HashtagPill.fromSlug(
    String slug, {
    this.dense = false,
    super.key,
  }) : hashtag = HashtagDto(slug: slug);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = hashtag.color != null
        ? Color(int.parse(hashtag.color!.replaceAll('#', '0xFF')))
        : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/hashtags/${hashtag.slug}'),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? 10 : 14,
            vertical: dense ? 4 : 7,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.18 : 0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.35 : 0.25),
            ),
          ),
          child: Text(
            '#${hashtag.name ?? hashtag.slug}',
            style: TextStyle(
              color: isDark ? color.withValues(alpha: 0.9) : color,
              fontSize: dense ? 12 : 13,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}

/// A horizontal row of hashtag pills built from a list of slug strings.
/// Only renders if [slugs] is non-empty.
class HashtagSlugRow extends StatelessWidget {
  final List<String> slugs;

  const HashtagSlugRow({required this.slugs, super.key});

  @override
  Widget build(BuildContext context) {
    if (slugs.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: slugs
          .map((slug) => HashtagPill.fromSlug(slug, dense: true))
          .toList(),
    );
  }
}
