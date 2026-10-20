import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/engagement/providers/reaction_providers.dart';
import 'package:flutter_poetry_app/features/engagement/widgets/reaction_button.dart';
import 'package:flutter_poetry_app/features/image_poetry/providers/image_bookmark_providers.dart';

import '../models/creator_image_model.dart';
import '../providers/creator_providers.dart';
import '../utils/api_error_messages.dart';

/// Full-screen view of one of the creator's own gallery images. Reuses
/// the same engagement endpoints the feed card hits (reactions,
/// bookmarks, share). Owner-only actions live behind the kebab menu in
/// the top bar — change category, edit caption / alt text, set as
/// profile picture, delete.
class CreatorImageDetailScreen extends ConsumerStatefulWidget {
  const CreatorImageDetailScreen({super.key, required this.image});

  final CreatorImage image;

  @override
  ConsumerState<CreatorImageDetailScreen> createState() =>
      _CreatorImageDetailScreenState();
}

class _CreatorImageDetailScreenState
    extends ConsumerState<CreatorImageDetailScreen> {
  late CreatorImage _image;

  // Local optimistic state for engagement. Seeded from the server in
  // initState via a single GET /api/poetry-images/{id}/status call, then
  // mutated optimistically on tap. Falls back to the counts on the
  // CreatorImage if the status call fails.
  bool _isBookmarked = false;
  String? _userReaction;
  int _totalReactions = 0;
  int _bookmarkCount = 0;
  int _shareCount = 0;
  Map<String, int> _reactionsByType = const {};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _image = widget.image;
    _bookmarkCount = _image.bookmarkCount;
    _shareCount = _image.shareCount;
    _totalReactions = _image.likeCount;
    _loadEngagementStatus();
  }

  Future<void> _loadEngagementStatus() async {
    try {
      final svc = ref.read(imageCollectionServiceProvider);
      final s = await svc.getImageStatus(_image.publicId);
      if (!mounted) return;
      setState(() {
        _isBookmarked = (s['isBookmarked'] as bool?) ?? _isBookmarked;
        _bookmarkCount = (s['bookmarkCount'] as num?)?.toInt() ?? _bookmarkCount;
        _shareCount = (s['shareCount'] as num?)?.toInt() ?? _shareCount;
        _totalReactions = (s['totalReactionCount'] as num?)?.toInt() ??
            (s['likeCount'] as num?)?.toInt() ??
            _totalReactions;
        _userReaction = s['userReaction'] as String?;
        final byType = s['reactionsByType'];
        if (byType is Map) {
          _reactionsByType = byType.map(
            (k, v) => MapEntry(k.toString(), (v as num).toInt()),
          );
        }
      });
    } catch (_) {
      // Soft-fail: stay with the counts we seeded from the image.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.35),
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _busy ? null : _showOwnerMenu,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Pinch-to-zoom full-screen image. Tap a single time to dismiss
          // engagement bar isn't wired here — the bar stays so the user
          // can react/share without juggling chrome.
          PhotoView(
            imageProvider: CachedNetworkImageProvider(_image.imageUrl),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            loadingBuilder: (_, __) => const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            ),
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image_outlined,
                  color: Colors.white54, size: 48),
            ),
          ),

          // Bottom scrim + engagement bar + metadata.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomPanel(
              image: _image,
              isBookmarked: _isBookmarked,
              userReaction: _userReaction,
              totalReactions: _totalReactions,
              reactionsByType: _reactionsByType,
              bookmarkCount: _bookmarkCount,
              shareCount: _shareCount,
              onReact: _onReact,
              onBookmark: _onBookmark,
              onShare: _onShare,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Engagement actions ────────────────────────────────────────────

  void _onReact(String reactionType) async {
    final previousUser = _userReaction;
    final previousTotal = _totalReactions;
    final previousByType = Map<String, int>.from(_reactionsByType);
    final isRemoving = previousUser == reactionType;

    // Optimistic update.
    setState(() {
      if (isRemoving) {
        _userReaction = null;
        _totalReactions = (_totalReactions - 1).clamp(0, 1 << 31);
        final next = Map<String, int>.from(_reactionsByType);
        next[reactionType] = ((next[reactionType] ?? 1) - 1).clamp(0, 1 << 31);
        if ((next[reactionType] ?? 0) == 0) next.remove(reactionType);
        _reactionsByType = next;
      } else {
        _userReaction = reactionType;
        _totalReactions = previousUser == null
            ? _totalReactions + 1
            : _totalReactions;
        final next = Map<String, int>.from(_reactionsByType);
        if (previousUser != null) {
          next[previousUser] = ((next[previousUser] ?? 1) - 1).clamp(0, 1 << 31);
          if ((next[previousUser] ?? 0) == 0) next.remove(previousUser);
        }
        next[reactionType] = (next[reactionType] ?? 0) + 1;
        _reactionsByType = next;
      }
    });

    try {
      await ref.read(reactionActionProvider.notifier).react(
            targetType: 'poetry-images',
            publicId: _image.publicId,
            reactionType: reactionType,
          );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _userReaction = previousUser;
        _totalReactions = previousTotal;
        _reactionsByType = previousByType;
      });
    }
  }

  void _onBookmark() async {
    final previousFlag = _isBookmarked;
    final previousCount = _bookmarkCount;
    setState(() {
      _isBookmarked = !_isBookmarked;
      _bookmarkCount = (previousCount + (_isBookmarked ? 1 : -1))
          .clamp(0, 1 << 31);
    });
    try {
      await ref
          .read(imageBookmarkActionProvider.notifier)
          .toggleBookmark(_image.publicId);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isBookmarked = previousFlag;
        _bookmarkCount = previousCount;
      });
    }
  }

  void _onShare() async {
    final lang = ref.read(selectedLanguageProvider);
    try {
      final svc = ref.read(imageCollectionServiceProvider);
      final shareInfo = await svc.recordShare(_image.publicId, lang: lang);
      final text = (shareInfo['shareText'] as String?) ?? '';
      final url = shareInfo['shareImageUrl'] as String?;
      ShareResult result;
      if (url != null && url.isNotEmpty) {
        // Download to a temp file so the native share sheet can carry
        // the actual image instead of just a URL.
        final tmp = await getTemporaryDirectory();
        final ext = url.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
        final path = '${tmp.path}/share_${_image.publicId}.$ext';
        await Dio().download(url, path);
        result = await Share.shareXFiles([XFile(path)], text: text);
      } else {
        result = await Share.shareWithResult(text);
      }
      if (result.status == ShareResultStatus.success && mounted) {
        setState(() => _shareCount += 1);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyApiMessage(e, CreatorAction.uploadImage))),
      );
    }
  }

  // ─── Owner kebab actions ───────────────────────────────────────────

  void _showOwnerMenu() {
    showModalBottomSheet(
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
            if (!_image.isProfileImage)
              ListTile(
                leading: const Icon(Icons.person_outline,
                    color: AppColors.primary),
                title: const Text('Set as profile picture'),
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  _setAsProfile();
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit_outlined,
                  color: AppColors.primary),
              title: const Text('Edit caption & alt text'),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                _editCaption();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: AppColors.error),
              title: const Text('Delete',
                  style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                _confirmDelete();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _setAsProfile() async {
    setState(() => _busy = true);
    try {
      final svc = ref.read(creatorServiceProvider);
      await svc.updateImage(_image.publicId, {'isProfileImage': true});
      ref.invalidate(creatorImagesProvider(null));
      ref.invalidate(ownedPoetProvider);
      if (!mounted) return;
      setState(() => _image = _image.copyWith(isProfileImage: true));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(friendlyApiMessage(e, CreatorAction.uploadImage)),
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editCaption() async {
    final captionCtl =
        TextEditingController(text: _image.caption ?? '');
    final altCtl = TextEditingController(text: _image.altText ?? '');
    final result = await showModalBottomSheet<Map<String, String?>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(sheetCtx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Caption',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: captionCtl,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            const Text('Alt text (for accessibility)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: altCtl,
              minLines: 1,
              maxLines: 2,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(sheetCtx).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(sheetCtx).pop({
                      'caption': captionCtl.text.trim(),
                      'altText': altCtl.text.trim(),
                    }),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    setState(() => _busy = true);
    try {
      final svc = ref.read(creatorServiceProvider);
      await svc.updateImage(_image.publicId, {
        'caption': result['caption'],
        'altText': result['altText'],
      });
      ref.invalidate(creatorImagesProvider(null));
      if (!mounted) return;
      setState(() => _image = _image.copyWith(
            caption: result['caption'],
            altText: result['altText'],
          ));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image updated')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(friendlyApiMessage(e, CreatorAction.uploadImage)),
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete image?'),
        content: const Text(
          'This will remove the image from your gallery. It cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      final svc = ref.read(creatorServiceProvider);
      await svc.deleteImage(_image.publicId);
      ref.invalidate(creatorImagesProvider(null));
      if (!mounted) return;
      Navigator.of(context).maybePop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(friendlyApiMessage(e, CreatorAction.uploadImage)),
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// Bottom panel: dark gradient scrim, category badge + caption row, then
/// the engagement bar (reactions / bookmark / share with counts).
class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.image,
    required this.isBookmarked,
    required this.userReaction,
    required this.totalReactions,
    required this.reactionsByType,
    required this.bookmarkCount,
    required this.shareCount,
    required this.onReact,
    required this.onBookmark,
    required this.onShare,
  });

  final CreatorImage image;
  final bool isBookmarked;
  final String? userReaction;
  final int totalReactions;
  final Map<String, int> reactionsByType;
  final int bookmarkCount;
  final int shareCount;
  final ValueChanged<String> onReact;
  final VoidCallback onBookmark;
  final VoidCallback onShare;

  String get _categoryLabel {
    switch (image.imageType) {
      case 'PROFILE':
        return 'Profile';
      case 'PORTRAIT':
        return 'Portrait';
      case 'HISTORICAL':
        return 'Historical';
      case 'EVENT':
        return 'Event';
      case 'POETRY':
        return 'Image poetry';
      case 'OTHER':
        return 'Other';
      case 'GALLERY':
      default:
        return 'Gallery';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.85),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CategoryChip(label: _categoryLabel),
                if (image.isProfileImage) ...[
                  const SizedBox(width: 8),
                  const _CategoryChip(label: 'Profile', emphasised: true),
                ],
              ],
            ),
            if ((image.caption ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                image.caption!,
                style: SukhanText.sans(
                  size: 13,
                  color: Colors.white,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 14),
            // Engagement row. ReactionButton handles the picker overlay.
            Row(
              children: [
                ReactionButton(
                  userReaction: userReaction,
                  totalCount: totalReactions,
                  reactionsByType: reactionsByType,
                  onReact: onReact,
                  size: ReactionButtonSize.expanded,
                ),
                const SizedBox(width: 20),
                _IconCount(
                  icon: isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  count: bookmarkCount,
                  highlighted: isBookmarked,
                  onTap: onBookmark,
                ),
                const SizedBox(width: 20),
                _IconCount(
                  icon: Icons.ios_share,
                  count: shareCount,
                  onTap: onShare,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, this.emphasised = false});
  final String label;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final bg = emphasised
        ? AppColors.secondary
        : Colors.white.withValues(alpha: 0.18);
    final fg = emphasised ? AppColors.primaryDark : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: emphasised
            ? null
            : Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        label.toUpperCase(),
        style: SukhanText.eyebrow(
          size: 9,
          color: fg,
        ),
      ),
    );
  }
}

class _IconCount extends StatelessWidget {
  const _IconCount({
    required this.icon,
    required this.count,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final int count;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 22,
                color: highlighted ? AppColors.secondary : Colors.white),
            const SizedBox(width: 6),
            Text(
              _fmt(count),
              style: SukhanText.sans(
                size: 13,
                color: Colors.white,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}m';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}k';
    return '$n';
  }
}
