import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import '../providers/poet_providers.dart';

class PoetPoetryTab extends ConsumerStatefulWidget {
  final String publicId;

  const PoetPoetryTab({super.key, required this.publicId});

  @override
  ConsumerState<PoetPoetryTab> createState() => _PoetPoetryTabState();
}

class _PoetPoetryTabState extends ConsumerState<PoetPoetryTab> {
  late Future<List<PoemItem>> _poemsFuture;
  String _selectedForm = 'ALL'; // ALL, GHAZAL, NAZAM

  @override
  void initState() {
    super.initState();
    _loadPoems();
  }

  void _loadPoems() {
    _poemsFuture = _fetchPoems();
  }

  Future<List<PoemItem>> _fetchPoems() async {
    try {
      final dioClient = ref.read(dioClientProvider);
      final response = await dioClient.dio.get(
        '/api/poems/poet/${widget.publicId}',
        queryParameters: {
          'page': 0,
          'size': 100,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data as Map<String, dynamic>;
        final content = data['content'] as List<dynamic>? ?? [];
        return content
            .map((item) => PoemItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error loading poems: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedLanguage = ref.watch(selectedLanguageProvider);
    final isUrdu = selectedLanguage == 'ur';

    return Column(
      children: [
        // Form Filter
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFormChip('ALL', 'All'),
                      SizedBox(width: AppSpacing.sm),
                      _buildFormChip('GHAZAL', 'Ghazals'),
                      SizedBox(width: AppSpacing.sm),
                      _buildFormChip('NAZAM', 'Nazams'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Poems List
        Expanded(
          child: FutureBuilder<List<PoemItem>>(
            future: _poemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Text('Error loading poems'),
                  ),
                );
              }

              final poems = snapshot.data ?? [];
              final filteredPoems = _selectedForm == 'ALL'
                  ? poems
                  : poems
                      .where((p) => p.form.toUpperCase() == _selectedForm)
                      .toList();

              if (filteredPoems.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Text('No poems found'),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(AppSpacing.md),
                itemCount: filteredPoems.length,
                itemBuilder: (context, index) {
                  final poem = filteredPoems[index];
                  return _buildPoemCard(context, poem, isDark, isUrdu);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFormChip(String value, String label) {
    final isSelected = _selectedForm == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedForm = selected ? value : 'ALL';
        });
      },
    );
  }

  Widget _buildPoemCard(
      BuildContext context, PoemItem poem, bool isDark, bool isUrdu) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () => context.push('/poems/${poem.publicId}'),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                poem.title,
                style: (isUrdu
                    ? AppTypography.getUrduTextTheme(context).titleMedium
                    : Theme.of(context).textTheme.titleMedium
                )?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: AppSpacing.sm),
              // Content Preview
              Text(
                poem.content,
                style: (isUrdu
                    ? AppTypography.urduVerseStyle
                    : Theme.of(context).textTheme.bodyMedium
                )?.copyWith(
                      height: isUrdu ? 2.2 : 1.6,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppSpacing.md),
              // Meta
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.label, size: 14, color: Colors.grey),
                      SizedBox(width: 6),
                      Text(
                        _getFormLabel(poem.form),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(width: AppSpacing.md),
                      Icon(Icons.language, size: 14, color: Colors.grey),
                      SizedBox(width: 6),
                      Text(
                        poem.language?.toUpperCase() ?? 'UR',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        '${poem.likeCount}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(width: AppSpacing.md),
                      Icon(Icons.visibility, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        _formatNumber(poem.viewCount),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormLabel(String? form) {
    switch (form?.toUpperCase()) {
      case 'GHAZAL':
        return 'Ghazal';
      case 'NAZAM':
        return 'Nazam';
      case 'RUBAAI':
        return 'Rubaai';
      default:
        return form ?? 'Poetry';
    }
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

class PoemItem {
  final String publicId;
  final String title;
  final String content;
  final String form;
  final String? language;
  final int likeCount;
  final int viewCount;

  PoemItem({
    required this.publicId,
    required this.title,
    required this.content,
    required this.form,
    this.language,
    required this.likeCount,
    required this.viewCount,
  });

  factory PoemItem.fromJson(Map<String, dynamic> json) {
    return PoemItem(
      publicId: json['publicId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      form: json['form'] ?? '',
      language: json['language'],
      likeCount: json['likeCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
    );
  }
}
