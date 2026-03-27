import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/widgets/localized_text.dart';
import '../../main/tabs/poets/models/poem_model.dart';
import '../services/hashtag_service.dart';

class HashtagPoemsTab extends ConsumerStatefulWidget {
  final String slug;

  const HashtagPoemsTab({required this.slug, super.key});

  @override
  ConsumerState<HashtagPoemsTab> createState() => _HashtagPoemsTabState();
}

class _HashtagPoemsTabState extends ConsumerState<HashtagPoemsTab>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final List<PoemModel> _poems = [];
  int _currentPage = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPage(0);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.85) {
      _loadMore();
    }
  }

  Future<void> _loadPage(int page) async {
    try {
      final lang = ref.read(selectedLanguageProvider);
      final service = ref.read(hashtagServiceProvider);
      final result = await service.getPoemsByHashtag(
        widget.slug,
        lang: lang,
        page: page,
        size: 15,
      );

      if (!mounted) return;
      setState(() {
        _poems.addAll(result.content);
        _currentPage = page;
        _hasMore = !result.last;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    await _loadPage(_currentPage + 1);
  }

  Future<void> _refresh() async {
    setState(() {
      _poems.clear();
      _currentPage = 0;
      _hasMore = true;
      _isLoading = true;
      _error = null;
    });
    await _loadPage(0);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = ref.watch(selectedLanguageProvider) == 'ur';

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _poems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isRtl ? 'لوڈ نہیں ہو سکا' : 'Failed to load',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: _refresh, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_poems.isEmpty) {
      return Center(
        child: Text(
          isRtl ? 'کوئی نظمیں نہیں ملیں' : 'No poems found',
          style: TextStyle(
            fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
            fontSize: isRtl ? 16 : 14,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primary,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _poems.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == _poems.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }

          final poem = _poems[index];
          return _PoemListTile(
            poem: poem,
            isDark: isDark,
            isRtl: isRtl,
            onTap: () => context.push('/main/poems/${poem.publicId}'),
          );
        },
      ),
    );
  }
}

class _PoemListTile extends StatelessWidget {
  final PoemModel poem;
  final bool isDark;
  final bool isRtl;
  final VoidCallback onTap;

  const _PoemListTile({
    required this.poem,
    required this.isDark,
    required this.isRtl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = poem.title ?? poem.contents.firstOrNull?.title ?? '';
    final excerpt = poem.excerpt ??
        poem.contents.firstOrNull?.fullText.substring(
          0,
          (poem.contents.firstOrNull?.fullText.length ?? 0).clamp(0, 120),
        ) ??
        '';

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title.isNotEmpty)
                LocalizedText(
                  title,
                  style: TextStyle(
                    fontSize: isRtl ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    height: isRtl ? 1.8 : 1.4,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (title.isNotEmpty && excerpt.isNotEmpty)
                const SizedBox(height: 6),
              if (excerpt.isNotEmpty)
                LocalizedText(
                  excerpt,
                  style: TextStyle(
                    fontSize: isRtl ? 15 : 14,
                    height: isRtl ? 1.8 : 1.5,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    poem.poetName,
                    style: TextStyle(
                      fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
                      fontSize: isRtl ? 14 : 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      height: isRtl ? 1.6 : 1.3,
                    ),
                  ),
                  const Spacer(),
                  if (poem.poetryTypeName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        poem.poetryTypeName!,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
