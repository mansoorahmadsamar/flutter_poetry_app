import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/widgets/localized_text.dart';
import '../models/poem_model.dart';
import '../providers/poem_providers.dart';
import '../providers/poet_providers.dart';
import 'package:flutter_poetry_app/features/engagement/providers/like_providers.dart';
import 'package:flutter_poetry_app/features/engagement/providers/bookmark_providers.dart';

class PoemDetailScreen extends ConsumerStatefulWidget {
  final String publicId;

  const PoemDetailScreen({
    super.key,
    required this.publicId,
  });

  @override
  ConsumerState<PoemDetailScreen> createState() => _PoemDetailScreenState();
}

class _PoemDetailScreenState extends ConsumerState<PoemDetailScreen> {
  // Optimistic state for like and bookmark
  bool? _isLikedOptimistic;
  bool? _isBookmarkedOptimistic;
  int? _likeCountOptimistic;

  @override
  Widget build(BuildContext context) {
    final poemAsync = ref.watch(poemDetailProvider(widget.publicId));
    final isUrdu = ref.watch(selectedLanguageProvider) == 'ur';

    return Scaffold(
      appBar: AppBar(
        title: poemAsync.maybeWhen(
          data: (poem) => LocalizedText(
            poem.getDisplayTitle(isUrdu ? 'ur' : 'en'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
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
                      child: LocalizedText(
                        poem.poetName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // Full poem content with automatic RTL and font handling
          Container(
            padding: EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : AppColors.verseBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: LocalizedText(
              poem.getDisplayText(isUrdu ? 'ur' : 'en'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: AppSpacing.lg),

          // Interaction buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLikeButton(context, ref, poem),
              _buildBookmarkButton(context, ref, poem),
              _buildActionButton(
                context,
                icon: Icons.share,
                label: 'Share',
                onPressed: () {
                  // TODO: Implement share functionality in Phase 2
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Share feature coming soon!')),
                  );
                },
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
                    poem.poetryTypeName ?? poem.poetryTypeUrduName ?? poem.poetryType,
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

  Widget _buildLikeButton(BuildContext context, WidgetRef ref, PoemModel poem) {
    final isLiked = _isLikedOptimistic ?? poem.isLikedByCurrentUser ?? false;
    final likeCount = _likeCountOptimistic ?? poem.likeCount;

    return Column(
      children: [
        IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            size: 28,
            color: isLiked ? Colors.red : null,
          ),
          onPressed: () async {
            // Optimistic update
            setState(() {
              _isLikedOptimistic = !isLiked;
              _likeCountOptimistic = isLiked ? likeCount - 1 : likeCount + 1;
            });

            try {
              final notifier = ref.read(likeActionProvider.notifier);
              await notifier.toggleLike(widget.publicId);

              // Invalidate poem detail to get updated data from server
              ref.invalidate(poemDetailProvider(widget.publicId));

              // Clear optimistic state
              setState(() {
                _isLikedOptimistic = null;
                _likeCountOptimistic = null;
              });
            } catch (e) {
              // Revert optimistic update on error
              setState(() {
                _isLikedOptimistic = null;
                _likeCountOptimistic = null;
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to ${isLiked ? 'unlike' : 'like'} poem'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
        Text(
          '$likeCount',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildBookmarkButton(BuildContext context, WidgetRef ref, PoemModel poem) {
    final isBookmarked = _isBookmarkedOptimistic ?? poem.isBookmarkedByCurrentUser ?? false;

    return Column(
      children: [
        IconButton(
          icon: Icon(
            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            size: 28,
            color: isBookmarked ? AppColors.primary : null,
          ),
          onPressed: () async {
            // Optimistic update
            setState(() {
              _isBookmarkedOptimistic = !isBookmarked;
            });

            try {
              final notifier = ref.read(bookmarkActionProvider.notifier);
              await notifier.toggleBookmark(widget.publicId);

              // Invalidate poem detail to get updated data from server
              ref.invalidate(poemDetailProvider(widget.publicId));

              // Clear optimistic state
              setState(() {
                _isBookmarkedOptimistic = null;
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isBookmarked ? 'Removed from bookmarks' : 'Added to bookmarks'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              // Revert optimistic update on error
              setState(() {
                _isBookmarkedOptimistic = null;
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to ${isBookmarked ? 'remove' : 'add'} bookmark'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
        Text(
          'Save',
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
