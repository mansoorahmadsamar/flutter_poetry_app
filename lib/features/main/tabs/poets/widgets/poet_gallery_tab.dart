import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/poet_providers.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';

class PoetGalleryTab extends ConsumerWidget {
  final String publicId;

  const PoetGalleryTab({super.key, required this.publicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gallery = ref.watch(poetGalleryProvider(publicId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return gallery.when(
      data: (images) {
        if (images.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text('No images available'),
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(AppSpacing.md),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            final image = images[index];
            return GestureDetector(
              onTap: () => _showImageFullscreen(context, image.imageUrl),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: image.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDark ? Colors.grey[800] : Colors.grey[300],
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDark ? Colors.grey[800] : Colors.grey[300],
                        child: Icon(Icons.broken_image),
                      ),
                    ),
                    if (image.isProfileImage)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Text('Failed to load gallery'),
        ),
      ),
    );
  }

  void _showImageFullscreen(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) =>
                Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                Center(child: Icon(Icons.error)),
          ),
        ),
      ),
    );
  }
}
