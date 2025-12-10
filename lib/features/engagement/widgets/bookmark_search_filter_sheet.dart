import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';

class BookmarkSearchFilterSheet extends StatefulWidget {
  final String? selectedPoetryType;
  final String selectedSortBy;
  final void Function(String? poetryType, String sortBy) onApply;

  const BookmarkSearchFilterSheet({
    super.key,
    this.selectedPoetryType,
    required this.selectedSortBy,
    required this.onApply,
  });

  @override
  State<BookmarkSearchFilterSheet> createState() =>
      _BookmarkSearchFilterSheetState();
}

class _BookmarkSearchFilterSheetState extends State<BookmarkSearchFilterSheet> {
  late String? _selectedPoetryType;
  late String _selectedSortBy;

  static const List<String> poetryTypes = [
    'GHAZAL',
    'NAZM',
    'RUBAI',
    'QASIDA',
    'MARSIYA',
    'FREE_VERSE',
  ];

  static const Map<String, String> poetryTypeNames = {
    'GHAZAL': 'غزل (Ghazal)',
    'NAZM': 'نظم (Nazm)',
    'RUBAI': 'رباعی (Rubai)',
    'QASIDA': 'قصیدہ (Qasida)',
    'MARSIYA': 'مرثیہ (Marsiya)',
    'FREE_VERSE': 'آزاد نظم (Free Verse)',
  };

  @override
  void initState() {
    super.initState();
    _selectedPoetryType = widget.selectedPoetryType;
    _selectedSortBy = widget.selectedSortBy;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter & Sort',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedPoetryType = null;
                        _selectedSortBy = 'createdAt';
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  // Poetry Type Section
                  Text(
                    'Poetry Type',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      ChoiceChip(
                        label: const Text('All Types'),
                        selected: _selectedPoetryType == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedPoetryType = null;
                          });
                        },
                      ),
                      ...poetryTypes.map((type) {
                        return ChoiceChip(
                          label: Text(poetryTypeNames[type] ?? type),
                          selected: _selectedPoetryType == type,
                          onSelected: (selected) {
                            setState(() {
                              _selectedPoetryType = selected ? type : null;
                            });
                          },
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Sort By Section
                  Text(
                    'Sort By',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  RadioListTile<String>(
                    title: const Text('Newest First'),
                    value: 'createdAt',
                    groupValue: _selectedSortBy,
                    onChanged: (value) {
                      setState(() {
                        _selectedSortBy = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Most Liked'),
                    value: 'likeCount',
                    groupValue: _selectedSortBy,
                    onChanged: (value) {
                      setState(() {
                        _selectedSortBy = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Most Viewed'),
                    value: 'viewCount',
                    groupValue: _selectedSortBy,
                    onChanged: (value) {
                      setState(() {
                        _selectedSortBy = value!;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Apply Button
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_selectedPoetryType, _selectedSortBy);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
