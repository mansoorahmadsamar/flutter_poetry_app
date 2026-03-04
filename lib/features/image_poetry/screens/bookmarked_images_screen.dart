import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/features/image_poetry/providers/image_bookmark_providers.dart';
import 'package:flutter_poetry_app/features/image_poetry/models/generated_image_model.dart';

/// Screen displaying user's bookmarked poetry images
class BookmarkedImagesScreen extends ConsumerStatefulWidget {
  const BookmarkedImagesScreen({super.key});

  @override
  ConsumerState<BookmarkedImagesScreen> createState() =>
      _BookmarkedImagesScreenState();
}

class _BookmarkedImagesScreenState
    extends ConsumerState<BookmarkedImagesScreen> {
  final ScrollController _scrollController = ScrollController();

  // State
  int _currentPage = 0;
  List<GeneratedImageModel> _allBookmarks = [];
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _languageFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    final params = ImageBookmarksParams(
      page: _currentPage,
      lang: _languageFilter,
    );

    final asyncValue = await ref.read(imageBookmarksProvider(params).future);

    setState(() {
      _allBookmarks.addAll(asyncValue.content);
      _hasMoreData = !asyncValue.last;
      _isLoadingMore = false;
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _currentPage = 0;
      _allBookmarks.clear();
      _hasMoreData = true;
    });
    ref.invalidate(imageBookmarksProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final params = ImageBookmarksParams(
      page: _currentPage,
      lang: _languageFilter,
    );

    final bookmarksAsync = ref.watch(imageBookmarksProvider(params));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.secondary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              elevation: 0,
              title: Text(
                'Bookmarked Images',
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // Bookmarked Images Grid
            bookmarksAsync.when(
              data: (paginatedData) {
                // Combine previously loaded bookmarks with new data
                if (_currentPage == 0) {
                  _allBookmarks = paginatedData.content;
                  _hasMoreData = !paginatedData.last;
                }

                if (_allBookmarks.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 64,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.3),
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'No bookmarked images yet',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : Colors.black.withValues(alpha: 0.6),
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            'Bookmark images to see them here',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.4)
                                  : Colors.black.withValues(alpha: 0.4),
                            ),
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
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= _allBookmarks.length) {
                          return const SizedBox.shrink();
                        }

                        final image = _allBookmarks[index];
                        return _BookmarkedImageCard(
                          image: image,
                          isDark: isDark,
                        );
                      },
                      childCount: _allBookmarks.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.withValues(alpha: 0.7),
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Failed to load bookmarks',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      ElevatedButton(
                        onPressed: _onRefresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Loading indicator for infinite scroll
            if (_isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkedImageCard extends StatelessWidget {
  final GeneratedImageModel image;
  final bool isDark;

  const _BookmarkedImageCard({
    required this.image,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to image detail screen
        // context.push('/image-detail/${image.publicId}');
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              CachedNetworkImage(
                imageUrl: image.thumbnailUrl ?? image.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
                  child: const Icon(Icons.error_outline),
                ),
              ),

              // Bookmark indicator
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bookmark,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),

              // Language badge
              if (image.languageCode.isNotEmpty)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getLanguageLabel(image.languageCode),
                      style: GoogleFonts.roboto(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLanguageLabel(String code) {
    switch (code) {
      case 'ur':
        return 'اردو';
      case 'en':
        return 'EN';
      case 'hi':
        return 'हिं';
      default:
        return code.toUpperCase();
    }
  }
}
