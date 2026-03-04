import 'package:flutter/material.dart';

import '../../../core/design_system/app_colors.dart';
import '../models/discover_bundle_model.dart';

/// Section showing trending search queries with tabs for daily/weekly
/// Jameel Noori Nastaleeq font for Urdu queries
class TrendingSection extends StatefulWidget {
  final TrendingSearches trending;
  final bool isRtl;
  final Function(String) onQueryTap;

  const TrendingSection({
    super.key,
    required this.trending,
    required this.isRtl,
    required this.onQueryTap,
  });

  @override
  State<TrendingSection> createState() => _TrendingSectionState();
}

class _TrendingSectionState extends State<TrendingSection> {
  bool _showDaily = true;

  @override
  Widget build(BuildContext context) {
    final queries = _showDaily ? widget.trending.daily : widget.trending.weekly;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (queries.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    size: 20,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.isRtl ? 'مقبول تلاش' : 'Trending Now',
                    style: TextStyle(
                      fontSize: widget.isRtl ? 18 : 16,
                      fontFamily: widget.isRtl ? 'Jameel Noori Nastaleeq' : null,
                      fontWeight: FontWeight.w600,
                      height: widget.isRtl ? 1.8 : 1.4,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              // Daily/Weekly toggle
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ToggleButton(
                      label: widget.isRtl ? 'آج' : 'Daily',
                      isSelected: _showDaily,
                      isRtl: widget.isRtl,
                      isDark: isDark,
                      onTap: () => setState(() => _showDaily = true),
                    ),
                    _ToggleButton(
                      label: widget.isRtl ? 'ہفتہ' : 'Weekly',
                      isSelected: !_showDaily,
                      isRtl: widget.isRtl,
                      isDark: isDark,
                      onTap: () => setState(() => _showDaily = false),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Trending chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: queries.take(10).map((query) {
              return _TrendingChip(
                query: query,
                isRtl: widget.isRtl,
                isDark: isDark,
                onTap: () => widget.onQueryTap(query.query),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isRtl;
  final bool isDark;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.isRtl,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isRtl ? 13 : 11,
            fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
            fontWeight: FontWeight.w500,
            height: isRtl ? 1.5 : 1.3,
            color: isSelected
                ? Colors.white
                : (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight),
          ),
        ),
      ),
    );
  }
}

class _TrendingChip extends StatelessWidget {
  final TrendingQuery query;
  final bool isRtl;
  final bool isDark;
  final VoidCallback onTap;

  const _TrendingChip({
    required this.query,
    required this.isRtl,
    required this.isDark,
    required this.onTap,
  });

  bool _isUrduText(String text) {
    final urduPattern = RegExp(r'[\u0600-\u06FF]');
    return urduPattern.hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final isUrduQuery = _isUrduText(query.query);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                AppColors.secondary.withValues(alpha: isDark ? 0.15 : 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (query.rank <= 3) ...[
                Icon(
                  Icons.trending_up,
                  size: 13,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 4),
              ],
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  query.query,
                  overflow: TextOverflow.ellipsis,
                  textDirection: isUrduQuery ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(
                    fontSize: isUrduQuery ? 14 : 13,
                    fontFamily: isUrduQuery ? 'Jameel Noori Nastaleeq' : null,
                    fontWeight: FontWeight.w500,
                    height: isUrduQuery ? 1.5 : 1.3,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
