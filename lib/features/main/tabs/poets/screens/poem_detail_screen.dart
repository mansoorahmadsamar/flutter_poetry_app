import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import '../models/poem_model.dart';
import '../providers/poem_providers.dart';
import '../providers/poet_providers.dart';

class PoemDetailScreen extends ConsumerWidget {
  final String publicId;

  const PoemDetailScreen({
    super.key,
    required this.publicId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poemAsync = ref.watch(poemDetailProvider(publicId));
    final isUrdu = ref.watch(selectedLanguageProvider) == 'ur';

    return Scaffold(
      appBar: AppBar(
        title: poemAsync.maybeWhen(
          data: (poem) => Text(
            poem.getDisplayTitle(isUrdu ? 'ur' : 'en'),
            style: isUrdu
                ? TextStyle(
                    fontFamily: 'Jameel Noori Nastaleeq',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 2.0,
                  )
                : null,
          ),
          orElse: () => Text('Loading...'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {/* TODO: Share */},
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {/* TODO: More options */},
          ),
        ],
      ),
      body: poemAsync.when(
        data: (poem) => _buildContent(context, ref, poem, isUrdu),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(context, error),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    PoemModel poem,
    bool isUrdu,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Poet info card
          Card(
            child: InkWell(
              onTap: () => context.push('/main/poets/${poem.poetPublicId}'),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        poem.poetName,
                        style: isUrdu
                            ? TextStyle(
                                fontFamily: 'Jameel Noori Nastaleeq',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 2.0,
                              )
                            : Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // Full poem content with Jameel Noori font for Urdu
          Container(
            padding: EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : AppColors.verseBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Text(
              poem.getDisplayText(isUrdu ? 'ur' : 'en'),
              style: poem.isRTL(isUrdu ? 'ur' : 'en')
                  ? TextStyle(
                      fontFamily: 'Jameel Noori Nastaleeq',
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      height: 2.2,
                    )
                  : Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                      height: 1.8,
                    ),
              textAlign: TextAlign.center,
              textDirection: poem.isRTL(isUrdu ? 'ur' : 'en')
                  ? TextDirection.rtl
                  : TextDirection.ltr,
            ),
          ),

          SizedBox(height: AppSpacing.lg),

          // Interaction buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                icon: Icons.favorite_border,
                label: 'Like',
                count: poem.likeCount,
                onPressed: () {/* TODO */},
              ),
              _buildActionButton(
                context,
                icon: Icons.bookmark_border,
                label: 'Save',
                count: 0,
                onPressed: () {/* TODO */},
              ),
              _buildActionButton(
                context,
                icon: Icons.share,
                label: 'Share',
                onPressed: () {/* TODO */},
              ),
            ],
          ),

          SizedBox(height: AppSpacing.lg),

          // Tags section
          if (poem.tags.isNotEmpty) ...[
            _buildTagsSection(context, poem.tags),
            SizedBox(height: AppSpacing.lg),
          ],

          // Detailed metadata
          Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: AppSpacing.md),
                  _buildDetailRow(
                    context,
                    'Poetry Type',
                    poem.poetryTypeUrduName ?? poem.poetryType,
                  ),
                  _buildDetailRow(
                    context,
                    'Language',
                    poem.getContentForLanguage(isUrdu ? 'ur' : 'en')?.languageName ?? 'Urdu',
                  ),
                  if (poem.yearWritten != null)
                    _buildDetailRow(
                      context,
                      'Year Written',
                      '${poem.yearWritten}',
                    ),
                  if (poem.categoryName != null && poem.categoryName != '-')
                    _buildDetailRow(
                      context,
                      'Category',
                      poem.categoryName!,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context, List<TagModel> tags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            'Poet Tags',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.grey,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: tags.map((tag) => _buildTagChip(tag)).toList(),
        ),
      ],
    );
  }

  Widget _buildTagChip(TagModel tag) {
    final chipColor = tag.color != null
        ? _parseColor(tag.color!)
        : _generateColorForTag(tag.name);

    return Chip(
      label: Text(
        tag.name,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: chipColor,
      visualDensity: VisualDensity.compact,
    );
  }

  Color _parseColor(String colorString) {
    if (colorString.startsWith('#')) {
      return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
    }
    return Colors.blue;
  }

  Color _generateColorForTag(String tagName) {
    final hash = tagName.hashCode;
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.6, 0.5).toColor();
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    int? count,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 28),
          onPressed: onPressed,
        ),
        Text(
          count != null ? '$count' : label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: AppSpacing.lg),
            Text('Failed to load poem'),
            SizedBox(height: AppSpacing.md),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

}
