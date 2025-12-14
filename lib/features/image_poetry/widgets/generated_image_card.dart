import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/image_poetry/models/generated_image_model.dart';

class GeneratedImageCard extends StatelessWidget {
  final GeneratedImageModel image;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool showFavoriteIndicator;

  const GeneratedImageCard({
    super.key,
    required this.image,
    required this.onTap,
    this.onLongPress,
    this.showFavoriteIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            CachedNetworkImage(
              imageUrl: image.thumbnailUrl ?? image.imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: 600,
              memCacheHeight: 1000,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.broken_image,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),

            // Gradient overlay for text readability
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
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
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Template name or custom indicator
                    Text(
                      image.isCustom
                          ? 'Custom Background'
                          : image.templateName ?? 'Template',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (image.poetName != null) ...[
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        image.poetName!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    SizedBox(height: AppSpacing.xs),

                    // Engagement stats
                    Row(
                      children: [
                        const Icon(
                          Icons.remove_red_eye_outlined,
                          size: 12,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${image.viewCount}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.share_outlined,
                          size: 12,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${image.shareCount}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Custom badge
            if (image.isCustom)
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.brush,
                        size: 10,
                        color: Colors.white,
                      ),
                      SizedBox(width: 2),
                      Text(
                        'Custom',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Favorite indicator
            if (showFavoriteIndicator)
              Positioned(
                top: AppSpacing.sm,
                left: AppSpacing.sm,
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
