import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import '../providers/follow_providers.dart';

/// Reusable follow/unfollow button for poet cards and detail screens.
///
/// Two variants:
///   - `compact: true` — small pill for list cards (e.g., hero card)
///   - `compact: false` — full-size button for detail screens
class FollowButton extends ConsumerWidget {
  final String publicId;
  final bool compact;

  const FollowButton({
    super.key,
    required this.publicId,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final followState = ref.watch(followToggleProvider(publicId));

    return followState.when(
      data: (isFollowing) => _buildButton(
        context,
        ref,
        isFollowing: isFollowing,
        isDark: isDark,
      ),
      loading: () => _buildButton(
        context,
        ref,
        isFollowing: false,
        isDark: isDark,
        isLoading: true,
      ),
      error: (_, __) => _buildButton(
        context,
        ref,
        isFollowing: false,
        isDark: isDark,
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    WidgetRef ref, {
    required bool isFollowing,
    required bool isDark,
    bool isLoading = false,
  }) {
    final verticalPad = compact ? 6.0 : 10.0;
    final horizontalPad = compact ? 16.0 : 24.0;
    final fontSize = compact ? 12.0 : 14.0;

    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
              HapticFeedback.lightImpact();
              ref.read(followToggleProvider(publicId).notifier).toggle();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPad,
          vertical: verticalPad,
        ),
        decoration: BoxDecoration(
          color: isFollowing
              ? (isDark
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.1))
              : AppColors.primary,
          borderRadius: BorderRadius.circular(20),
          border: isFollowing
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 1,
                )
              : null,
        ),
        child: isLoading
            ? SizedBox(
                width: compact ? 14 : 16,
                height: compact ? 14 : 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isFollowing ? AppColors.primary : Colors.white,
                  ),
                ),
              )
            : Text(
                isFollowing ? 'Following' : 'Follow',
                style: GoogleFonts.roboto(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: isFollowing
                      ? AppColors.primary
                      : Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}
