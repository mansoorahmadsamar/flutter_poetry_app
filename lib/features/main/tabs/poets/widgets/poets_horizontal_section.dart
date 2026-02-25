import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/discover/widgets/section_header.dart';
import '../models/poet_model.dart';
import 'poet_horizontal_card.dart';

/// Horizontal poet discovery section.
///
/// Combines [SectionHeader] + horizontal [ListView] of [PoetHorizontalCard].
/// When [poets] is null, shows shimmer skeleton (loading).
/// When [poets] is empty, hides entirely.
class PoetsHorizontalSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final List<PoetModel>? poets;
  final int totalCount;
  final VoidCallback? onSeeAll;
  final Function(PoetModel) onPoetTap;

  const PoetsHorizontalSection({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    required this.poets,
    this.totalCount = 0,
    this.onSeeAll,
    required this.onPoetTap,
  });

  @override
  Widget build(BuildContext context) {
    // Hide section if loaded but empty
    if (poets != null && poets!.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          icon: icon,
          iconColor: iconColor,
          isRtl: false,
          itemCount: poets?.length ?? 0,
          totalCount: totalCount,
          onSeeMore: onSeeAll,
        ),
        SizedBox(
          height: 165,
          child: poets == null
              ? _buildSkeleton(context)
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: poets!.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return PoetHorizontalCard(
                      poet: poets![index],
                      onTap: () => onPoetTap(poets![index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2C2C2C) : AppColors.shimmerBase;

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (_, __) {
        return SizedBox(
          width: 120,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF262626) : const Color(0xFFFCFAF6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFEFE6DA),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Container(
                  height: 95,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(7, 6, 7, 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 70,
                        height: 9,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 45,
                        height: 7,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 7,
                            decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 28,
                            height: 7,
                            decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
