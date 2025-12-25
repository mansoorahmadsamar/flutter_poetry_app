import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/image_poetry/providers/image_template_providers.dart';
import 'package:flutter_poetry_app/features/image_poetry/widgets/template_card.dart';

class TemplateSelectionScreen extends ConsumerStatefulWidget {
  final String coupletId;

  const TemplateSelectionScreen({
    super.key,
    required this.coupletId,
  });

  @override
  ConsumerState<TemplateSelectionScreen> createState() =>
      _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState
    extends ConsumerState<TemplateSelectionScreen> {
  String? _selectedCategory;
  bool? _premiumFilter;

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(templatesProvider(
      TemplateParams(
        category: _selectedCategory,
        isPremium: _premiumFilter,
      ),
    ));

    final popularTemplatesAsync = ref.watch(popularTemplatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Template'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: CustomScrollView(
        slivers: [
          // Category filter chips
          SliverToBoxAdapter(
            child: _buildCategoryFilters(),
          ),

          // Premium/Free toggle
          SliverToBoxAdapter(
            child: _buildPremiumToggle(),
          ),

          // Popular templates section
          SliverToBoxAdapter(
            child: _buildPopularSection(popularTemplatesAsync),
          ),

          // All templates header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Text(
                'All Templates',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),

          // Templates grid
          templatesAsync.when(
            data: (paginatedResponse) {
              final templates = paginatedResponse.content;

              if (templates.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          'No templates found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_selectedCategory != null || _premiumFilter != null)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = null;
                                _premiumFilter = null;
                              });
                            },
                            child: const Text('Clear filters'),
                          ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.all(AppSpacing.md),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.6,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final template = templates[index];
                      return TemplateCard(
                        template: template,
                        onTap: () => _selectTemplate(template.publicId),
                      );
                    },
                    childCount: templates.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: _buildErrorState(error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    const categories = ['CLASSIC', 'MODERN', 'FLORAL', 'GEOMETRIC', 'MINIMAL', 'NATURE'];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _selectedCategory == null,
                onSelected: (selected) {
                  setState(() => _selectedCategory = null);
                },
              ),
              ...categories.map((category) {
                return FilterChip(
                  label: Text(_formatCategory(category)),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                    });
                  },
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumToggle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Text(
            'Template Type',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Spacer(),
          SegmentedButton<bool?>(
            segments: const [
              ButtonSegment(value: null, label: Text('All')),
              ButtonSegment(value: false, label: Text('Free')),
              ButtonSegment(value: true, label: Text('Premium')),
            ],
            selected: {_premiumFilter},
            onSelectionChanged: (Set<bool?> selected) {
              setState(() => _premiumFilter = selected.first);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSection(AsyncValue<List<dynamic>> popularAsync) {
    return popularAsync.when(
      data: (popularTemplates) {
        if (popularTemplates.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Popular Templates',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: popularTemplates.length,
                itemBuilder: (context, index) {
                  final template = popularTemplates[index];
                  return Container(
                    width: 150,
                    margin: EdgeInsets.only(
                      right: index < popularTemplates.length - 1
                          ? AppSpacing.md
                          : 0,
                    ),
                    child: TemplateCard(
                      template: template,
                      onTap: () => _selectTemplate(template.publicId),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            SizedBox(height: AppSpacing.md),
            const Text(
              'Failed to load templates',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(templatesProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCategory(String category) {
    return category[0] + category.substring(1).toLowerCase();
  }

  void _selectTemplate(String templateId) {
    context.push(
      '/image-poetry/generate/${widget.coupletId}',
      extra: {'templateId': templateId},
    );
  }
}
