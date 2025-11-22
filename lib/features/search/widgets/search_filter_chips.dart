import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/search/providers/search_providers.dart';

class SearchFilterChips extends ConsumerWidget {
  final VoidCallback? onFiltersChanged;

  const SearchFilterChips({
    super.key,
    this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(searchFiltersProvider);

    if (!filters.hasActiveFilters) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Filters',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              // Era filters
              ...filters.selectedEras.map(
                (era) => _FilterChip(
                  label: era,
                  onDeleted: () {
                    ref.read(searchFiltersProvider.notifier).toggleEra(era);
                    onFiltersChanged?.call();
                  },
                ),
              ),
              // Gender filters
              ...filters.selectedGenders.map(
                (gender) => _FilterChip(
                  label: gender,
                  onDeleted: () {
                    ref.read(searchFiltersProvider.notifier).toggleGender(gender);
                    onFiltersChanged?.call();
                  },
                ),
              ),
              // Featured filter
              if (filters.onlyFeatured)
                _FilterChip(
                  label: 'Featured',
                  onDeleted: () {
                    ref.read(searchFiltersProvider.notifier).setOnlyFeatured(false);
                    onFiltersChanged?.call();
                  },
                ),
              // Trending filter
              if (filters.onlyTrending)
                _FilterChip(
                  label: 'Trending',
                  onDeleted: () {
                    ref.read(searchFiltersProvider.notifier).setOnlyTrending(false);
                    onFiltersChanged?.call();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const _FilterChip({
    required this.label,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      deleteIcon: const Icon(
        Icons.close,
        size: 16,
        color: AppColors.primary,
      ),
      onDeleted: onDeleted,
      backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
      side: const BorderSide(
        color: AppColors.secondary,
        width: 1,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
    );
  }
}
