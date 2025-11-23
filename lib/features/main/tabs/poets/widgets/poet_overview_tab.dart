import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/poet_profile_model.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import '../providers/poet_providers.dart';

class PoetOverviewTab extends ConsumerWidget {
  final PoetProfileModel poet;

  const PoetOverviewTab({super.key, required this.poet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedLanguage = ref.watch(selectedLanguageProvider);
    final isUrdu = selectedLanguage == 'ur';

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Biography Section
          if (poet.biography != null) ...[
            Text(
              'Biography',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: AppSpacing.md),
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Text(
                poet.biography!,
                style: (isUrdu
                    ? AppTypography.getUrduTextTheme(context).bodyMedium
                    : Theme.of(context).textTheme.bodyMedium
                )?.copyWith(
                      height: isUrdu ? 2.0 : 1.8,
                    ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
          ],

          // Key Information Section
          Text(
            'Key Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: AppSpacing.md),
          _buildInfoGrid(context, isDark),
          SizedBox(height: AppSpacing.lg),

          // Facts Section
          if (poet.facts != null && poet.facts!.isNotEmpty) ...[
            Text(
              'Notable Facts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: AppSpacing.md),
            ..._buildFacts(context, isDark, isUrdu),
            SizedBox(height: AppSpacing.lg),
          ],

          // Tags Section
          if (poet.tags != null && poet.tags!.isNotEmpty) ...[
            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: poet.tags!
                  .map((tag) => Chip(
                        label: Text(tag.name),
                        backgroundColor: (tag.color != null
                                ? Color(int.parse('0xff${tag.color!.replaceFirst('#', '')}'))
                                : Colors.grey)
                            .withValues(alpha: 0.3),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context, bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildInfoCard(
          context,
          'Birth Year',
          poet.birthYear.toString(),
          isDark,
        ),
        _buildInfoCard(
          context,
          'Death Year',
          poet.deathYear?.toString() ?? 'Active',
          isDark,
        ),
        _buildInfoCard(
          context,
          'Birth Place',
          poet.birthPlace ?? 'Unknown',
          isDark,
        ),
        _buildInfoCard(
          context,
          'Country',
          poet.country ?? 'Unknown',
          isDark,
        ),
        _buildInfoCard(
          context,
          'Total Poems',
          poet.poemCount.toString(),
          isDark,
        ),
        _buildInfoCard(
          context,
          'Followers',
          _formatNumber(poet.followerCount),
          isDark,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFacts(BuildContext context, bool isDark, bool isUrdu) {
    return poet.facts!
        .map((fact) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 20, color: Colors.green),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      fact,
                      style: (isUrdu
                          ? AppTypography.getUrduTextTheme(context).bodyMedium
                          : Theme.of(context).textTheme.bodyMedium
                      )?.copyWith(
                            height: isUrdu ? 2.0 : 1.6,
                          ),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
