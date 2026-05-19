import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform;
import 'dart:math' as math;
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

  Future<void> _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.signInWithGoogle();
    if (!context.mounted) return;
    _showErrorIfAny(context, ref);
  }

  Future<void> _handleAppleSignIn(BuildContext context, WidgetRef ref) async {
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.signInWithApple();
    if (!context.mounted) return;
    _showErrorIfAny(context, ref);
  }

  void _showErrorIfAny(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authProvider);
    if (authState.errorMessage == null) return;
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

          // Sign-in buttons.
          //
          // App Store Guideline 4.8 requires Sign in with Apple at equal
          // prominence to any other social sign-in. We render the Apple
          // button FIRST on iOS/macOS (Apple's recommended ordering) and
          // omit it entirely on Android (Apple guidelines explicitly say
          // Android apps don't need Sign in with Apple).
          if (Platform.isIOS || Platform.isMacOS) ...[
            _buildStunningAppleButton(authState),
            const SizedBox(height: 14),
          ],
          _buildStunningGoogleButton(authState),

          const SizedBox(height: 20),

          // Guideline 5.1.1(v): users must be able to browse non-account
          // content without signing in. The splash redirect already lets
          // guests reach /main directly; this is a backup affordance for
          // anyone who manually navigated to /login.
          TextButton(
            onPressed: authState.isLoading
                ? null
                : () => context.go(AppRoutes.main),
            child: const Text(
              'Continue without signing in',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF2C5F2D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Terms
          Text(
            'By continuing, you agree to our\nTerms & Privacy Policy',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// Sign in with Apple button. Matches the Google button's dimensions
  /// (height 60, width double.infinity, radius 18) to satisfy Guideline 4.8
  /// "equal prominence". Uses Apple's mandated black/white styling.
  Widget _buildStunningAppleButton(authState) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: authState.isLoading
              ? null
              : () => _handleAppleSignIn(context, ref),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: authState.isLoading
                ? const Center(
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.apple,
                        size: 26,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Continue with Apple',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
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

  Widget _buildStunningGoogleButton(authState) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C5F2D),
            Color(0xFF1A3A1C),
            Color(0xFF0F2410),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2410).withValues(alpha: 0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: authState.isLoading
              ? null
              : () => _handleGoogleSignIn(context, ref),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: authState.isLoading
                ? const Center(
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Image.network(
                          'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                          width: 20,
                          height: 20,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.g_mobiledata,
                              size: 22,
                              color: Color(0xFF4285F4),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Flexible(
                        child: Text(
                          'Continue with Google',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
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
}
