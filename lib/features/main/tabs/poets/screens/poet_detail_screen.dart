import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/poet_providers.dart';
import '../widgets/poet_overview_tab.dart';
import '../widgets/poet_gallery_tab.dart';
import '../widgets/poet_books_tab.dart';
import '../widgets/poet_videos_tab.dart';
import '../widgets/poet_poetry_tab.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/core/widgets/localized_text.dart';

class PoetDetailScreen extends ConsumerStatefulWidget {
  final String publicId;

  const PoetDetailScreen({
    super.key,
    required this.publicId,
  });

  @override
  ConsumerState<PoetDetailScreen> createState() => _PoetDetailScreenState();
}

class _PoetDetailScreenState extends ConsumerState<PoetDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final poetProfile = ref.watch(poetDetailProvider(widget.publicId));
    final selectedLanguage = ref.watch(selectedLanguageProvider);
    final isUrdu = selectedLanguage == 'ur';

    return poetProfile.when(
      data: (poet) => Scaffold(
        body: CustomScrollView(
          slivers: [
            // Hero Header
            _buildHeroHeader(context, poet, isDark, isUrdu),
            // Poet Info Card
            SliverToBoxAdapter(
              child: _buildPoetInfoCard(context, poet, isDark, isUrdu),
            ),
            // Tab Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                tabController: _tabController,
                isDark: isDark,
              ),
            ),
            // Tab Content
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  PoetOverviewTab(poet: poet),
                  PoetGalleryTab(publicId: widget.publicId),
                  PoetBooksTab(publicId: widget.publicId),
                  PoetVideosTab(publicId: widget.publicId),
                  PoetPoetryTab(publicId: widget.publicId),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: AppSpacing.lg),
              Text('Failed to load poet details'),
              SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, poetProfile, bool isDark, bool isUrdu) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            CachedNetworkImage(
              imageUrl: poetProfile.profileImageUrl ?? '',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: isDark ? Colors.grey[800] : Colors.grey[300],
              ),
              errorWidget: (context, url, error) => Container(
                color: isDark ? Colors.grey[800] : Colors.grey[300],
                child: Icon(
                  Icons.person_outline,
                  size: 100,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    isDark
                        ? AppColors.surfaceDark.withValues(alpha: 0.8)
                        : Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            // Floating Info
            Positioned(
              bottom: AppSpacing.lg,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  LocalizedText(
                    poetProfile.name,
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _buildQuickStat(
                        context,
                        '${poetProfile.birthYear}${poetProfile.deathYear != null ? ' - ${poetProfile.deathYear}' : ''}',
                        'Years',
                      ),
                      SizedBox(width: AppSpacing.lg),
                      _buildQuickStat(
                        context,
                        '${poetProfile.poemCount}',
                        'Poems',
                      ),
                      SizedBox(width: AppSpacing.lg),
                      _buildQuickStat(
                        context,
                        _formatNumber(poetProfile.viewCount),
                        'Views',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(BuildContext context, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey[300],
              ),
        ),
      ],
    );
  }

  Widget _buildPoetInfoCard(BuildContext context, poetProfile, bool isDark, bool isUrdu) {
    return Container(
      transform: Matrix4.translationValues(0, -30, 0),
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio
          LocalizedText(
            poetProfile.shortBio,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          // Details Grid
          GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildDetailItem(context, 'Era', _getEraLabel(poetProfile.era)),
              _buildDetailItem(
                context,
                'Country',
                poetProfile.country ?? 'N/A',
              ),
              _buildDetailItem(
                context,
                'Language',
                poetProfile.primaryLanguageName ?? 'Urdu',
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          // Bio Text
          if (poetProfile.biography != null)
            LocalizedText(
              poetProfile.biography!,
              style: TextStyle(
                fontSize: 14,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getEraLabel(String? era) {
    switch (era) {
      case 'CLASSICAL':
        return 'Classical';
      case 'MODERN':
        return 'Modern';
      case 'CONTEMPORARY':
        return 'Contemporary';
      case 'EMERGING':
        return 'Emerging';
      default:
        return era ?? 'Unknown';
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final bool isDark;

  _TabBarDelegate({required this.tabController, required this.isDark});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: TabBar(
        controller: tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor:
            isDark ? Colors.grey[400] : Colors.grey[600],
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Gallery'),
          Tab(text: 'Books'),
          Tab(text: 'Videos'),
          Tab(text: 'Poetry'),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return oldDelegate.tabController != tabController ||
        oldDelegate.isDark != isDark;
  }
}
