import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/widgets/localized_text.dart';
import '../../main/tabs/poets/models/couplet_model.dart';
import '../services/hashtag_service.dart';
import 'hashtag_pill.dart';

class HashtagCoupletsTab extends ConsumerStatefulWidget {
  final String slug;

  const HashtagCoupletsTab({required this.slug, super.key});

  @override
  ConsumerState<HashtagCoupletsTab> createState() =>
      _HashtagCoupletsTabState();
}

class _HashtagCoupletsTabState extends ConsumerState<HashtagCoupletsTab>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final List<CoupletDetailResponse> _couplets = [];
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
      final result = await service.getCoupletsByHashtag(
        widget.slug,
        lang: lang,
        page: page,
        size: 15,
      );

      if (!mounted) return;
      setState(() {
        _couplets.addAll(result.content);
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
      _couplets.clear();
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

    if (_error != null && _couplets.isEmpty) {
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

    if (_couplets.isEmpty) {
      return Center(
        child: Text(
          isRtl ? 'کوئی اشعار نہیں ملے' : 'No couplets found',
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
        itemCount: _couplets.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == _couplets.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }

          final couplet = _couplets[index];
          return _CoupletListTile(
            couplet: couplet,
            isDark: isDark,
            isRtl: isRtl,
            onTap: () =>
                context.push('/main/poems/${couplet.poemPublicId}'),
          );
        },
      ),
    );
  }
}

class _CoupletListTile extends StatelessWidget {
  final CoupletDetailResponse couplet;
  final bool isDark;
  final bool isRtl;
  final VoidCallback onTap;

  const _CoupletListTile({
    required this.couplet,
    required this.isDark,
    required this.isRtl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final verses = couplet.verses;
    final verseText = verses
        .map((v) => v.text)
        .where((t) => t.isNotEmpty)
        .join('\n');

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
              LocalizedText(
                verseText,
                style: TextStyle(
                  fontSize: isRtl ? 18 : 16,
                  fontWeight: FontWeight.w500,
                  height: isRtl ? 2.0 : 1.6,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              if (couplet.tagSlugs.isNotEmpty) ...[
                const SizedBox(height: 8),
                HashtagSlugRow(slugs: couplet.tagSlugs),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    couplet.poetName,
                    style: TextStyle(
                      fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
                      fontSize: isRtl ? 14 : 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      height: isRtl ? 1.6 : 1.3,
                    ),
                  ),
                  if (couplet.poemTitle != null) ...[
                    Text(
                      ' — ',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    Expanded(
                      child: LocalizedText(
                        couplet.poemTitle!,
                        style: TextStyle(
                          fontSize: isRtl ? 13 : 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          height: isRtl ? 1.6 : 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
