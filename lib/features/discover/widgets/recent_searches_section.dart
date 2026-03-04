import 'package:flutter/material.dart';

import '../../../core/design_system/app_colors.dart';

/// Section showing user's recent search queries
class RecentSearchesSection extends StatelessWidget {
  final List<String> searches;
  final bool isRtl;
  final Function(String) onSearchTap;
  final VoidCallback onClearAll;
  final Function(String) onRemove;

  const RecentSearchesSection({
    super.key,
    required this.searches,
    required this.isRtl,
    required this.onSearchTap,
    required this.onClearAll,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 20,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRtl ? 'حالیہ تلاش' : 'Recent Searches',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onClearAll,
                child: Text(
                  isRtl ? 'سب صاف کریں' : 'Clear All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: searches.take(10).map((query) {
              return _SearchChip(
                query: query,
                isRtl: isRtl,
                onTap: () => onSearchTap(query),
                onRemove: () => onRemove(query),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  final String query;
  final bool isRtl;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SearchChip({
    required this.query,
    required this.isRtl,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 4, 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(
                  query,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
