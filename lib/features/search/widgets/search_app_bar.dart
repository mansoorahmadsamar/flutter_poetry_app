import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';

/// Clean search app bar for the search screen
///
/// Features:
/// - Back button on left
/// - Search text field with proper RTL support
/// - Clear button on right
/// - Loading indicator while autocompleting
/// - Brand colors and Urdu-optimized typography
class SearchAppBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String languageCode;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onBack;

  const SearchAppBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.languageCode,
    required this.isLoading,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = languageCode == 'ur' || languageCode == 'hi';
    final textDirection = isRtl ? TextDirection.rtl : TextDirection.ltr;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            tooltip: 'واپس',
          ),

          // Search Field
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.backgroundDark
                    : AppColors.verseBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: focusNode.hasFocus
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: focusNode.hasFocus ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Search Icon
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: AppSpacing.md,
                      end: AppSpacing.sm,
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      size: 22,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),

                  // Text Field
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      autofocus: true,
                      textDirection: textDirection,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(
                        fontFamily: languageCode == 'ur'
                            ? 'Jameel Noori Nastaleeq'
                            : (languageCode == 'hi' ? 'NotoSansDevanagari' : null),
                        fontSize: languageCode == 'ur' ? 18 : 16,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        height: languageCode == 'ur' ? 1.8 : 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText: _getHintText(),
                        hintTextDirection: textDirection,
                        hintStyle: TextStyle(
                          fontFamily: languageCode == 'ur'
                              ? 'Jameel Noori Nastaleeq'
                              : (languageCode == 'hi' ? 'NotoSansDevanagari' : null),
                          fontSize: languageCode == 'ur' ? 16 : 14,
                          color: isDark
                              ? AppColors.textDisabledDark
                              : AppColors.textDisabledLight,
                          height: languageCode == 'ur' ? 1.8 : 1.5,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                    ),
                  ),

                  // Loading or Clear Button
                  if (isLoading)
                    Padding(
                      padding: EdgeInsetsDirectional.only(end: AppSpacing.md),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    )
                  else if (controller.text.isNotEmpty)
                    IconButton(
                      onPressed: onClear,
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getHintText() {
    switch (languageCode) {
      case 'ur':
        return 'شاعر، غزل، نظم تلاش کریں...';
      case 'hi':
        return 'कवि, ग़ज़ल, नज़्म खोजें...';
      default:
        return 'Search poets, ghazals, nazms...';
    }
  }
}
