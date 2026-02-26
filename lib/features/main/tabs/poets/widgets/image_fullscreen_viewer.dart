import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/image_poetry/providers/image_bookmark_providers.dart';
import '../models/poet_image_model.dart';

/// Engagement state for a single image
class _ImageEngagement {
  bool isLiked = false;
  bool isBookmarked = false;
  int likeCount = 0;
  int bookmarkCount = 0;
  int shareCount = 0;
  bool loaded = false;
}

class ImageFullscreenViewer extends ConsumerStatefulWidget {
  final List<PoetImageModel> images;
  final int initialIndex;

  const ImageFullscreenViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  ConsumerState<ImageFullscreenViewer> createState() =>
      _ImageFullscreenViewerState();
}

class _ImageFullscreenViewerState extends ConsumerState<ImageFullscreenViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showControls = true;
  final Map<String, _ImageEngagement> _engagementStates = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _loadImageStatus(widget.images[_currentIndex].publicId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  _ImageEngagement _getEngagement(String publicId) {
    return _engagementStates.putIfAbsent(publicId, () => _ImageEngagement());
  }

  Future<void> _loadImageStatus(String publicId) async {
    final engagement = _getEngagement(publicId);
    if (engagement.loaded) return;

    try {
      final status = await ref
          .read(imageBookmarkActionProvider.notifier)
          .getImageStatus(publicId);

      if (mounted) {
        setState(() {
          engagement.isLiked = status['isLiked'] as bool? ?? false;
          engagement.isBookmarked = status['isBookmarked'] as bool? ?? false;
          engagement.likeCount = status['likeCount'] as int? ?? 0;
          engagement.bookmarkCount = status['bookmarkCount'] as int? ?? 0;
          engagement.shareCount = status['shareCount'] as int? ?? 0;
          engagement.loaded = true;
        });
      }
    } catch (_) {
      // Silently fail — defaults are all false/0
    }
  }

  Future<void> _toggleLike() async {
    final image = widget.images[_currentIndex];
    final engagement = _getEngagement(image.publicId);

    try {
      final isLiked = await ref
          .read(imageBookmarkActionProvider.notifier)
          .toggleLike(image.publicId);

      if (mounted) {
        setState(() {
          engagement.isLiked = isLiked;
          engagement.likeCount += isLiked ? 1 : -1;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${engagement.isLiked ? 'unlike' : 'like'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleBookmark() async {
    final image = widget.images[_currentIndex];
    final engagement = _getEngagement(image.publicId);
    final currentLang = ref.read(selectedLanguageProvider);

    try {
      final isBookmarked = await ref
          .read(imageBookmarkActionProvider.notifier)
          .toggleBookmark(image.publicId, lang: currentLang);

      if (mounted) {
        setState(() {
          engagement.isBookmarked = isBookmarked;
          engagement.bookmarkCount += isBookmarked ? 1 : -1;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBookmarked ? 'Image bookmarked' : 'Bookmark removed',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to toggle bookmark'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareImage() async {
    final image = widget.images[_currentIndex];

    try {
      await Share.share(
        'Check out this image!\n\n${image.imageUrl}',
        subject: 'Poetry Image',
      );

      // Record share event after share sheet is dismissed
      ref
          .read(imageBookmarkActionProvider.notifier)
          .recordShare(image.publicId);

      if (mounted) {
        setState(() {
          _getEngagement(image.publicId).shareCount += 1;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _loadImageStatus(widget.images[index].publicId);
  }

  @override
  Widget build(BuildContext context) {
    final currentImage = widget.images[_currentIndex];
    final engagement = _getEngagement(currentImage.publicId);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image PageView
          GestureDetector(
            onTap: () {
              setState(() => _showControls = !_showControls);
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final image = widget.images[index];
                return InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: image.imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Top bar
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_showControls,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 26,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        if (currentImage.caption != null &&
                            currentImage.caption!.isNotEmpty &&
                            currentImage.caption != '-')
                          Expanded(
                            flex: 2,
                            child: Text(
                              currentImage.caption!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: Container(
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
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Like button
                          _buildActionButton(
                            icon: engagement.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            label: engagement.likeCount > 0
                                ? '${engagement.likeCount}'
                                : 'Like',
                            onTap: _toggleLike,
                            isActive: engagement.isLiked,
                            activeColor: Colors.redAccent,
                          ),
                          // Bookmark button
                          _buildActionButton(
                            icon: engagement.isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            label: engagement.bookmarkCount > 0
                                ? '${engagement.bookmarkCount}'
                                : 'Save',
                            onTap: _toggleBookmark,
                            isActive: engagement.isBookmarked,
                            activeColor: Colors.amber,
                          ),
                          // Share button
                          _buildActionButton(
                            icon: Icons.share_outlined,
                            label: engagement.shareCount > 0
                                ? '${engagement.shareCount}'
                                : 'Share',
                            onTap: _shareImage,
                          ),
                          // Page indicator
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_currentIndex + 1} / ${widget.images.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentImage.imageType,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    Color activeColor = Colors.amber,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: isActive ? activeColor : Colors.white,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? activeColor : Colors.white70,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
