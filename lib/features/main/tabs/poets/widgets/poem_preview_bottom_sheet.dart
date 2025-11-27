import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/widgets/localized_text.dart';
import '../models/poem_model.dart';
import '../providers/poem_providers.dart';
import '../providers/poet_providers.dart';

class PoemPreviewBottomSheet extends ConsumerWidget {
  final String poemPublicId;

  const PoemPreviewBottomSheet({
    super.key,
    required this.poemPublicId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poemAsync = ref.watch(poemDetailProvider(poemPublicId));
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
              IconButton(
                icon: Icon(Icons.favorite_border),
                onPressed: () {/* TODO: Like */},
              ),
              IconButton(
                icon: Icon(Icons.bookmark_border),
                onPressed: () {/* TODO: Bookmark */},
              ),
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
              poem.poetryTypeUrduName ?? poem.poetryType,
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
