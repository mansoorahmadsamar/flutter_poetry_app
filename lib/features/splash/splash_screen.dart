import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

/// Modern artistic splash screen matching brand theme
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOutCubic,
      ),
    );

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Cream background matching login screen
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF5F0E8), // Cream
            ),
          ),

          // Animated scattered Urdu calligraphy background
          _buildAnimatedCalligraphy(),

          // Main content with animations
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Sukhan full logo
                    Image.asset(
                      'assets/sukhan_full_logo.png',
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 40),

                    // Tagline in Urdu
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF0F2410),
                          Color(0xFF2C5F2D),
                          Color(0xFF0F2410),
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'جہانِ سخن',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Jameel Noori Nastaleeq',
                          fontSize: 38,
                          height: 2.2,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // English tagline
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'WHERE POETRY LIVES',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: Color(0xFF0F2410),
                          letterSpacing: 2.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Modern pulsing loading indicator
                    _buildModernLoadingIndicator(),
                  ],
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
              children: List.generate(24, (index) {
                final random = math.Random(index * 456);
                final row = index ~/ 3;
                final col = index % 3;

                final cellHeight = 130.0;
                final cellWidth = 130.0;

                final top = (row * cellHeight) + (random.nextDouble() * 80) + 30;
                final left = (col * cellWidth) + (random.nextDouble() * 70) - 10;

                // Shimmer effect with subtle variation
                final shimmerOpacity = 0.05 +
                    (math.sin(_shimmerAnimation.value + index * 0.6) * 0.025)
                        .abs();

                return Positioned(
                  top: top,
                  left: left,
                  child: Opacity(
                    opacity: shimmerOpacity,
                    child: Transform.rotate(
                      angle: (random.nextDouble() - 0.5) * 0.3,
                      child: Text(
                        words[index % words.length],
                        style: TextStyle(
                          fontFamily: 'Jameel Noori Nastaleeq',
                          fontSize: 55 + (random.nextDouble() * 30),
                          color: const Color(0xFF2C5F2D), // Brand green
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

  Widget _buildModernLoadingIndicator() {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring with gradient
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2C5F2D).withValues(alpha: 0.2),
                  const Color(0xFFD4AF37).withValues(alpha: 0.2),
                ],
              ),
            ),
          ),
          // Animated progress indicator
          const CircularProgressIndicator(
            strokeWidth: 3.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(0xFF2C5F2D), // Brand green
            ),
          ),
          // Inner decorative dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
