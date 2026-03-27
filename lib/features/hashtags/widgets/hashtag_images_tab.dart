import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../services/hashtag_service.dart';

class HashtagImagesTab extends ConsumerStatefulWidget {
  final String slug;

  const HashtagImagesTab({required this.slug, super.key});

  @override
  ConsumerState<HashtagImagesTab> createState() => _HashtagImagesTabState();
}

class _HashtagImagesTabState extends ConsumerState<HashtagImagesTab>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _images = [];
  int _currentPage = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPage(0);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.85) {
      _loadMore();
    }
  }

  Future<void> _loadPage(int page) async {
    try {
      final service = ref.read(hashtagServiceProvider);
      final result = await service.getImagesByHashtag(
        widget.slug,
        page: page,
        size: 20,
      );

      if (!mounted) return;
      setState(() {
        _images.addAll(result.content);
        _currentPage = page;
        _hasMore = !result.last;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    await _loadPage(_currentPage + 1);
  }

  Future<void> _refresh() async {
    setState(() {
      _images.clear();
      _currentPage = 0;
      _hasMore = true;
      _isLoading = true;
      _error = null;
    });
    await _loadPage(0);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = ref.watch(selectedLanguageProvider) == 'ur';

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isRtl ? 'لوڈ نہیں ہو سکا' : 'Failed to load',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: _refresh, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_images.isEmpty) {
      return Center(
        child: Text(
          isRtl ? 'کوئی تصاویر نہیں ملیں' : 'No images found',
          style: TextStyle(
            fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
            fontSize: isRtl ? 16 : 14,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primary,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.85,
        ),
        itemCount: _images.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _images.length) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          final image = _images[index];
          return _ImageGridTile(
            imageData: image,
            isDark: isDark,
          );
        },
      ),
    );
  }
}

class _ImageGridTile extends StatelessWidget {
  final Map<String, dynamic> imageData;
  final bool isDark;

  const _ImageGridTile({
    required this.imageData,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        imageData['thumbnailUrl'] as String? ?? imageData['imageUrl'] as String? ?? '';
    final poetName = imageData['poetName'] as String? ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: 300,
              placeholder: (_, __) => Container(
                color: isDark ? AppColors.surfaceDark : AppColors.shimmerBase,
              ),
              errorWidget: (_, __, ___) => Container(
                color: isDark ? AppColors.surfaceDark : AppColors.shimmerBase,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.textDisabledLight,
                ),
              ),
            )
          else
            Container(
              color: isDark ? AppColors.surfaceDark : AppColors.shimmerBase,
              child: Icon(
                Icons.image_outlined,
                color: AppColors.textDisabledLight,
                size: 40,
              ),
            ),
          // Gradient overlay with poet name
          if (poetName.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  poetName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
