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
    final verticalPad = compact ? 7.0 : 10.0;
    final horizontalPad = compact ? 14.0 : 24.0;
    final fontSize = compact ? 12.5 : 14.0;
    final iconSize = compact ? 15.0 : 18.0;

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
              ? Colors.transparent
              : AppColors.primary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isFollowing
                ? (isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.15))
                : AppColors.primary,
            width: 1.5,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: iconSize,
                height: iconSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isFollowing ? AppColors.primary : Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFollowing ? Icons.check_rounded : Icons.person_add_outlined,
                    size: iconSize,
                    color: isFollowing
                        ? (isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : Colors.black.withValues(alpha: 0.5))
                        : Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isFollowing ? 'Following' : 'Follow',
                    style: GoogleFonts.roboto(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: isFollowing
                          ? (isDark
                              ? Colors.white.withValues(alpha: 0.6)
                              : Colors.black.withValues(alpha: 0.5))
                          : Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
