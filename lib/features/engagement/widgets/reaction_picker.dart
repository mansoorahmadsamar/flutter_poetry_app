import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/features/engagement/models/reaction_models.dart';

/// Floating reaction picker — appears above the reaction button on long-press.
/// Two rows of 5 emojis each, with labels always visible.
/// Each emoji staggers in with spring physics.
class ReactionPicker extends StatefulWidget {
  final List<ReactionType> reactionTypes;
  final String? currentReaction;
  final ValueChanged<String> onReactionSelected;
  final VoidCallback onDismiss;
  final bool isUrdu;

  const ReactionPicker({
    super.key,
    required this.reactionTypes,
    this.currentReaction,
    required this.onReactionSelected,
    required this.onDismiss,
    this.isUrdu = true,
  });

  @override
  State<ReactionPicker> createState() => _ReactionPickerState();
}

class _ReactionPickerState extends State<ReactionPicker>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _scaleAnimations;
  int? _pressedIndex;

  @override
  void initState() {
    super.initState();
    final count = widget.reactionTypes.length;
    _controllers = List.generate(count, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
    });
    _scaleAnimations = _controllers.map((c) {
      return CurvedAnimation(parent: c, curve: Curves.elasticOut);
    }).toList();

    // Staggered entrance — each emoji pops in 35ms after the previous
    for (var i = 0; i < count; i++) {
      Future.delayed(Duration(milliseconds: 35 * i), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final pickerWidth = screenWidth - 32; // 16px margin each side

    // Split into 2 rows of 5
    final topRow = widget.reactionTypes.take(5).toList();
    final bottomRow = widget.reactionTypes.skip(5).toList();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: pickerWidth,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRow(topRow, 0, pickerWidth),
            const SizedBox(height: 6),
            _buildRow(bottomRow, 5, pickerWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<ReactionType> types, int startIndex, double totalWidth) {
    final itemWidth = (totalWidth - 16) / 5; // 5 items per row, minus padding

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(types.length, (i) {
        final globalIndex = startIndex + i;
        final type = types[i];
        final isSelected = widget.currentReaction == type.key;
        final isPressed = _pressedIndex == globalIndex;

        return ScaleTransition(
          scale: _scaleAnimations[globalIndex],
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressedIndex = globalIndex),
            onTapUp: (_) {
              setState(() => _pressedIndex = null);
              HapticFeedback.selectionClick();
              widget.onReactionSelected(type.key);
            },
            onTapCancel: () => setState(() => _pressedIndex = null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              width: itemWidth,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: isPressed ? 1.35 : (isSelected ? 1.1 : 1.0),
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    child: Text(
                      type.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.isUrdu ? type.urduLabel : type.englishLabel,
                    style: TextStyle(
                      fontFamily:
                          widget.isUrdu ? 'Jameel Noori Nastaleeq' : null,
                      fontSize: widget.isUrdu ? 11 : 9,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : (Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                      height: widget.isUrdu ? 1.6 : 1.2,
                    ),
                    textDirection:
                        widget.isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
