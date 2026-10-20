import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../../main/tabs/poets/models/couplet_model.dart';
import '../services/hashtag_service.dart';
import 'hashtag_couplet_tile.dart';

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
        _couplets.addAll(result.content.where(HashtagCoupletTile.hasVerseText));
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
          final poemId = couplet.poemPublicId;
          return HashtagCoupletTile(
            key: ValueKey('hashtag-couplet-${couplet.publicId}'),
            couplet: couplet,
            isDark: isDark,
            isRtl: isRtl,
            // Production's CoupletDto has no poem id (T-177): such a couplet
            // shows its verses but opens nothing, rather than /main/poems/null.
            onTap: poemId == null
                ? null
                : () => context.push('/main/poems/$poemId'),
          );
        },
      ),
    );
  }
}
