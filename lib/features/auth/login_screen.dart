import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/routing/app_router.dart';

/// Stunning login screen with WOW factor for Jahān-e-Sukhan
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _handleAppleSignIn(BuildContext context, WidgetRef ref) async {
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.signInWithApple();

    if (context.mounted) {
      final authState = ref.read(authProvider);
      if (authState.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.errorMessage!),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.signInWithGoogle();

    if (context.mounted) {
      final authState = ref.read(authProvider);
      if (authState.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.errorMessage!),
            backgroundColor: const Color(0xFF8B4513),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Cream background
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF5F0E8), // Cream
            ),
          ),

          // Animated scattered Urdu calligraphy
          _buildAnimatedCalligraphy(),

          // Main content with animations
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      const SizedBox(height: 60),

                      // Logo with golden glow
                      _buildGlowingLogo(),

                      const Spacer(),

                      // Content card
                      _buildContentCard(authState),

                      const Spacer(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCalligraphy() {
    final words = [
      'عشق', 'خیال', 'لفظ', 'سکوت', 'جذبہ', 'یاد',
      'غزل', 'شعر', 'محبت', 'احساس', 'خواب', 'نظم',
      'درد', 'امید', 'رنگ', 'نور', 'سایہ', 'جنوں',
      'وفا', 'دل', 'راز', 'خاموشی', 'گیت', 'نغمہ'
    ];

    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Stack(
              children: List.generate(30, (index) {
                final random = math.Random(index * 123);
                final row = index ~/ 3;
                final col = index % 3;

                final cellHeight = 120.0;
                final cellWidth = 130.0;

                final top = (row * cellHeight) + (random.nextDouble() * 70) + 20;
                final left = (col * cellWidth) + (random.nextDouble() * 60) - 5;

                // Calculate shimmer effect
                final shimmerOpacity = 0.06 +
                    (math.sin(_shimmerAnimation.value + index * 0.5) * 0.03).abs();

                return Positioned(
                  top: top,
                  left: left,
                  child: Opacity(
                    opacity: shimmerOpacity,
                    child: Transform.rotate(
                      angle: (random.nextDouble() - 0.5) * 0.35,
                      child: Text(
                        words[index % words.length],
                        style: TextStyle(
                          fontFamily: 'Jameel Noori Nastaleeq',
                          fontSize: 60 + (random.nextDouble() * 25),
                          color: const Color(0xFF2C5F2D), // Green
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGlowingLogo() {
    return Image.asset(
      'assets/sukhan_full_logo.png',
      height: 100,
      fit: BoxFit.contain,
    );
  }

  Widget _buildContentCard(authState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.55),
            Colors.white.withValues(alpha: 0.50),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decorative top element
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFD4AF37),
                  Color(0xFFFFF8E1),
                  Color(0xFFD4AF37),
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 32),

          // Welcome text with shimmer
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFF0F2410),
                Color(0xFF2C5F2D),
                Color(0xFF0F2410),
              ],
            ).createShader(bounds),
            child: const Text(
              'جہانِ سخن میں خوش آمدید',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Jameel Noori Nastaleeq',
                fontSize: 34,
                height: 2.6,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Subtitle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'WHERE POETRY LIVES',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xFF0F2410),
                letterSpacing: 2.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Apple Sign-In Button — iOS only. Apple App Store Guideline 4.8
          // requires Sign in with Apple at equal prominence whenever a
          // third-party login (Google here) is offered. We render Apple
          // ABOVE Google with matching height + full width to satisfy the
          // "at least as prominent" rule.
          if (!kIsWeb && Platform.isIOS) ...[
            _buildAppleSignInButton(authState),
            const SizedBox(height: 18),
          ],

          // Stunning Google Button
          _buildStunningGoogleButton(authState),

          const SizedBox(height: 32),

          // Terms
          Text(
            'By continuing, you agree to our\nTerms & Privacy Policy',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Colors.grey[700],
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          // Guest entry — every user lands on this login screen first; tapping
          // here is the explicit, opt-in way to browse poetry without an
          // account (App Store Guideline 5.1.1(v)). Account actions inside the
          // app then prompt sign-in.
          TextButton(
            onPressed: authState.isLoading
                ? null
                : () => context.go(AppRoutes.main),
            child: Text(
              'Continue as guest',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C5F2D),
                letterSpacing: -0.1,
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFF2C5F2D).withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Shared structural constants so the Apple and Google buttons are a
  // pixel-matched pair: identical height, corner radius, horizontal padding,
  // logo box, label gap, and typography. Only the official platform colors
  // (and the logo glyph) differ.
  static const double _kButtonHeight = 56;
  static const double _kButtonRadius = 14;
  static const double _kButtonHPadding = 22;
  static const double _kLogoBox = 22;
  static const double _kLogoTextGap = 14;
  static const double _kLabelSize = 17;
  static const FontWeight _kLabelWeight = FontWeight.w600;
  static const double _kLabelSpacing = -0.2;

  /// Shared button shell used by both providers so they are structurally
  /// identical (same height, radius, padding, logo box, label gap, font).
  /// The logo is left-anchored and the label sits immediately to its right,
  /// so the two buttons' logos and text line up perfectly across rows.
  Widget _buildAuthButton({
    required Widget logo,
    required String label,
    required Color background,
    required Color foreground,
    required bool isLoading,
    required VoidCallback? onTap,
    Border? border,
    List<BoxShadow>? boxShadow,
  }) {
    return Container(
      width: double.infinity,
      height: _kButtonHeight,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(_kButtonRadius),
        border: border,
        boxShadow: boxShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(_kButtonRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _kButtonHPadding),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(foreground),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: _kLogoBox,
                        height: _kLogoBox,
                        child: Center(child: logo),
                      ),
                      const SizedBox(width: _kLogoTextGap),
                      Flexible(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: _kLabelSize,
                            fontWeight: _kLabelWeight,
                            color: foreground,
                            letterSpacing: _kLabelSpacing,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  /// Sign in with Apple — official black background + authentic Apple glyph
  /// (drawn with the package's [AppleLogoPainter]), rendered in the shared
  /// button shell so its font, size, logo box, and left margin match the
  /// Google button exactly. App-Store-compliant: black bg, white logo,
  /// "Sign in with Apple" label, correct proportions.
  Widget _buildAppleSignInButton(authState) {
    return _buildAuthButton(
      label: 'Sign in with Apple',
      background: Colors.black,
      foreground: Colors.white,
      isLoading: authState.isLoading,
      onTap: () => _handleAppleSignIn(context, ref),
      // Apple glyph is slightly taller than wide (25:31) and reads better a
      // touch larger than the square Google mark; it sits in the same box.
      logo: const SizedBox(
        width: _kLogoBox * (25 / 31),
        height: _kLogoBox,
        child: CustomPaint(
          painter: AppleLogoPainter(color: Colors.white),
        ),
      ),
    );
  }

  /// Sign in with Google — official "Light" style (white background, hairline
  /// border, multi-color transparent "G", dark grey label), in the same
  /// shared shell as the Apple button for a matched premium pair.
  Widget _buildStunningGoogleButton(authState) {
    return _buildAuthButton(
      label: 'Sign in with Google',
      background: Colors.white,
      foreground: const Color(0xFF3C4043),
      isLoading: authState.isLoading,
      onTap: () => _handleGoogleSignIn(context, ref),
      border: Border.all(color: const Color(0xFFDADCE0), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 10,
          offset: const Offset(0, 3),
          spreadRadius: -2,
        ),
      ],
      logo: Image.asset(
        'assets/icons/google_logo.png',
        width: _kLogoBox,
        height: _kLogoBox,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.g_mobiledata,
            size: _kLogoBox,
            color: Color(0xFF4285F4),
          );
        },
      ),
    );
  }
}
