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

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFBF7), // Paper background
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        textDirection: textDirection,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintTextDirection: textDirection,
          hintStyle: TextStyle(
            fontSize: 16,
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.black.withValues(alpha: 0.6),
          ),
          suffixIcon: _buildSuffixIcon(searchState.isLoadingAutocomplete),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
        onChanged: (value) {
          // Notify provider of query change (debounced internally)
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
        return 'شاعر، شعر، یا اشعار تلاش کریں...';
      case 'hi':
        return 'कवि, कविता, या छंद खोजें...';
      case 'en':
      default:
        return 'Search poets, poems, or verses...';
    }
  }
}
