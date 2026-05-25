import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/design_system/app_colors.dart';

/// Modal sheet that prompts a guest to sign in before performing a gated
/// action (bookmark, like, follow, image save, etc.). Shows both Sign in
/// with Apple (iOS / macOS only, top placement per Apple's guidelines) and
/// Sign in with Google with identical dimensions — required for App Store
/// Guideline 4.8.
///
/// Returns `true` if the user successfully signed in, `false` if they
/// dismissed the sheet. Callers can use the result to optimistically retry
/// the gated action:
///
/// ```dart
/// if (auth.isGuest) {
///   final ok = await SignInPromptSheet.show(context, reason: 'Sign in to bookmark');
///   if (!ok) return;
/// }
/// _performBookmarkAction();
/// ```
class SignInPromptSheet extends ConsumerStatefulWidget {
  /// Optional human-readable reason for the sign-in prompt, shown above the
  /// buttons. Examples: "Sign in to bookmark this poem",
  /// "Sign in to follow this poet".
  final String? reason;

  const SignInPromptSheet({super.key, this.reason});

  /// Imperative open helper. Returns `true` on successful sign-in.
  static Future<bool> show(BuildContext context, {String? reason}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => SignInPromptSheet(reason: reason),
    );
    return result ?? false;
  }

  @override
  ConsumerState<SignInPromptSheet> createState() => _SignInPromptSheetState();
}

class _SignInPromptSheetState extends ConsumerState<SignInPromptSheet> {
  bool _hasPopped = false;

  @override
  Widget build(BuildContext context) {
    // Auto-dismiss with `true` the moment the user becomes authenticated.
    // This is what lets gated-action callers `await` the sheet and retry
    // their action without manual navigation.
    ref.listen(authProvider, (prev, next) {
      if (!_hasPopped && next.isAuthenticated && mounted) {
        _hasPopped = true;
        Navigator.of(context).pop(true);
      }
    });

    final authState = ref.watch(authProvider);
    final showAppleButton = Platform.isIOS || Platform.isMacOS;

    return Padding(
      // Lift the sheet above the keyboard / system UI.
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F0E8), // Cream (matches login screen background)
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Grab handle
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Heading
              Text(
                widget.reason ?? 'Sign in to continue',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Save what you love, follow poets, and pick up where you left off — across devices.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFF5C5C5C),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Buttons — Apple first on iOS, then Google. Same dimensions
              // so Apple is at least as prominent as Google (Guideline 4.8).
              if (showAppleButton) ...[
                _SignInButton(
                  label: 'Continue with Apple',
                  icon: const Icon(Icons.apple, size: 24, color: Colors.white),
                  background: Colors.black,
                  textColor: Colors.white,
                  loading: authState.isLoading,
                  onPressed: () =>
                      ref.read(authProvider.notifier).signInWithApple(),
                ),
                const SizedBox(height: 12),
              ],
              _SignInButton(
                label: 'Continue with Google',
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.g_mobiledata,
                    size: 22,
                    color: Color(0xFF4285F4),
                  ),
                ),
                background: AppColors.primary,
                textColor: Colors.white,
                loading: authState.isLoading,
                onPressed: () =>
                    ref.read(authProvider.notifier).signInWithGoogle(),
              ),

              const SizedBox(height: 16),

              // Dismiss — keeps the user browsing rather than yanking them
              // out of context.
              TextButton(
                onPressed: authState.isLoading
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: const Text(
                  'Continue browsing',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Color(0xFF5C5C5C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              if (authState.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  authState.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final Color background;
  final Color textColor;
  final bool loading;
  final VoidCallback onPressed;

  const _SignInButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.textColor,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: textColor,
          disabledBackgroundColor: background.withValues(alpha: 0.7),
          disabledForegroundColor: textColor.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: loading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
