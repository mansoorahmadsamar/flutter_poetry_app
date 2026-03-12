import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../models/hashtag_model.dart';
import '../services/hashtag_service.dart';
import '../widgets/hashtag_couplets_tab.dart';
import '../widgets/hashtag_poems_tab.dart';
import '../widgets/hashtag_images_tab.dart';
import '../widgets/hashtag_poets_tab.dart';

class HashtagDetailScreen extends ConsumerStatefulWidget {
  final String slug;

  const HashtagDetailScreen({required this.slug, super.key});

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
    _tabController = TabController(length: 4, vsync: this);
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
    final isRtl = ref.watch(selectedLanguageProvider) == 'ur';
    final displayName = _meta?.name ?? widget.slug;

    final hashtagColor = _meta?.color != null
        ? Color(int.parse(_meta!.color!.replaceAll('#', '0xFF')))
        : AppColors.primary;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          title: Text(
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
                : TabBarView(
                    controller: _tabController,
                    children: [
                      HashtagCoupletsTab(slug: widget.slug),
                      HashtagPoemsTab(slug: widget.slug),
                      HashtagImagesTab(slug: widget.slug),
                      HashtagPoetsTab(slug: widget.slug),
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
