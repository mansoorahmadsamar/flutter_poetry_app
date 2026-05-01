import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/sparkline.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/sukhan_chip.dart';
import '../../models/creator_analytics_model.dart';
import '../../providers/creator_providers.dart';

/// Analytics dashboard. 6-card metric grid + Top Poems list.
/// Sparkline trend per metric is the "medium depth" the user picked
/// during design exploration.
class StatsTab extends ConsumerWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(creatorAnalyticsProvider);
    return statsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Could not load stats: $e',
              style: SukhanText.italic(size: 12, color: AppColors.error)),
        ),
      ),
      data: (a) => _StatsView(stats: a),
    );
  }
}

class _StatsView extends StatelessWidget {
  const _StatsView({required this.stats});
  final CreatorAnalytics stats;

  @override
  Widget build(BuildContext context) {
    final metrics = <_Metric>[
      _Metric('Followers', 'مداحین', stats.followerCount, _flatTrend(stats.followerCount)),
      _Metric('Profile views', 'پروفائل دیکھے', stats.profileViews, _flatTrend(stats.profileViews)),
      _Metric('Poems', 'شاعری', stats.poemCount, _flatTrend(stats.poemCount)),
      _Metric('Poem views', 'شعر دیکھے', stats.totalPoemViews, _flatTrend(stats.totalPoemViews)),
      _Metric('Likes', 'پسند', stats.totalPoemLikes, _flatTrend(stats.totalPoemLikes)),
      _Metric('Bookmarks', 'محفوظ', stats.totalPoemBookmarks, _flatTrend(stats.totalPoemBookmarks)),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
      children: [
        Row(
          children: [
            Text('LAST 30 DAYS',
                style: SukhanText.eyebrow(color: AppColors.secondary)),
            const Spacer(),
            const SukhanChip(
              label: '30d ▾',
              variant: SukhanChipVariant.ghost,
              fontSize: 11,
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 100,
          ),
          itemCount: metrics.length,
          itemBuilder: (_, i) => _MetricCard(metric: metrics[i]),
        ),
        const SizedBox(height: 14),
        _topPoemsCard(context),
      ],
    );
  }

  Widget _topPoemsCard(BuildContext context) {
    if (stats.topPoems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.dividerLight),
        ),
        child: Center(
          child: Text(
            'Compose a few poems and your top hits will appear here.',
            textAlign: TextAlign.center,
            style: SukhanText.italic(
              size: 12,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Text('Top poems',
                    style: SukhanText.display(
                      size: 14,
                      color: AppColors.textPrimaryLight,
                      weight: FontWeight.w600,
                    )),
                const SizedBox(width: 8),
                Text('سب سے زیادہ مقبول',
                    textDirection: TextDirection.rtl,
                    style: SukhanText.nastaleeq(
                      size: 12,
                      color: AppColors.secondary,
                    )),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.dividerLight),
          for (var i = 0; i < stats.topPoems.length; i++)
            _TopPoemRow(
              rank: i + 1,
              poem: stats.topPoems[i],
              onTap: () => GoRouter.of(context)
                  .push('/main/poems/${stats.topPoems[i].publicId}'),
              isLast: i == stats.topPoems.length - 1,
            ),
        ],
      ),
    );
  }

  /// Generate a synthetic 7-point ascending trend ending at the current value.
  /// The backend doesn't yet expose timeseries, so we approximate visually.
  List<double> _flatTrend(int current) {
    if (current == 0) return List<double>.filled(7, 0);
    final base = current * 0.6;
    return List.generate(
      7,
      (i) => base + (current - base) * (i / 6),
    );
  }
}

class _Metric {
  const _Metric(this.english, this.urdu, this.value, this.trend);
  final String english;
  final String urdu;
  final int value;
  final List<double> trend;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});
  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 11, 13, 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric.english.toUpperCase(),
            style: SukhanText.eyebrow(
              size: 9,
              color: AppColors.inkSubtle,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _fmt(metric.value),
                style: SukhanText.display(
                  size: 22,
                  color: AppColors.textPrimaryLight,
                  weight: FontWeight.w600,
                  letterSpacing: -0.22,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_upward, size: 12, color: AppColors.success),
            ],
          ),
          const SizedBox(height: 4),
          if (metric.value > 0)
            Sparkline(
              data: metric.trend,
              color: AppColors.primary,
              width: 140,
              height: 18,
            ),
        ],
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}m';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}k';
    return '$n';
  }
}

class _TopPoemRow extends StatelessWidget {
  const _TopPoemRow({
    required this.rank,
    required this.poem,
    required this.onTap,
    required this.isLast,
  });

  final int rank;
  final TopPoem poem;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : AppColors.hairline,
              style: BorderStyle.solid,
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rank == 1 ? AppColors.secondary : AppColors.greenSoft,
              ),
              child: Text(
                '$rank',
                style: SukhanText.display(
                  size: 11,
                  color: rank == 1 ? AppColors.backgroundLight : AppColors.primary,
                  weight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                poem.title,
                textDirection: TextDirection.rtl,
                overflow: TextOverflow.ellipsis,
                style: SukhanText.nastaleeq(
                  size: 15,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.favorite_border, size: 11, color: AppColors.textSecondaryLight),
            const SizedBox(width: 3),
            Text('${poem.likeCount}',
                style: SukhanText.sans(
                  size: 11,
                  color: AppColors.textSecondaryLight,
                )),
            const SizedBox(width: 10),
            const Icon(Icons.visibility_outlined, size: 11, color: AppColors.textSecondaryLight),
            const SizedBox(width: 3),
            Text(_fmt(poem.viewCount),
                style: SukhanText.sans(
                  size: 11,
                  color: AppColors.textSecondaryLight,
                )),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}m';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}k';
    return '$n';
  }
}
