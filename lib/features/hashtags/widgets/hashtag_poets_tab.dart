import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../../main/tabs/poets/models/poet_model.dart';
import '../services/hashtag_service.dart';

class HashtagPoetsTab extends ConsumerStatefulWidget {
  final String slug;

  const HashtagPoetsTab({required this.slug, super.key});

  @override
  ConsumerState<HashtagPoetsTab> createState() => _HashtagPoetsTabState();
}

class _HashtagPoetsTabState extends ConsumerState<HashtagPoetsTab>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final List<PoetModel> _poets = [];
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
      final result = await service.getPoetsByHashtag(
        widget.slug,
        lang: lang,
        page: page,
        size: 20,
      );

      if (!mounted) return;
      setState(() {
        _poets.addAll(result.content);
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
      _poets.clear();
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

    if (_error != null && _poets.isEmpty) {
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

    if (_poets.isEmpty) {
      return Center(
        child: Text(
          isRtl ? 'کوئی شاعر نہیں ملے' : 'No poets found',
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
        itemCount: _poets.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == _poets.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }

          final poet = _poets[index];
          return _PoetListTile(
            poet: poet,
            isDark: isDark,
            isRtl: isRtl,
            onTap: () => context.push('/main/poets/${poet.publicId}'),
          );
        },
      ),
    );
  }
}

class _PoetListTile extends StatelessWidget {
  final PoetModel poet;
  final bool isDark;
  final bool isRtl;
  final VoidCallback onTap;

  const _PoetListTile({
    required this.poet,
    required this.isDark,
    required this.isRtl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final era = poet.birthYear > 0
        ? '${poet.birthYear}–${poet.deathYear > 0 ? poet.deathYear : "present"}'
        : '';

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: poet.profileImageUrl != null &&
                        poet.profileImageUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(
                        poet.profileImageUrl!,
                        maxWidth: 96,
                        maxHeight: 96,
                      )
                    : null,
                child: poet.profileImageUrl == null ||
                        poet.profileImageUrl!.isEmpty
                    ? Icon(Icons.person_rounded,
                        size: 24, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poet.name,
                      style: TextStyle(
                        fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
                        fontSize: isRtl ? 16 : 15,
                        fontWeight: FontWeight.w600,
                        height: isRtl ? 1.8 : 1.4,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    if (era.isNotEmpty)
                      Text(
                        era,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                  ],
                ),
              ),
              // Stats
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (poet.poemCount > 0)
                    Text(
                      '${poet.poemCount} ${isRtl ? "نظمیں" : "poems"}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (poet.followerCount > 0)
                    Text(
                      '${poet.followerCount} ${isRtl ? "فالوورز" : "followers"}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
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
