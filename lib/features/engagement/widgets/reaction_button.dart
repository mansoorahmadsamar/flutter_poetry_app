import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/engagement/providers/reaction_providers.dart';
import 'reaction_picker.dart';

/// Size variants for different contexts.
enum ReactionButtonSize { compact, expanded }

/// Animated reaction button that replaces the old heart/like button.
///
/// - **Tap**: Quick-toggle LOVE (familiar like/unlike feel)
/// - **Long-press**: Opens ReactionPicker overlay above the button
/// - Shows current reaction emoji or outline heart when no reaction
/// - Bounce animation on tap, smooth emoji swap on change
class ReactionButton extends ConsumerStatefulWidget {
  final String? userReaction;
  final int totalCount;
  final Map<String, int>? reactionsByType;
  final ValueChanged<String> onReact;
  final ReactionButtonSize size;

  const ReactionButton({
    super.key,
    this.userReaction,
    this.totalCount = 0,
    this.reactionsByType,
    required this.onReact,
    this.size = ReactionButtonSize.compact,
  });

  @override
  ConsumerState<ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends ConsumerState<ReactionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _barrierEntry;
  OverlayEntry? _pickerEntry;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.35, end: 0.9)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 45,
      ),
    ]).animate(_bounceController);
  }

  @override
  void dispose() {
    _dismissPicker();
    _bounceController.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.lightImpact();
    _bounceController.forward(from: 0);
    // Tap = toggle LOVE (backward-compatible like/unlike feel)
    widget.onReact('LOVE');
  }

  void _onLongPress() {
    HapticFeedback.mediumImpact();
    _showPicker();
  }

  void _showPicker() {
    final reactionTypes = ref.read(reactionTypesProvider).valueOrNull;
    if (reactionTypes == null || reactionTypes.isEmpty) return;

    final isUrdu = ref.read(selectedLanguageProvider) == 'ur';

    _barrierEntry = OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _dismissPicker,
        child: const SizedBox.expand(),
      ),
    );

    // Position picker centered on screen, above the button
    final renderBox = context.findRenderObject() as RenderBox;
    final buttonPos = renderBox.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;
    final pickerWidth = screenWidth - 32;

    _pickerEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: 16,
        top: buttonPos.dy - 180, // above the button
        width: pickerWidth,
        child: ReactionPicker(
          reactionTypes: reactionTypes,
          currentReaction: widget.userReaction,
          isUrdu: isUrdu,
          onReactionSelected: (key) {
            _dismissPicker();
            _bounceController.forward(from: 0);
            HapticFeedback.selectionClick();
            widget.onReact(key);
          },
          onDismiss: _dismissPicker,
        ),
      ),
    );

    final overlay = Overlay.of(context);
    overlay.insert(_barrierEntry!);
    overlay.insert(_pickerEntry!);
  }

  void _dismissPicker() {
    _barrierEntry?.remove();
    _barrierEntry = null;
    _pickerEntry?.remove();
    _pickerEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasReaction = widget.userReaction != null;
    final reactionTypes = ref.watch(reactionTypesProvider).valueOrNull ?? [];

    final emojiSize = widget.size == ReactionButtonSize.compact ? 20.0 : 26.0;
    final iconSize = widget.size == ReactionButtonSize.compact
        ? AppSpacing.feedEngagementIconSize
        : 26.0;

    // Find current emoji
    String? currentEmoji;
    if (hasReaction) {
      for (final type in reactionTypes) {
        if (type.key == widget.userReaction) {
          currentEmoji = type.emoji;
          break;
        }
      }
      currentEmoji ??= '❤️';
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _onTap,
        onLongPress: _onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji / heart icon with bounce animation
              ScaleTransition(
                scale: _bounceAnimation,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: hasReaction
                      ? Text(
                          currentEmoji!,
                          key: ValueKey('emoji_${widget.userReaction}'),
                          style: TextStyle(fontSize: emojiSize),
                        )
                      : Icon(
                          Icons.favorite_border_rounded,
                          key: const ValueKey('heart_outline'),
                          size: iconSize,
                          color: isDark
                              ? AppColors.engagementIconDark
                              : AppColors.engagementIcon,
                        ),
                ),
              ),

              // Count
              if (widget.totalCount > 0) ...[
                const SizedBox(width: AppSpacing.xs),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(animation),
                      child:
                          FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Text(
                    _formatCount(widget.totalCount),
                    key: ValueKey(widget.totalCount),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: hasReaction
                          ? (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight)
                          : (isDark
                              ? AppColors.engagementIconDark
                              : AppColors.engagementIcon),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
