import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';

const String _urduFontFamily = 'Jameel Noori Nastaleeq';

// Design tokens — mirrors PoetHorizontalCard for visual consistency
class _Tokens {
  _Tokens._();

  static const Color surfaceLight = Color(0xFFFCFAF6);
  static const Color surfaceDark = Color(0xFF262626);
  static const Color borderLight = Color(0xFFEFE6DA);
  static const Color borderDark = Color(0xFF3A3A3A);

  static List<BoxShadow> shadow(bool isDark) => isDark
      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 4))]
      : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 2, offset: const Offset(0, 1)),
        ];
}

/// Compact (150px wide) poem card for horizontal discovery scrolls.
class PoemHorizontalCard extends StatefulWidget {
  final PoemModel poem;
  final String selectedScript;
  final VoidCallback onTap;

  const PoemHorizontalCard({
    super.key,
    required this.poem,
    required this.selectedScript,
    required this.onTap,
  });

  @override
  State<PoemHorizontalCard> createState() => _PoemHorizontalCardState();
}

class _PoemHorizontalCardState extends State<PoemHorizontalCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUrdu = widget.selectedScript == 'ur';
    final title = widget.poem.getDisplayTitle(widget.selectedScript);
    final excerpt = widget.poem.getDisplayText(widget.selectedScript);
    final typeLabel = widget.poem.poetryTypeName ??
        widget.poem.poetryTypeUrduName ??
        widget.poem.poetryType;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: SizedBox(
          width: 150,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? _Tokens.surfaceDark : _Tokens.surfaceLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? _Tokens.borderDark : _Tokens.borderLight,
              ),
              boxShadow: _Tokens.shadow(isDark),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Poetry type badge row
                Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      typeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: isUrdu
                          ? const TextStyle(
                              fontFamily: _urduFontFamily,
                              fontSize: 10,
                              height: 1.4,
                              color: AppColors.primary,
                            )
                          : GoogleFonts.roboto(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                    ),
                  ),
                ),

                const Divider(height: 1, thickness: 0.5, color: Color(0xFFEFE6DA)),

                // Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    style: isUrdu
                        ? TextStyle(
                            fontFamily: _urduFontFamily,
                            fontSize: 12,
                            height: 1.5,
                            color: isDark ? const Color(0xFFF0ECE6) : const Color(0xFF1A1A1A),
                          )
                        : GoogleFonts.roboto(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            color: isDark ? const Color(0xFFF0ECE6) : const Color(0xFF1A1A1A),
                          ),
                  ),
                ),

                // Excerpt
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                  child: Text(
                    excerpt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    style: isUrdu
                        ? const TextStyle(
                            fontFamily: _urduFontFamily,
                            fontSize: 10,
                            height: 1.4,
                            color: AppColors.textSecondaryLight,
                          )
                        : GoogleFonts.roboto(
                            fontSize: 10,
                            height: 1.4,
                            color: AppColors.textSecondaryLight,
                          ),
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
