import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/design_system/app_colors.dart';

/// Premium hero section with:
/// 1. Breathing blob background (scale-animated blurred circles)
/// 2. Rounded bottom corners
/// 3. Glassmorphism frosted search bar
/// 4. Roboto typography, centered heading (always English)
/// 5. Urdu tagline
class DiscoverHero extends StatefulWidget {
  final bool isRtl;
  final String languageCode;
  final VoidCallback onSearchTap;

  const DiscoverHero({
    super.key,
    required this.isRtl,
    required this.languageCode,
    required this.onSearchTap,
  });

  @override
  State<DiscoverHero> createState() => _DiscoverHeroState();
}

class _DiscoverHeroState extends State<DiscoverHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hintController;
  late final Animation<double> _hintOpacity;
  Timer? _hintTimer;
  int _hintIndex = 0;

  static const _hints = {
    'ur': [
      'شاعر، غزل، شعر تلاش کریں…',
      'اپنے پسندیدہ شاعر ڈھونڈیں…',
      'نظم، قصیدہ، رباعی تلاش کریں…',
    ],
    'en': [
      'Search poets, verses, ghazals…',
      'Find your favourite poet…',
      'Explore nazms, qasidas, rubais…',
    ],
    'hi': [
      'कवि, शेर, ग़ज़ल खोजें…',
      'अपने पसंदीदा शायर खोजें…',
      'नज़्म, क़सीदा, रुबाई खोजें…',
    ],
  };

  List<String> get _currentHints =>
      _hints[widget.languageCode] ?? _hints['en']!;

  @override
  void initState() {
    super.initState();
    _hintController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _hintOpacity = CurvedAnimation(
      parent: _hintController,
      curve: Curves.easeInOut,
    );
    _hintController.value = 1.0;
    _startHintRotation();
  }

  void _startHintRotation() {
    _hintTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _hintController.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _hintIndex = (_hintIndex + 1) % _currentHints.length;
        });
        _hintController.forward();
      });
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _hintController.dispose();
    super.dispose();
  }

  bool _isHintUrdu() =>
      widget.languageCode == 'ur' || widget.languageCode == 'hi';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF0A2E22),
                  AppColors.primaryDark,
                  const Color(0xFF0B2A1E),
                ]
              : [
                  const Color(0xFF0E3527),
                  const Color(0xFF163D31),
                  const Color(0xFF0F3228),
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          _BreathingBlob(
            right: -40,
            top: -20,
            size: 200,
            color: isDark
                ? const Color(0xFF1A5C48)
                : const Color(0xFF1F5A44),
            opacity: 0.25,
            duration: const Duration(seconds: 5),
          ),
          _BreathingBlob(
            left: -30,
            bottom: 20,
            size: 160,
            color: isDark
                ? const Color(0xFF1A6B5A)
                : const Color(0xFF2A7A68),
            opacity: 0.18,
            duration: const Duration(seconds: 7),
          ),
          _BreathingBlob(
            right: 40,
            bottom: 80,
            size: 100,
            color: isDark
                ? const Color(0xFF2D7A5A)
                : const Color(0xFF3A8F6E),
            opacity: 0.12,
            duration: const Duration(seconds: 6),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                children: [
                  _buildTitleSection(),
                  const SizedBox(height: 16),
                  _buildGlassSearchBar(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          'Discover',
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'غزل، نظم، مضامین، ناول، کتابیں — سب ایک جگہ',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'Jameel Noori Nastaleeq',
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.55),
            height: 1.8,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassSearchBar(bool isDark) {
    return Hero(
      tag: 'search_bar',
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: widget.onSearchTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white24,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FadeTransition(
                        opacity: _hintOpacity,
                        child: Text(
                          _currentHints[_hintIndex],
                          style: TextStyle(
                            fontFamily: _isHintUrdu()
                                ? 'Jameel Noori Nastaleeq'
                                : null,
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 15,
                            height: _isHintUrdu() ? 1.6 : 1.4,
                          ),
                          textDirection: _isHintUrdu()
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.mic_outlined,
                      color: Colors.white.withValues(alpha: 0.4),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}

// ─── Breathing Blob ─────────────────────────────────────────────

/// A soft, blurred circle that slowly scales 5-10% to feel "alive."
class _BreathingBlob extends StatefulWidget {
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final double size;
  final Color color;
  final double opacity;
  final Duration duration;

  const _BreathingBlob({
    this.left,
    this.right,
    this.top,
    this.bottom,
    required this.size,
    required this.color,
    required this.opacity,
    required this.duration,
  });

  @override
  State<_BreathingBlob> createState() => _BreathingBlobState();
}

class _BreathingBlobState extends State<_BreathingBlob>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      right: widget.right,
      top: widget.top,
      bottom: widget.bottom,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(scale: _scale.value, child: child);
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: widget.opacity),
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}
