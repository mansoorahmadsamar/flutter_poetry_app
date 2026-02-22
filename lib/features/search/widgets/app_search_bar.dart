import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';

/// Clean single-bar search field matching the Discover hero style.
///
/// One white rounded container with shadow — back button, search icon,
/// text field, and clear/loading all live inside the same bar.
/// No outer wrapper, no double borders.
class AppSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String languageCode;
  final bool isLoading;
  final bool showBackButton;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback? onBack;

  const AppSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.languageCode,
    required this.isLoading,
    this.showBackButton = true,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    this.onBack,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  bool _hasFocus = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
    _hasText = widget.controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() => _hasFocus = widget.focusNode.hasFocus);
  }

  void _onTextChange() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText && mounted) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUrdu = widget.languageCode == 'ur';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 50,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: _hasFocus
                ? AppColors.primary.withValues(alpha: 0.4)
                : isDark
                    ? AppColors.borderDark
                    : Colors.grey.withValues(alpha: 0.3),
            width: _hasFocus ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
          textInputAction: TextInputAction.search,
          style: TextStyle(
            fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
            fontSize: isUrdu ? 18 : 15,
            color: isDark ? AppColors.textPrimaryDark : const Color(0xFF2C2C2C),
            height: isUrdu ? 1.8 : 1.5,
          ),
          decoration: InputDecoration(
            hintText: _getHintText(),
            hintTextDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
            hintStyle: TextStyle(
              fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
              fontSize: isUrdu ? 16 : 14,
              color: Colors.grey.withValues(alpha: 0.6),
              height: isUrdu ? 1.8 : 1.5,
            ),
            prefixIcon: _buildPrefixIcon(isDark),
            suffixIcon: _buildSuffixIcon(isDark),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
        ),
      ),
    );
  }

  Widget _buildPrefixIcon(bool isDark) {
    // Back button inside the bar if enabled, otherwise just search icon
    if (widget.showBackButton && widget.onBack != null) {
      return GestureDetector(
        onTap: widget.onBack,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsetsDirectional.only(start: 4),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 22,
            color: isDark
                ? AppColors.textSecondaryDark
                : Colors.grey.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    return Icon(
      Icons.search_rounded,
      size: 20,
      color: Colors.grey.withValues(alpha: 0.7),
    );
  }

  Widget? _buildSuffixIcon(bool isDark) {
    if (widget.isLoading) {
      return Padding(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    }

    if (!_hasText) return null;

    return IconButton(
      onPressed: widget.onClear,
      icon: Icon(
        Icons.clear_rounded,
        size: 20,
        color: Colors.grey.withValues(alpha: 0.7),
      ),
    );
  }

  String _getHintText() {
    switch (widget.languageCode) {
      case 'ur':
        return 'شاعر، شعر، غزل تلاش کریں…';
      case 'hi':
        return 'कवि, शेर, ग़ज़ल खोजें…';
      default:
        return 'Search poets, verses, ghazals…';
    }
  }
}
