import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/utils/color_parser.dart';
import '../../../core/utils/language_typography.dart';
import '../models/hashtag_model.dart';
import '../services/hashtag_service.dart';
import '../utils/hashtag_tabs.dart';
import '../widgets/hashtag_couplets_tab.dart';
import '../widgets/hashtag_poems_tab.dart';
import '../widgets/hashtag_images_tab.dart';
import '../widgets/hashtag_poets_tab.dart';

class HashtagDetailScreen extends ConsumerStatefulWidget {
  final String slug;

  const HashtagDetailScreen({required this.slug, super.key});

  /// Key of the theme definition shown under the app bar.
  static const definitionKey = Key('hashtag-definition');

  @override
  ConsumerState<HashtagDetailScreen> createState() =>
      _HashtagDetailScreenState();
}

class _HashtagDetailScreenState extends ConsumerState<HashtagDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  HashtagDto? _meta;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: HashtagTab.values.length, vsync: this);
    _loadMeta();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMeta() async {
    try {
      final service = ref.read(hashtagServiceProvider);
      final meta = await service.getHashtagMeta(widget.slug);
      if (mounted) {
        setState(() {
          _meta = meta;
          _isLoading = false;
          // Open on the first tab that has content (T-178). The tab pages are
          // built only after this, so the empty first tab never loads.
          _tabController.index = initialHashtagTab(meta).index;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appLanguage = ref.watch(selectedLanguageProvider);
    final isRtl = appLanguage == 'ur';
    // A theme tag's name in the app language (fallback Urdu, then English);
    // other tags keep showing `name`, else the slug.
    final localizedName = _meta?.localizedName(appLanguage);
    final displayName = _meta?.displayName(appLanguage) ?? widget.slug;
    final definition = _meta?.definition;

    final hashtagColor =
        parseHexColor(_meta?.color, fallback: AppColors.primary);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          title: localizedName != null
              ? Text(
                  '#${localizedName.text}',
                  textDirection: LanguageTypography.getTextDirection(
                      localizedName.languageCode),
                  style: LanguageTypography.labelStyleFor(
                    languageCode: localizedName.languageCode,
                    baseFontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                )
              : Text(
                  '#$displayName',
                  style: TextStyle(
                    fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
                    fontSize: isRtl ? 20 : 18,
                    fontWeight: FontWeight.w600,
                    height: isRtl ? 1.8 : 1.4,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: hashtagColor,
            unselectedLabelColor: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            indicatorColor: hashtagColor,
            indicatorWeight: 3,
            labelStyle: TextStyle(
              fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
              fontSize: isRtl ? 14 : 13,
              fontWeight: FontWeight.w600,
              height: isRtl ? 1.6 : 1.3,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
              fontSize: isRtl ? 14 : 13,
              fontWeight: FontWeight.w500,
              height: isRtl ? 1.6 : 1.3,
            ),
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(
                text: isRtl
                    ? 'اشعار${_meta != null ? " (${_meta!.coupletCount})" : ""}'
                    : 'Couplets${_meta != null ? " (${_meta!.coupletCount})" : ""}',
              ),
              Tab(
                text: isRtl
                    ? 'نظمیں${_meta != null ? " (${_meta!.poemCount})" : ""}'
                    : 'Poems${_meta != null ? " (${_meta!.poemCount})" : ""}',
              ),
              Tab(
                text: isRtl
                    ? 'تصاویر${_meta != null ? " (${_meta!.imageCount})" : ""}'
                    : 'Images${_meta != null ? " (${_meta!.imageCount})" : ""}',
              ),
              Tab(
                text: isRtl
                    ? 'شعراء${_meta != null ? " (${_meta!.poetCount})" : ""}'
                    : 'Poets${_meta != null ? " (${_meta!.poetCount})" : ""}',
              ),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError(isDark, isRtl)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (definition != null)
                        _HashtagDefinition(
                          key: HashtagDetailScreen.definitionKey,
                          text: definition,
                          isDark: isDark,
                        ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            HashtagCoupletsTab(slug: widget.slug),
                            HashtagPoemsTab(slug: widget.slug),
                            HashtagImagesTab(slug: widget.slug),
                            HashtagPoetsTab(slug: widget.slug),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildError(bool isDark, bool isRtl) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppColors.textDisabledLight,
          ),
          const SizedBox(height: 16),
          Text(
            isRtl ? 'مواد لوڈ نہیں ہو سکا' : 'Could not load hashtag',
            style: TextStyle(
              fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
              fontSize: isRtl ? 16 : 14,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _loadMeta();
            },
            child: Text(isRtl ? 'دوبارہ کوشش کریں' : 'Try Again'),
          ),
        ],
      ),
    );
  }
}

/// A theme tag's one-line definition, under the app bar, in its own script's
/// typography and direction.
class _HashtagDefinition extends StatelessWidget {
  const _HashtagDefinition({
    super.key,
    required this.text,
    required this.isDark,
  });

  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final lang = LanguageTypography.languageCodeForScript(text);
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Text(
        text,
        textDirection: LanguageTypography.getTextDirection(lang),
        textAlign: TextAlign.start,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: LanguageTypography.createStyle(
          baseFontSize: 13,
          languageCode: lang,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}
