import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import '../../models/creator_image_model.dart';
import '../../providers/creator_providers.dart';
import '../../utils/api_error_messages.dart';

/// Sort options for the creator gallery. All client-side because the
/// list endpoint returns every image and counts per item.
enum _GallerySort { newest, mostLiked, mostShared, mostBookmarked }

extension _GallerySortX on _GallerySort {
  String get label {
    switch (this) {
      case _GallerySort.newest:
        return 'Newest';
      case _GallerySort.mostLiked:
        return 'Most liked';
      case _GallerySort.mostShared:
        return 'Most shared';
      case _GallerySort.mostBookmarked:
        return 'Most bookmarked';
    }
  }
}

/// 3-column gallery grid. Profile image gets a gold ring + "PROFILE" tag.
/// Last cell is the dashed-gold "+ ADD" upload prompt.
class GalleryTab extends ConsumerStatefulWidget {
  const GalleryTab({super.key});

  @override
  ConsumerState<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends ConsumerState<GalleryTab> {
  _GallerySort _sort = _GallerySort.newest;

  /// Active category filter. `null` = All. Matched against `imageType`.
  String? _categoryFilter;

  /// Static list of (label, optional imageType key) pairs for the chip
  /// row. `null` key = "All". Order favours the most-used categories.
  static const List<(String label, String? key)> _categoryChips = [
    ('All', null),
    ('Profile', 'PROFILE'),
    ('Portrait', 'PORTRAIT'),
    ('Historical', 'HISTORICAL'),
    ('Event', 'EVENT'),
    ('Image poetry', 'POETRY'),
    ('Gallery', 'GALLERY'),
    ('Other', 'OTHER'),
  ];

  /// Display label for the category dropdown chip. Falls back to "All"
  /// when no category is selected; otherwise looks up the chip key in
  /// [_categoryChips] for a friendly label.
  String get _activeCategoryLabel {
    if (_categoryFilter == null) return 'All';
    for (final c in _categoryChips) {
      if (c.$2 == _categoryFilter) return c.$1;
    }
    return _categoryFilter!;
  }

  /// Apply the active category filter + sort to the raw list. `displayOrder`
  /// is the secondary key so two images uploaded the same day stay in a
  /// stable order.
  List<CreatorImage> _displayList(List<CreatorImage> raw) {
    final filtered = _categoryFilter == null
        ? raw
        : raw.where((i) => i.imageType == _categoryFilter).toList();
    final sorted = [...filtered];
    int byCount(int Function(CreatorImage) accessor, CreatorImage a, CreatorImage b) {
      final cmp = accessor(b).compareTo(accessor(a));
      if (cmp != 0) return cmp;
      return b.displayOrder.compareTo(a.displayOrder);
    }
    switch (_sort) {
      case _GallerySort.newest:
        // No timestamp on the model; treat displayOrder DESC as a proxy
        // for "newest" (uploads put new items at the top).
        sorted.sort((a, b) => b.displayOrder.compareTo(a.displayOrder));
        break;
      case _GallerySort.mostLiked:
        sorted.sort((a, b) => byCount((i) => i.likeCount, a, b));
        break;
      case _GallerySort.mostShared:
        sorted.sort((a, b) => byCount((i) => i.shareCount, a, b));
        break;
      case _GallerySort.mostBookmarked:
        sorted.sort((a, b) => byCount((i) => i.bookmarkCount, a, b));
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final imagesAsync = ref.watch(creatorImagesProvider(null));
    return imagesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text("Couldn't load your gallery — please try again.",
              style: SukhanText.italic(
                size: 12,
                color: AppColors.error,
              )),
        ),
      ),
      data: (images) {
        // Empty: a single centered empty-state block (icon + quote + one
        // Upload CTA) instead of a lone "ADD" tile + a floating quote.
        if (images.isEmpty) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 90),
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.greenSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.photo_library_outlined,
                          size: 34, color: AppColors.primary),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '"تصویر بھی ایک نظم ہے"',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: SukhanText.nastaleeq(
                        size: 15,
                        color: AppColors.primary,
                        height: 1.9,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () => _uploadImage(context, ref),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Upload an image'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.backgroundLight,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 10),
                        shape: const StadiumBorder(),
                        textStyle: SukhanText.sans(
                          size: 12,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        final visible = _displayList(images);
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          children: [
            // Filter row — [📅 Newest ▾]  |  [▽ All ▾]  + "5 images" tag
            // pushed to the right, with the filled green Upload pill
            // on the far right. No big "Gallery" title — the tab strip
            // already labels this view.
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PopupMenuButton<_GallerySort>(
                  position: PopupMenuPosition.under,
                  initialValue: _sort,
                  onSelected: (s) => setState(() => _sort = s),
                  itemBuilder: (_) => _GallerySort.values
                      .map((s) => PopupMenuItem(
                            value: s,
                            child: Text(s.label),
                          ))
                      .toList(),
                  child: _IconChip(
                    icon: Icons.calendar_today_outlined,
                    label: _sort.label,
                  ),
                ),
                Container(
                  width: 1,
                  height: 22,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: AppColors.dividerLight,
                ),
                PopupMenuButton<String?>(
                  position: PopupMenuPosition.under,
                  initialValue: _categoryFilter,
                  onSelected: (key) => setState(() => _categoryFilter = key),
                  itemBuilder: (_) => _categoryChips
                      .map((c) => PopupMenuItem<String?>(
                            value: c.$2,
                            child: Text(c.$1),
                          ))
                      .toList(),
                  child: _IconChip(
                    icon: Icons.filter_alt_outlined,
                    label: _activeCategoryLabel,
                    accent: _categoryFilter != null,
                  ),
                ),
                const Spacer(),
                Text(
                  '${images.length} ${images.length == 1 ? "image" : "images"}',
                  style: SukhanText.sans(
                    size: 12,
                    color: AppColors.textSecondaryLight,
                    weight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: () => _uploadImage(context, ref),
                  icon: const Icon(Icons.cloud_upload_outlined, size: 14),
                  label: const Text('Upload'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.backgroundLight,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    shape: const StadiumBorder(),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    textStyle: SukhanText.sans(
                      size: 12,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            // Hairline divider between the controls row and the grid —
            // anchors the controls visually and lets the gap stay tiny.
            const SizedBox(height: 6),
            Container(height: 1, color: AppColors.dividerLight),
            const SizedBox(height: 6),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.82,
              ),
              itemCount: visible.length + 1,
              itemBuilder: (ctx, i) {
                if (i == visible.length) {
                  return _AddPlaceholder(
                    onTap: () => _uploadImage(ctx, ref),
                  );
                }
                final img = visible[i];
                return _GalleryCell(
                  image: img,
                  onTap: () => GoRouter.of(ctx).pushNamed(
                    'creator-image-detail',
                    pathParameters: {'id': img.publicId},
                    extra: img,
                  ),
                  onMenu: () => _showImageActions(ctx, ref, img),
                );
              },
            ),
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

    // Ask the user which category this image belongs to before uploading.
    // Lets the same upload flow create profile pictures, portraits,
    // historical images, etc. — all backed by the same endpoint per
    // FLUTTER_API_DOCUMENTATION.md §20.8.
    if (!context.mounted) return;
    final category = await _pickCategory(context);
    if (category == null) return; // user dismissed

    try {
      await ref.read(creatorServiceProvider).uploadImage(
            filePath: picked.path,
            imageType: category.imageType,
            isProfileImage: category.isProfileImage,
          );
      ref.invalidate(creatorImagesProvider(null));
      // If they uploaded a new profile image, the dashboard hero needs
      // to pick up the new profileImageUrl too.
      if (category.isProfileImage) {
        ref.invalidate(ownedPoetProvider);
      }
      messenger.showSnackBar(SnackBar(content: Text(category.successMessage)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text(friendlyApiMessage(e, CreatorAction.uploadImage)),
      ));
    }
  }

  /// Bottom sheet that asks which category (`imageType`) the image
  /// belongs to. Returns `null` if dismissed. The order here intentionally
  /// puts the most-used categories first.
  Future<_ImageCategory?> _pickCategory(BuildContext context) {
    return showModalBottomSheet<_ImageCategory>(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // Cap the sheet so the system gesture bar + a bit of breathing room
      // stay visible. Internal list scrolls if it grows past that cap.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
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
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                children: [
                  Text('Category',
                      style: SukhanText.display(
                        size: 14,
                        color: AppColors.textPrimaryLight,
                        weight: FontWeight.w600,
                      )),
                  const SizedBox(width: 8),
                  Text('قسم',
                      textDirection: TextDirection.rtl,
                      style: SukhanText.nastaleeq(
                        size: 13,
                        color: AppColors.secondary,
                      )),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final c in _ImageCategory.all)
                      ListTile(
                        leading: Icon(c.icon, color: AppColors.primary),
                        title: Row(
                          children: [
                            Expanded(child: Text(c.label)),
                            const SizedBox(width: 8),
                            Text(c.urduLabel,
                                textDirection: TextDirection.rtl,
                                style: SukhanText.nastaleeq(
                                  size: 13,
                                  color: AppColors.secondary,
                                )),
                          ],
                        ),
                        onTap: () => Navigator.of(sheetCtx).pop(c),
                      ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        messenger.showSnackBar(SnackBar(
          content: Text(friendlyApiMessage(e, CreatorAction.updateImage)),
        ));
      }
    } else if (action == 'delete') {
      try {
        await ref.read(creatorServiceProvider).deleteImage(img.publicId);
        ref.invalidate(creatorImagesProvider(null));
      } catch (e) {
        messenger.showSnackBar(SnackBar(
          content: Text(friendlyApiMessage(e, CreatorAction.deleteImage)),
        ));
      }
    }
  }
}

class _GalleryCell extends StatelessWidget {
  const _GalleryCell({
    required this.image,
    required this.onTap,
    required this.onMenu,
  });

  final CreatorImage image;
  final VoidCallback onTap;
  final VoidCallback onMenu;

  /// Title-case label for the category corner badge. PROFILE wins over
  /// the underlying imageType so the gold "Profile" tag still anchors the
  /// poet's primary picture. Plain GALLERY items get no badge.
  String? get _categoryLabel {
    if (image.isProfileImage) return 'Profile';
    switch (image.imageType) {
      case 'PORTRAIT':
        return 'Portrait';
      case 'HISTORICAL':
        return 'Historical';
      case 'EVENT':
        return 'Event';
      case 'POETRY':
        return 'Poetry';
      case 'OTHER':
        return 'Other';
      case 'PROFILE':
        return 'Profile';
      case 'GALLERY':
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProfile = image.isProfileImage;
    final badge = _categoryLabel;
    final caption = (image.caption ?? '').trim();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Card chrome — cream surface, rounded corners, soft shadow, gold
        // ring on the active profile image.
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: isProfile
              ? Border.all(color: AppColors.secondary, width: 1.2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Image is contained (not cropped) so logos/illustrations
                  // show fully, mirroring the screenshot.
                  Positioned.fill(
                    child: image.imageUrl.isEmpty
                        ? const SizedBox.shrink()
                        : CachedNetworkImage(
                            imageUrl: image.thumbnailUrl ?? image.imageUrl,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const SizedBox.shrink(),
                            errorWidget: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                  ),
                  // Category badge — top-left. Gold for the active profile,
                  // muted neutral for everything else (matches mockup).
                  if (badge != null)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: isProfile
                              ? AppColors.secondary
                              : AppColors.textSecondaryLight
                                  .withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          badge.toUpperCase(),
                          style: SukhanText.sans(
                            size: 7,
                            color: AppColors.backgroundLight,
                            weight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  // Kebab in a small white circle, top-right.
                  Positioned(
                    top: -2,
                    right: -2,
                    child: _KebabButton(onTap: onMenu),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            // Caption below the image. Always reserved as a single-line
            // strip so cards stay the same height; empty for images
            // without a caption.
            Text(
              caption.isNotEmpty ? caption : '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: SukhanText.sans(
                size: 9,
                color: AppColors.primaryDark,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// White circular kebab button used at the top-right of each gallery
/// card. Opens the per-image actions sheet.
class _KebabButton extends StatelessWidget {
  const _KebabButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(2),
          child: Icon(Icons.more_vert,
              size: 11, color: AppColors.textPrimaryLight),
        ),
      ),
    );
  }
}

/// Filter chip with a leading icon used in the Newest / All row. Matches
/// the screenshot's outlined pill style. `accent: true` swaps to gold to
/// signal an active filter.
class _IconChip extends StatelessWidget {
  const _IconChip({
    required this.icon,
    required this.label,
    this.accent = false,
  });
  final IconData icon;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final fg = accent ? AppColors.secondaryDark : AppColors.textPrimaryLight;
    final border = accent ? AppColors.secondary : AppColors.dividerLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: SukhanText.sans(
              size: 12,
              color: fg,
              weight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: fg),
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

/// One option in the category picker that follows source selection on
/// upload. Maps to the backend's `imageType` enum from
/// FLUTTER_API_DOCUMENTATION.md §20.8. `Profile picture` additionally
/// sets `isProfileImage: true` so the backend promotes it to the
/// poet's profile slot (and demotes the prior one).
class _ImageCategory {
  const _ImageCategory({
    required this.label,
    required this.urduLabel,
    required this.icon,
    required this.imageType,
    this.isProfileImage = false,
    String? successMessage,
  }) : _successMessage = successMessage;

  final String label;
  final String urduLabel;
  final IconData icon;
  final String imageType;
  final bool isProfileImage;
  final String? _successMessage;

  String get successMessage =>
      _successMessage ?? '$label uploaded';

  static const all = <_ImageCategory>[
    _ImageCategory(
      label: 'Profile picture',
      urduLabel: 'پروفائل تصویر',
      icon: Icons.person_outline,
      imageType: 'PROFILE',
      isProfileImage: true,
      successMessage: 'Profile picture updated',
    ),
    _ImageCategory(
      label: 'Portrait',
      urduLabel: 'تصویر',
      icon: Icons.image_outlined,
      imageType: 'PORTRAIT',
    ),
    _ImageCategory(
      label: 'Historical',
      urduLabel: 'تاریخی',
      icon: Icons.history_edu_outlined,
      imageType: 'HISTORICAL',
    ),
    _ImageCategory(
      label: 'Event',
      urduLabel: 'تقریب',
      icon: Icons.event_outlined,
      imageType: 'EVENT',
    ),
    _ImageCategory(
      label: 'Image poetry',
      urduLabel: 'تصویری شاعری',
      icon: Icons.auto_awesome_outlined,
      imageType: 'POETRY',
    ),
    _ImageCategory(
      label: 'Gallery',
      urduLabel: 'گیلری',
      icon: Icons.photo_library_outlined,
      imageType: 'GALLERY',
    ),
    _ImageCategory(
      label: 'Other',
      urduLabel: 'دیگر',
      icon: Icons.more_horiz,
      imageType: 'OTHER',
    ),
  ];
}
