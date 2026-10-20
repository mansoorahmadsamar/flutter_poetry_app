import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/utils/api_placeholder.dart';

/// The round poet avatar in a feed card header. Tapping it opens the poet's
/// profile; screen readers announce it as `<poet name>, poet profile`.
class FeedPoetAvatar extends StatelessWidget {
  const FeedPoetAvatar({
    super.key,
    required this.poetPublicId,
    required this.poetName,
    required this.imageUrl,
  });

  final String? poetPublicId;
  final String? poetName;
  final String? imageUrl;

  /// Opens `/main/poets/:publicId`, or null when the id is absent or the
  /// API's `"-"` — the avatar and poet name are then not tappable. One rule
  /// for every feed card.
  static VoidCallback? profileTap(BuildContext context, String? poetPublicId) {
    final publicId = presentOrNull(poetPublicId);
    if (publicId == null) return null;
    return () => context.push('/main/poets/$publicId');
  }

  /// Semantic label for a poet avatar or name that opens the profile.
  static String semanticLabel(String? poetName) {
    final name = presentOrNull(poetName);
    return name == null ? 'Poet profile' : '$name, poet profile';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final url = presentOrNull(imageUrl);
    final openProfile = profileTap(context, poetPublicId);

    return Semantics(
      button: openProfile != null,
      image: true,
      label: semanticLabel(poetName),
      onTap: openProfile,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: openProfile,
        child: ClipOval(
          child: url != null
              ? CachedNetworkImage(
                  imageUrl: url,
                  width: AppSpacing.feedAvatarSize,
                  height: AppSpacing.feedAvatarSize,
                  fit: BoxFit.cover,
                  memCacheWidth: 88,
                  placeholder: (_, __) => _AvatarPlaceholder(isDark: isDark),
                  errorWidget: (_, __, ___) =>
                      _AvatarPlaceholder(isDark: isDark),
                )
              : _AvatarPlaceholder(isDark: isDark),
        ),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.feedAvatarSize,
      height: AppSpacing.feedAvatarSize,
      decoration: BoxDecoration(
        color: isDark ? AppColors.borderDark : AppColors.shimmerBase,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_outline,
        size: AppSpacing.iconSm,
        color:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
    );
  }
}
