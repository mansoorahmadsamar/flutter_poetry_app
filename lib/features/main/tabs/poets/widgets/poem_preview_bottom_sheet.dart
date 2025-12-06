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

class PoemPreviewBottomSheet extends ConsumerStatefulWidget {
  final String poemPublicId;

  const PoemPreviewBottomSheet({
    super.key,
    required this.poemPublicId,
  });

  @override
  ConsumerState<PoemPreviewBottomSheet> createState() => _PoemPreviewBottomSheetState();
}

class _PoemPreviewBottomSheetState extends ConsumerState<PoemPreviewBottomSheet> {
  // Optimistic state for like and bookmark
  bool? _isLikedOptimistic;
  bool? _isBookmarkedOptimistic;

  @override
  Widget build(BuildContext context) {
    final poemAsync = ref.watch(poemDetailProvider(widget.poemPublicId));
    final isUrdu = ref.watch(selectedLanguageProvider) == 'ur';

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLg),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              poemAsync.when(
                data: (poem) => _buildHeader(context, ref, poem, isUrdu),
                loading: () => _buildLoadingHeader(),
                error: (_, __) => _buildErrorHeader(),
              ),

              Divider(),

              // Content
              Expanded(
                child: poemAsync.when(
                  data: (poem) => _buildContent(
                    context,
                    scrollController,
                    poem,
                    isUrdu,
                  ),
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (error, _) => _buildError(context, error),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    PoemModel poem,
    bool isUrdu,
  ) {
    final isLiked = _isLikedOptimistic ?? poem.isLikedByCurrentUser ?? false;
    final isBookmarked = _isBookmarkedOptimistic ?? poem.isBookmarkedByCurrentUser ?? false;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: LocalizedText(
              poem.getDisplayTitle(isUrdu ? 'ur' : 'en'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Like button
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : null,
                ),
                onPressed: () => _handleLikeToggle(poem),
              ),
              // Bookmark button
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? AppColors.primary : null,
                ),
                onPressed: () => _handleBookmarkToggle(poem),
              ),
              // Full screen button
              IconButton(
                icon: Icon(Icons.fullscreen),
                tooltip: 'Open Full Screen',
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/main/poems/${poem.publicId}');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleLikeToggle(PoemModel poem) async {
    final isLiked = _isLikedOptimistic ?? poem.isLikedByCurrentUser ?? false;

    // Optimistic update
    setState(() {
      _isLikedOptimistic = !isLiked;
    });

    try {
      final notifier = ref.read(likeActionProvider.notifier);
      final newIsLiked = await notifier.toggleLike(widget.poemPublicId);

      // Update optimistic state with server response and keep it permanently
      if (mounted) {
        setState(() {
          _isLikedOptimistic = newIsLiked;
        });
      }
    } catch (e) {
      // Revert optimistic update on error
      if (mounted) {
        setState(() {
          _isLikedOptimistic = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${isLiked ? 'unlike' : 'like'} poem'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleBookmarkToggle(PoemModel poem) async {
    final isBookmarked = _isBookmarkedOptimistic ?? poem.isBookmarkedByCurrentUser ?? false;

    // Optimistic update
    setState(() {
      _isBookmarkedOptimistic = !isBookmarked;
    });

    try {
      final notifier = ref.read(bookmarkActionProvider.notifier);
      final newIsBookmarked = await notifier.toggleBookmark(widget.poemPublicId);

      // Update optimistic state with server response and keep it permanently
      if (mounted) {
        setState(() {
          _isBookmarkedOptimistic = newIsBookmarked;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newIsBookmarked ? 'Added to bookmarks' : 'Removed from bookmarks'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Revert optimistic update on error
      if (mounted) {
        setState(() {
          _isBookmarkedOptimistic = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${isBookmarked ? 'remove' : 'add'} bookmark'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildLoadingHeader() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(child: Text('Loading...')),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildErrorHeader() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Text('Error loading poem'),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ScrollController scrollController,
    PoemModel poem,
    bool isUrdu,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full poem content with automatic RTL and font handling
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : AppColors.verseBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: LocalizedText(
              poem.getDisplayText(isUrdu ? 'ur' : 'en'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: AppSpacing.lg),

          // Metadata
          _buildMetadata(context, poem, isUrdu),
        ],
      ),
    );
  }

  Widget _buildMetadata(BuildContext context, PoemModel poem, bool isUrdu) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetaRow(
              context,
              Icons.category,
              poem.poetryTypeName ?? poem.poetryTypeUrduName ?? poem.poetryType,
            ),
            _buildMetaRow(
              context,
              Icons.person,
              poem.poetName,
            ),
            _buildMetaRow(
              context,
              Icons.language,
              poem.getContentForLanguage(isUrdu ? 'ur' : 'en')?.languageName ?? 'Urdu',
            ),
            if (poem.yearWritten != null)
              _buildMetaRow(
                context,
                Icons.calendar_today,
                '${poem.yearWritten}',
              ),
            _buildMetaRow(
              context,
              Icons.visibility,
              '${poem.viewCount} views',
            ),
            _buildMetaRow(
              context,
              Icons.favorite,
              '${poem.likeCount} likes',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          SizedBox(width: AppSpacing.sm),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
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
            SizedBox(height: AppSpacing.md),
            Text('Failed to load poem'),
            SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
