import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';

/// Premium discover hero header with integrated search
///
/// Features:
/// - Solid Deep Green (#1B4D3E) background
/// - Menu icon (left) + Profile avatar (right)
/// - "Discover" title with Urdu subtitle
/// - Integrated search field with multi-language support
/// - Height: 200-220px
/// - Optional subtle poetic texture overlay
class DiscoverHeroHeader extends ConsumerStatefulWidget {
  final bool autofocus;
  final VoidCallback? onMenuTap;
  final VoidCallback? onProfileTap;
  final bool showBackButton;

  const DiscoverHeroHeader({
    super.key,
    this.autofocus = false,
    this.onMenuTap,
    this.onProfileTap,
    this.showBackButton = false,
  });

  @override
  ConsumerState<DiscoverHeroHeader> createState() => _DiscoverHeroHeaderState();
}

class _DiscoverHeroHeaderState extends ConsumerState<DiscoverHeroHeader> {
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

    // Show back arrow if we have search results or are in a search state
    final hasSearchResults = searchState.mode == SearchMode.results ||
                            searchState.mode == SearchMode.searching ||
                            searchState.currentQuery.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1B4D3E), // Solid Deep Green
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Menu/Back icon + Profile avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      (widget.showBackButton && !hasSearchResults) ? Icons.arrow_back
                          : hasSearchResults ? Icons.arrow_back
                          : Icons.menu,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      if (hasSearchResults) {
                        // Clear search and go back to discovery
                        _controller.clear();
                        ref.read(globalSearchProvider.notifier).reset();
                        setState(() {});
                      } else if (widget.showBackButton) {
                        // Navigate back (for GlobalSearchScreen)
                        Navigator.of(context).pop();
                      } else {
                        // Open menu (for SearchTab)
                        widget.onMenuTap?.call();
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  GestureDetector(
                    onTap: widget.onProfileTap,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.sm),

              // Title: "Discover"
              Text(
                'Discover',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),

              SizedBox(height: 4),

              // Urdu subtitle
              Text(
                'اشعار، شاعر، غزل، نظم — سب ایک جگہ',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Jameel Noori Nastaleeq',
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.8,
                ),
              ),

              SizedBox(height: AppSpacing.sm),

              // Integrated search field
              _buildSearchField(languageCode, searchState.isLoadingAutocomplete),
            ],
          ),
        ),
      ),
    );
  }

  /// Build integrated search field
  Widget _buildSearchField(String languageCode, bool isLoading) {
    final hintText = _getHintText(languageCode);
    final textDirection = languageCode == 'ur' || languageCode == 'hi'
        ? TextDirection.rtl
        : TextDirection.ltr;
    final hasFocus = _focusNode.hasFocus;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: hasFocus
              ? Colors.white.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.2),
          width: hasFocus ? 1.5 : 1,
        ),
        boxShadow: hasFocus
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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
          fontSize: languageCode == 'ur' ? 18 : (languageCode == 'hi' ? 16 : 15),
          fontFamily: languageCode == 'ur' ? 'Jameel Noori Nastaleeq' : (languageCode == 'hi' ? 'NotoSansDevanagari' : null),
          color: Colors.white,
          height: languageCode == 'ur' ? 1.8 : 1.5,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintTextDirection: textDirection,
          hintStyle: TextStyle(
            fontSize: languageCode == 'ur' ? 16 : (languageCode == 'hi' ? 15 : 14),
            fontFamily: languageCode == 'ur' ? 'Jameel Noori Nastaleeq' : (languageCode == 'hi' ? 'NotoSansDevanagari' : null),
            color: Colors.white.withValues(alpha: 0.5),
            height: languageCode == 'ur' ? 1.8 : 1.5,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          suffixIcon: _buildSuffixIcon(isLoading),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
        onChanged: (value) {
          setState(() {}); // Rebuild to update clear button visibility
          ref.read(globalSearchProvider.notifier).onQueryChanged(value);
        },
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            ref.read(globalSearchProvider.notifier).executeSearch(query: value);
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
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    }

    if (_controller.text.isNotEmpty) {
      return IconButton(
        icon: Icon(
          Icons.clear,
          color: Colors.white.withValues(alpha: 0.7),
          size: 20,
        ),
        onPressed: () {
          _controller.clear();
          ref.read(globalSearchProvider.notifier).reset();
          setState(() {}); // Rebuild to hide clear button
        },
      );
    }

    return null;
  }

  /// Get language-specific hint text
  String _getHintText(String languageCode) {
    switch (languageCode) {
      case 'ur':
        return 'شاعر، شعر، غزل تلاش کریں…';
      case 'hi':
        return 'कवि, कविताएँ, ग़ज़ल खोजें…';
      case 'en':
      default:
        return 'Search poets, verses, ghazals…';
    }
  }
}
