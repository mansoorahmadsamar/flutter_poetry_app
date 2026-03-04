import 'package:flutter/material.dart';

import '../../../core/design_system/app_colors.dart';
import '../models/discover_bundle_model.dart';

/// Trending searches section with Daily/Weekly toggle, staggered chip animation,
/// and upward arrow indicators for top-ranked queries.
class TrendingChips extends StatefulWidget {
  final TrendingSearches trending;
  final bool isRtl;
  final Function(String) onQueryTap;

  const TrendingChips({
    super.key,
    required this.trending,
    required this.isRtl,
    required this.onQueryTap,
  });

  @override
  State<TrendingChips> createState() => _TrendingChipsState();
}

class _TrendingChipsState extends State<TrendingChips>
    with SingleTickerProviderStateMixin {
  bool _showDaily = true;
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  void _togglePeriod(bool daily) {
    if (_showDaily == daily) return;
    setState(() => _showDaily = daily);
    _staggerController.reset();
    _staggerController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final queries =
        _showDaily ? widget.trending.daily : widget.trending.weekly;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (queries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with toggle
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 0),
          child: Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 20,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.isRtl ? 'مقبول تلاش' : 'Trending Now',
                  style: TextStyle(
                    fontFamily:
                        widget.isRtl ? 'Jameel Noori Nastaleeq' : null,
                    fontSize: widget.isRtl ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    height: widget.isRtl ? 1.8 : 1.4,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              // Toggle
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
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
                      onTap: () => _togglePeriod(true),
                    ),
                    _ToggleButton(
                      label: widget.isRtl ? 'ہفتہ' : 'Weekly',
                      isSelected: !_showDaily,
                      isRtl: widget.isRtl,
                      isDark: isDark,
                      onTap: () => _togglePeriod(false),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Chips with staggered animation
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
          child: AnimatedBuilder(
            animation: _staggerController,
            builder: (context, _) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  queries.take(4).length,
                  (index) {
                    final delay = index * 0.15;
                    final end = (delay + 0.5).clamp(0.0, 1.0);
                    final opacity = Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _staggerController,
                        curve: Interval(delay, end, curve: Curves.easeOut),
                      ),
                    );
                    final slide = Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _staggerController,
                        curve: Interval(delay, end, curve: Curves.easeOut),
                      ),
                    );

                    return FadeTransition(
                      opacity: opacity,
                      child: SlideTransition(
                        position: slide,
                        child: _TrendingChip(
                          query: queries[index],
                          rank: index + 1,
                          isRtl: widget.isRtl,
                          isDark: isDark,
                          onTap: () =>
                              widget.onQueryTap(queries[index].query),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
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
  final int rank;
  final bool isRtl;
  final bool isDark;
  final VoidCallback onTap;

  const _TrendingChip({
    required this.query,
    required this.rank,
    required this.isRtl,
    required this.isDark,
    required this.onTap,
  });

  bool _isUrduText(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final isUrdu = _isUrduText(query.query);
    final isTopRank = rank <= 3;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                AppColors.secondary.withValues(alpha: isDark ? 0.15 : 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rank badge
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isTopRank
                      ? AppColors.warning.withValues(alpha: 0.2)
                      : AppColors.textSecondaryLight.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isTopRank
                          ? AppColors.warning
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  query.query,
                  overflow: TextOverflow.ellipsis,
                  textDirection:
                      isUrdu ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(
                    fontSize: isUrdu ? 14 : 13,
                    fontFamily:
                        isUrdu ? 'Jameel Noori Nastaleeq' : null,
                    fontWeight: FontWeight.w500,
                    height: isUrdu ? 1.5 : 1.3,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.primary,
                  ),
                ),
              ),
              // Upward arrow for top 3 ranks
              if (isTopRank) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.north_rounded,
                  size: 12,
                  color: AppColors.success,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
