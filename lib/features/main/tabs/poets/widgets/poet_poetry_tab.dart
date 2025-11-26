import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import '../models/poem_model.dart';
import '../providers/poem_providers.dart';
import 'poem_card.dart';
import 'poetry_section_header.dart';
import 'poem_preview_bottom_sheet.dart';

class PoetPoetryTab extends ConsumerStatefulWidget {
  final String publicId;

  const PoetPoetryTab({super.key, required this.publicId});

  @override
  ConsumerState<PoetPoetryTab> createState() => _PoetPoetryTabState();
}

class _PoetPoetryTabState extends ConsumerState<PoetPoetryTab> {
  // Track expanded sections (default all expanded)
  final Map<String, bool> _expandedSections = {};

  // Poetry types to fetch
  final List<String> _poetryTypes = [
    'GHAZAL',
    'NAZAM',
    'VERSE',
    'RUBAI',
    'AZAD_NAZAM',
  ];

  // Store loaded poems per type
  final Map<String, List<PoemModel>> _poemsByType = {};

  @override
  void initState() {
    super.initState();
    // Initialize all sections as expanded
    for (final type in _poetryTypes) {
      _expandedSections[type] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: _poetryTypes.length,
      itemBuilder: (context, index) {
        final poetryType = _poetryTypes[index];
        return _buildPoetryTypeSection(poetryType);
      },
    );
  }

  Widget _buildPoetryTypeSection(String poetryType) {
    // Get current page for this poetry type
    final pagesMap = ref.watch(poemPagesProvider(widget.publicId));
    final currentPage = pagesMap[poetryType] ?? 0;

    // Fetch poems for this type and page
    final poemsAsync = ref.watch(poetPoemsProvider((
      poetPublicId: widget.publicId,
      poetryType: poetryType,
      page: currentPage,
    )));

    return poemsAsync.when(
      data: (response) {
        // Update cached poems
        if (currentPage == 0) {
          _poemsByType[poetryType] = response.content;
        } else if (_poemsByType[poetryType] != null) {
          // Add new poems to existing list, avoiding duplicates
          final existingIds = _poemsByType[poetryType]!
              .map((p) => p.publicId)
              .toSet();
          final newPoems = response.content
              .where((p) => !existingIds.contains(p.publicId))
              .toList();
          _poemsByType[poetryType]!.addAll(newPoems);
        } else {
          _poemsByType[poetryType] = response.content;
        }

        final poems = _poemsByType[poetryType] ?? [];
        final isExpanded = _expandedSections[poetryType] ?? true;
        final hasMore = !response.last;

        // Don't show section if no poems
        if (response.totalElements == 0) {
          return SizedBox.shrink();
        }

        return Column(
          children: [
            // Section header
            PoetrySectionHeader(
              poetryType: poetryType,
              count: response.totalElements,
              isExpanded: isExpanded,
              onToggle: () => _toggleSection(poetryType),
            ),

            // Section content
            if (isExpanded) ...[
              ...poems.map((poem) => PoemCard(
                poem: poem,
                onTap: () => _showPoemBottomSheet(context, poem.publicId),
              )),

              // Load More button
              if (hasMore)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: OutlinedButton.icon(
                    onPressed: () => _loadMorePoems(poetryType),
                    icon: Icon(Icons.expand_more),
                    label: Text('Load More ${_getTypeLabel(poetryType)}'),
                  ),
                ),
            ],

            SizedBox(height: AppSpacing.lg),
          ],
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Card(
          color: Colors.red[50],
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Error loading $poetryType poems',
                  style: TextStyle(color: Colors.red[900]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleSection(String poetryType) {
    setState(() {
      _expandedSections[poetryType] = !(_expandedSections[poetryType] ?? true);
    });
  }

  void _loadMorePoems(String poetryType) {
    final pagesMap = ref.read(poemPagesProvider(widget.publicId));
    final currentPage = pagesMap[poetryType] ?? 0;

    // Update the page number
    ref.read(poemPagesProvider(widget.publicId).notifier).state = {
      ...pagesMap,
      poetryType: currentPage + 1,
    };
  }

  void _showPoemBottomSheet(BuildContext context, String poemPublicId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PoemPreviewBottomSheet(poemPublicId: poemPublicId),
    );
  }

  String _getTypeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'GHAZAL': return 'Ghazals';
      case 'NAZAM': return 'Nazams';
      case 'VERSE': return 'Verses';
      case 'RUBAI': return 'Rubais';
      case 'AZAD_NAZAM': return 'Azad Nazams';
      default: return type;
    }
  }
}
