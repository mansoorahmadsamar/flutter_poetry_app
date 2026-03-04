import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';

/// Global search bar widget with debounced input
///
/// Features:
/// - Auto RTL/LTR based on language
/// - Loading indicator during autocomplete
/// - Clear button when text exists
/// - Urdu hint text support
/// - Paper aesthetic background
/// - Debounced onChange (400ms handled by provider)
class GlobalSearchBar extends ConsumerStatefulWidget {
  final bool autofocus;
  final VoidCallback? onSubmitted;

  const GlobalSearchBar({
    super.key,
    this.autofocus = false,
    this.onSubmitted,
  });

  @override
  ConsumerState<GlobalSearchBar> createState() => _GlobalSearchBarState();
}

class _GlobalSearchBarState extends ConsumerState<GlobalSearchBar> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode.addListener(() {
      setState(() {}); // Rebuild on focus change
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(globalSearchProvider);
    final languageCode = ref.watch(selectedLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Language-specific hint text
    final hintText = _getHintText(languageCode);
    final textDirection = languageCode == 'ur' ? TextDirection.rtl : TextDirection.ltr;
    final hasFocus = _focusNode.hasFocus;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFocus
              ? AppColors.primary.withValues(alpha: 0.5)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08)),
          width: hasFocus ? 1.5 : 1,
        ),
        boxShadow: hasFocus
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        textDirection: textDirection,
        style: TextStyle(
          fontSize: languageCode == 'ur' ? 18 : 16,
          fontFamily: languageCode == 'ur' ? 'Jameel Noori Nastaleeq' : null,
          color: isDark ? Colors.white : Colors.black87,
          height: languageCode == 'ur' ? 1.8 : 1.5,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintTextDirection: textDirection,
          hintStyle: TextStyle(
            fontSize: languageCode == 'ur' ? 16 : 15,
            fontFamily: languageCode == 'ur' ? 'Jameel Noori Nastaleeq' : null,
            color: isDark
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.4),
            height: languageCode == 'ur' ? 1.8 : 1.5,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 22,
            color: hasFocus
                ? AppColors.primary
                : (isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.5)),
          ),
          suffixIcon: _buildSuffixIcon(searchState.isLoadingAutocomplete),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
        onChanged: (value) {
          setState(() {}); // Rebuild to update focus state
          ref.read(globalSearchProvider.notifier).onQueryChanged(value);
        },
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            ref.read(globalSearchProvider.notifier).executeSearch(query: value);
            widget.onSubmitted?.call();
          }
        },
      ),
    );
  }

  /// Build suffix icon (clear button or loading indicator)
  Widget? _buildSuffixIcon(bool isLoading) {
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.secondary,
            ),
          ),
        ),
      );
    }

    if (_controller.text.isNotEmpty) {
      return IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          _controller.clear();
          ref.read(globalSearchProvider.notifier).onQueryChanged('');
          _focusNode.requestFocus(); // Keep focus after clearing
        },
      );
    }

    return null;
  }

  /// Get language-specific hint text
  String _getHintText(String languageCode) {
    switch (languageCode) {
      case 'ur':
        return 'شاعر، نظم، غزل تلاش کریں...';
      case 'hi':
        return 'कवि, कविता खोजें...';
      case 'en':
      default:
        return 'Search poets, poems, verses…';
    }
  }
}
