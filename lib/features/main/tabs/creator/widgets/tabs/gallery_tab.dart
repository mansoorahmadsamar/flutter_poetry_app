import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import '../../models/creator_image_model.dart';
import '../../providers/creator_providers.dart';

/// 3-column gallery grid. Profile image gets a gold ring + "PROFILE" tag.
/// Last cell is the dashed-gold "+ ADD" upload prompt.
class GalleryTab extends ConsumerWidget {
  const GalleryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(creatorImagesProvider(null));
    return imagesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Could not load gallery: $e',
              style: SukhanText.italic(
                size: 12,
                color: AppColors.error,
              )),
        ),
      ),
      data: (images) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
          children: [
            Row(
              children: [
                Text('${images.length} IMAGES',
                    style: SukhanText.eyebrow(color: AppColors.secondary)),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => _uploadImage(context, ref),
                  icon: const Icon(Icons.add, size: 12),
                  label: const Text('Upload'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: const StadiumBorder(),
                    textStyle: SukhanText.sans(
                      size: 11,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: images.length + 1,
              itemBuilder: (ctx, i) {
                if (i == images.length) {
                  return _AddPlaceholder(
                    onTap: () => _uploadImage(ctx, ref),
                  );
                }
                final img = images[i];
                return _GalleryCell(
                  image: img,
                  onLongPress: () => _showImageActions(ctx, ref, img),
                );
              },
            ),
            if (images.isEmpty) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '"تصویر بھی ایک نظم ہے"',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: SukhanText.nastaleeq(
                    size: 14,
                    color: AppColors.primary,
                    height: 1.9,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _uploadImage(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dividerLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pick from gallery'),
              onTap: () => Navigator.of(sheetCtx).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(sheetCtx).pop(ImageSource.camera),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 90,
    );
    if (picked == null) return;
    try {
      await ref.read(creatorServiceProvider).uploadImage(filePath: picked.path);
      ref.invalidate(creatorImagesProvider(null));
      messenger.showSnackBar(const SnackBar(content: Text('Image uploaded')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  Future<void> _showImageActions(
    BuildContext context,
    WidgetRef ref,
    CreatorImage img,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dividerLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (!img.isProfileImage)
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text('Set as profile picture'),
                onTap: () => Navigator.of(sheetCtx).pop('profile'),
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Delete', style: TextStyle(color: AppColors.error)),
              onTap: () => Navigator.of(sheetCtx).pop('delete'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (action == 'profile') {
      try {
        await ref
            .read(creatorServiceProvider)
            .updateImage(img.publicId, {'isProfileImage': true});
        ref.invalidate(creatorImagesProvider(null));
        ref.invalidate(ownedPoetProvider);
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    } else if (action == 'delete') {
      try {
        await ref.read(creatorServiceProvider).deleteImage(img.publicId);
        ref.invalidate(creatorImagesProvider(null));
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }
}

class _GalleryCell extends StatelessWidget {
  const _GalleryCell({required this.image, required this.onLongPress});

  final CreatorImage image;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryDark, AppColors.primaryLight],
                ),
                border: Border.all(
                  color: image.isProfileImage
                      ? AppColors.secondary
                      : AppColors.dividerLight,
                  width: image.isProfileImage ? 2 : 1,
                ),
              ),
              child: image.imageUrl.isEmpty
                  ? const SizedBox.shrink()
                  : CachedNetworkImage(
                      imageUrl: image.thumbnailUrl ?? image.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const SizedBox.shrink(),
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                    ),
            ),
          ),
          if (image.isProfileImage)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'PROFILE',
                  style: SukhanText.eyebrow(
                    size: 8,
                    color: AppColors.backgroundLight,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddPlaceholder extends StatelessWidget {
  const _AddPlaceholder({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.paperSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.secondary,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 20, color: AppColors.secondary),
            const SizedBox(height: 4),
            Text('ADD',
                style: SukhanText.eyebrow(
                  size: 9,
                  color: AppColors.secondaryDark,
                )),
          ],
        ),
      ),
    );
  }
}
