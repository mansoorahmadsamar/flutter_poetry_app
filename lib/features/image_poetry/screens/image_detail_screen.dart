import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/image_poetry/widgets/image_viewer.dart';
import 'package:flutter_poetry_app/features/image_poetry/widgets/collection_dialog.dart';
import 'package:flutter_poetry_app/features/image_poetry/providers/image_collection_providers.dart';
import 'package:flutter_poetry_app/features/image_poetry/providers/image_bookmark_providers.dart';

class ImageDetailScreen extends ConsumerStatefulWidget {
  final String imageId;

  const ImageDetailScreen({
    super.key,
    required this.imageId,
  });

  @override
  ConsumerState<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends ConsumerState<ImageDetailScreen> {
  bool _showMetadata = false;
  bool? _isBookmarked;

  @override
  void initState() {
    super.initState();
    _loadBookmarkStatus();
  }

  Future<void> _loadBookmarkStatus() async {
    final isBookmarked = await ref
        .read(imageBookmarkActionProvider.notifier)
        .isBookmarked(widget.imageId);

    if (mounted) {
      setState(() {
        _isBookmarked = isBookmarked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // For now, we'll fetch from saved images
    // In a real app, you'd have a separate provider for a single image
    final params = const SavedImagesParams(page: 1, size: 100);
    final imagesAsync = ref.watch(savedImagesProvider(params));

    return imagesAsync.when(
      data: (paginatedResponse) {
        final image = paginatedResponse.content.firstWhere(
          (img) => img.publicId == widget.imageId,
          orElse: () => paginatedResponse.content.first,
        );

        return Scaffold(
          body: Stack(
            children: [
              // Full-screen image
              ImageViewer(
                imageUrl: image.imageUrl,
                heroTag: 'image_${image.publicId}',
              ),

              // Metadata panel (slide up from bottom)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _showMetadata ? 300 : 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Handle
                      GestureDetector(
                        onTap: () {
                          setState(() => _showMetadata = !_showMetadata);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),

                      // Action buttons (always visible)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              icon: _isBookmarked == true
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              label: 'Bookmark',
                              onTap: () => _toggleBookmark(image.publicId),
                              isActive: _isBookmarked == true,
                            ),
                            _buildActionButton(
                              icon: Icons.share,
                              label: 'Share',
                              onTap: () => _shareImage(image.imageUrl),
                            ),
                            _buildActionButton(
                              icon: Icons.collections_bookmark,
                              label: 'Save',
                              onTap: () => _showCollectionDialog(image.publicId),
                            ),
                            _buildActionButton(
                              icon: Icons.favorite_border,
                              label: 'Favorite',
                              onTap: () => _toggleFavorite(image.publicId),
                            ),
                          ],
                        ),
                      ),

                      // Metadata (shown when expanded)
                      if (_showMetadata)
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: _buildMetadata(image),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.white,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Failed to load image',
                style: const TextStyle(color: Colors.white),
              ),
              SizedBox(height: AppSpacing.sm),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.primary : Colors.grey[700],
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? AppColors.primary : Colors.grey[700],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadata(dynamic image) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image Details',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.md),

        // Template or custom
        _buildMetadataRow(
          'Type',
          image.isCustom ? 'Custom Background' : image.templateName ?? 'Template',
        ),

        if (image.poetName != null)
          _buildMetadataRow('Poet', image.poetName!),

        _buildMetadataRow('Language', _getLanguageName(image.languageCode)),

        // Dimensions
        if (image.width != null && image.height != null)
          _buildMetadataRow(
            'Dimensions',
            '${image.width} × ${image.height} px',
          ),

        // File size
        if (image.fileSizeBytes != null)
          _buildMetadataRow(
            'Size',
            _formatFileSize(image.fileSizeBytes!),
          ),

        _buildMetadataRow('Format', image.format),

        SizedBox(height: AppSpacing.md),

        // Engagement stats
        Text(
          'Engagement',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.sm),

        Row(
          children: [
            _buildStatChip(
              Icons.remove_red_eye,
              '${image.viewCount} views',
            ),
            SizedBox(width: AppSpacing.sm),
            _buildStatChip(
              Icons.share,
              '${image.shareCount} shares',
            ),
          ],
        ),

        if (image.createdAt != null) ...[
          SizedBox(height: AppSpacing.md),
          Text(
            'Created ${_formatDate(image.createdAt!)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ur':
        return 'Urdu';
      case 'en':
        return 'English';
      case 'hi':
        return 'Hindi';
      default:
        return code.toUpperCase();
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _downloadImage(String imageUrl) async {
    // TODO: Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download functionality coming soon')),
    );
  }

  Future<void> _shareImage(String imageUrl) async {
    try {
      await Share.share(
        'Check out this beautiful poetry image!\n\n$imageUrl',
        subject: 'Poetry Image',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    }
  }

  Future<void> _showCollectionDialog(String imageId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CollectionDialog(imageId: imageId),
    );

    if (result == true && mounted) {
      // Refresh if saved successfully
      ref.invalidate(savedImagesProvider);
    }
  }

  Future<void> _toggleFavorite(String imageId) async {
    try {
      final isFavorite = await ref
          .read(collectionActionProvider.notifier)
          .toggleFavorite(imageId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFavorite ? 'Added to favorites' : 'Removed from favorites'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleBookmark(String imageId) async {
    final currentLang = ref.read(selectedLanguageProvider);

    try {
      final isBookmarked = await ref
          .read(imageBookmarkActionProvider.notifier)
          .toggleBookmark(imageId, lang: currentLang);

      if (mounted) {
        setState(() {
          _isBookmarked = isBookmarked;
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
            content: Text('Failed to toggle bookmark: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
