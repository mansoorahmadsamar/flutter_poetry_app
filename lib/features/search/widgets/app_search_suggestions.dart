import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:shimmer/shimmer.dart';

/// Inline autocomplete suggestions (NOT a floating overlay).
///
/// Renders as an embedded ListView in the scroll body:
/// 1. "تلاش کریں: [query]" action row
/// 2. Grouped suggestions: شعراء, کلام, ٹیگز, زمرے
/// 3. Shimmer placeholders when loading
///
/// Only watches autocomplete-related state via `.select()`.
class AppSearchSuggestions extends ConsumerWidget {
  final ValueChanged<String> onSuggestionTap;
  final VoidCallback onSearchTap;

  const AppSearchSuggestions({
    super.key,
    required this.onSuggestionTap,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autocomplete = ref.watch(
      globalSearchProvider.select((s) => s.autocompleteResults),
    );
    final isLoading = ref.watch(
      globalSearchProvider.select((s) => s.isLoadingAutocomplete),
    );
    final query = ref.watch(
      globalSearchProvider.select((s) => s.currentQuery),
    );
    final languageCode = ref.watch(selectedLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUrdu = languageCode == 'ur';

    return ListView(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      children: [
        // "Search for" action row
        _SearchActionRow(
          query: query,
          isDark: isDark,
          isUrdu: isUrdu,
          onTap: onSearchTap,
        ),

        // Loading shimmer
        if (isLoading && autocomplete == null) ...[
          for (int i = 0; i < 3; i++) _SuggestionSkeleton(isDark: isDark),
        ],

        // Grouped suggestions with staggered entrance
        if (autocomplete != null) ...[
          // Build groups and stagger by index
          ..._buildStaggeredGroups(autocomplete, languageCode, isDark, isUrdu),
        ],
      ],
    );
  }

  List<Widget> _buildStaggeredGroups(
    AutocompleteResponse autocomplete,
    String languageCode,
    bool isDark,
    bool isUrdu,
  ) {
    final groups = <Widget>[];
    int groupIndex = 0;

    if (autocomplete.poets.isNotEmpty) {
      groups.add(_StaggeredEntrance(
        delay: Duration(milliseconds: 30 * groupIndex),
        child: _SuggestionGroup(
          title: _poetsTitle(languageCode),
          icon: Icons.person_rounded,
          isDark: isDark,
          isUrdu: isUrdu,
          children: autocomplete.poets.map((poet) {
            return _PoetSuggestionRow(
              poet: poet,
              isDark: isDark,
              onTap: () => onSuggestionTap(poet.name),
            );
          }).toList(),
        ),
      ));
      groupIndex++;
    }

    if (autocomplete.poems.isNotEmpty) {
      groups.add(_StaggeredEntrance(
        delay: Duration(milliseconds: 30 * groupIndex),
        child: _SuggestionGroup(
          title: _poemsTitle(languageCode),
          icon: Icons.auto_stories_rounded,
          isDark: isDark,
          isUrdu: isUrdu,
          children: autocomplete.poems.map((poem) {
            return _TextSuggestionRow(
              text: poem.title,
              subtitle: poem.poetName,
              isDark: isDark,
              onTap: () => onSuggestionTap(poem.title),
            );
          }).toList(),
        ),
      ));
      groupIndex++;
    }

    if (autocomplete.tags.isNotEmpty) {
      groups.add(_StaggeredEntrance(
        delay: Duration(milliseconds: 30 * groupIndex),
        child: _SuggestionGroup(
          title: _tagsTitle(languageCode),
          icon: Icons.tag_rounded,
          isDark: isDark,
          isUrdu: isUrdu,
          children: autocomplete.tags.map((tag) {
            return _TextSuggestionRow(
              text: tag.name,
              isDark: isDark,
              onTap: () => onSuggestionTap(tag.name),
            );
          }).toList(),
        ),
      ));
      groupIndex++;
    }

    if (autocomplete.categories.isNotEmpty) {
      groups.add(_StaggeredEntrance(
        delay: Duration(milliseconds: 30 * groupIndex),
        child: _SuggestionGroup(
          title: _categoriesTitle(languageCode),
          icon: Icons.category_rounded,
          isDark: isDark,
          isUrdu: isUrdu,
          children: autocomplete.categories.map((cat) {
            return _TextSuggestionRow(
              text: cat.name,
              trailing: cat.poemCount > 0
                  ? Text(
                      '${cat.poemCount}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    )
                  : null,
              isDark: isDark,
              onTap: () => onSuggestionTap(cat.name),
            );
          }).toList(),
        ),
      ));
    }

    return groups;
  }

  String _poetsTitle(String lang) =>
      lang == 'ur' ? 'شعراء' : (lang == 'hi' ? 'कवि' : 'Poets');
  String _poemsTitle(String lang) =>
      lang == 'ur' ? 'کلام' : (lang == 'hi' ? 'कविताएँ' : 'Poems');
  String _tagsTitle(String lang) =>
      lang == 'ur' ? 'ٹیگز' : (lang == 'hi' ? 'टैग' : 'Tags');
  String _categoriesTitle(String lang) =>
      lang == 'ur' ? 'زمرے' : (lang == 'hi' ? 'श्रेणियाँ' : 'Categories');
}

// ---------------------------------------------------------------------------
// Staggered entrance animation (opacity + translateY)
// ---------------------------------------------------------------------------

class _StaggeredEntrance extends StatefulWidget {
  final Duration delay;
  final Widget child;

  const _StaggeredEntrance({
    required this.delay,
    required this.child,
  });

  @override
  State<_StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<_StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// "Search for [query]" action row
// ---------------------------------------------------------------------------

class _SearchActionRow extends StatelessWidget {
  final String query;
  final bool isDark;
  final bool isUrdu;
  final VoidCallback onTap;

  const _SearchActionRow({
    required this.query,
    required this.isDark,
    required this.isUrdu,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: 20,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                isUrdu ? 'تلاش کریں: "$query"' : 'Search for "$query"',
                textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                style: TextStyle(
                  fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                  fontSize: isUrdu ? 16 : 14,
                  color: AppColors.primary,
                  height: isUrdu ? 1.8 : 1.4,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Suggestion group with header
// ---------------------------------------------------------------------------

class _SuggestionGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;
  final bool isUrdu;
  final List<Widget> children;

  const _SuggestionGroup({
    required this.title,
    required this.icon,
    required this.isDark,
    required this.isUrdu,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.secondary),
              SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: TextStyle(
                  fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                  fontSize: isUrdu ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                  height: isUrdu ? 1.8 : 1.4,
                ),
              ),
            ],
          ),
        ),

        // Items
        ...children,

        // Divider
        Divider(
          height: 1,
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Poet suggestion row (with avatar)
// ---------------------------------------------------------------------------

class _PoetSuggestionRow extends StatelessWidget {
  final AutocompletePoet poet;
  final bool isDark;
  final VoidCallback onTap;

  const _PoetSuggestionRow({
    required this.poet,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUrdu = _isUrduText(poet.name);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: poet.profileImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: poet.profileImageUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      memCacheWidth: 80,
                      placeholder: (_, __) => _placeholder(),
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            SizedBox(width: AppSpacing.md),

            // Name
            Expanded(
              child: Text(
                poet.name,
                textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                style: TextStyle(
                  fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                  fontSize: isUrdu ? 16 : 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  height: isUrdu ? 1.8 : 1.4,
                ),
              ),
            ),

            // Arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark
                  ? AppColors.textDisabledDark
                  : AppColors.textDisabledLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        size: 20,
        color: AppColors.primary.withValues(alpha: 0.5),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Text suggestion row
// ---------------------------------------------------------------------------

class _TextSuggestionRow extends StatelessWidget {
  final String text;
  final String? subtitle;
  final Widget? trailing;
  final bool isDark;
  final VoidCallback onTap;

  const _TextSuggestionRow({
    required this.text,
    this.subtitle,
    this.trailing,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUrdu = _isUrduText(text);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    textDirection:
                        isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    style: TextStyle(
                      fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                      fontSize: isUrdu ? 16 : 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      height: isUrdu ? 1.8 : 1.4,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2),
                    Text(
                      subtitle!,
                      textDirection: _isUrduText(subtitle!)
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: _isUrduText(subtitle!)
                            ? 'Jameel Noori Nastaleeq'
                            : null,
                        fontSize: _isUrduText(subtitle!) ? 13 : 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        height: _isUrduText(subtitle!) ? 1.6 : 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
            SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark
                  ? AppColors.textDisabledDark
                  : AppColors.textDisabledLight,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton shimmer row
// ---------------------------------------------------------------------------

class _SuggestionSkeleton extends StatelessWidget {
  final bool isDark;

  const _SuggestionSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Shimmer.fromColors(
        baseColor: isDark ? AppColors.surfaceDark : AppColors.shimmerBase,
        highlightColor:
            isDark ? AppColors.borderDark : AppColors.shimmerHighlight,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helper
// ---------------------------------------------------------------------------

bool _isUrduText(String text) {
  return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
}
