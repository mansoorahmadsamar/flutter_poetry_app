import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:flutter_poetry_app/core/widgets/standard_app_bar.dart';

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
  final ScrollController _scrollController = ScrollController();
  bool _showElevation = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 10 && !_showElevation) {
      setState(() => _showElevation = true);
    } else if (_scrollController.offset <= 10 && _showElevation) {
      setState(() => _showElevation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final poetProfile = ref.watch(poetDetailProvider(widget.publicId));
    final selectedLanguage = ref.watch(selectedLanguageProvider);
    final isUrdu = selectedLanguage == 'ur';

    return poetProfile.when(
      data: (poet) => Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // Simple App Bar
            StandardSliverAppBar(
              title: poet.name,
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // Share functionality
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // More options
                  },
                ),
              ],
            ),
            // Profile Header
            SliverToBoxAdapter(
              child: _buildProfileHeader(context, poet, isDark, isUrdu),
            ),
            // Tab Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                tabController: _tabController,
                isDark: isDark,
              ),
            ),
          ],
          body: TabBarView(
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
      ),
      loading: () => Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        appBar: AppBar(
          title: const Text('Loading...'),
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          foregroundColor: isDark ? Colors.white : AppColors.primary,
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          foregroundColor: isDark ? Colors.white : AppColors.primary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Failed to load poet details',
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, poetProfile, bool isDark, bool isUrdu) {
    // Get the profile image URL
    String? profileImageUrl = poetProfile.profileImageUrl;

    // If no direct profileImageUrl, try to get from gallery where isProfileImage is true
    if ((profileImageUrl == null || profileImageUrl.isEmpty) &&
        poetProfile.gallery != null &&
        poetProfile.gallery!.isNotEmpty) {
      try {
        final profileImage = poetProfile.gallery!.firstWhere(
          (img) => img.isProfileImage == true,
        );
        profileImageUrl = profileImage.imageUrl;
      } catch (e) {
        // If no profile image found in gallery, use first image
        profileImageUrl = poetProfile.gallery!.first.imageUrl;
      }
    }

    return Container(
      color: isDark ? AppColors.surfaceDark : Colors.white,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image & Stats Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circular Profile Image with Brand Border
              Hero(
                tag: 'poet_${poetProfile.publicId}',
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondary,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: profileImageUrl != null && profileImageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: profileImageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: isDark ? Colors.grey[800] : Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.person_outline,
                                size: 40,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.person_outline,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      context,
                      _formatNumber(poetProfile.followerCount),
                      'Followers',
                      isDark,
                    ),
                    _buildStat(
                      context,
                      _formatNumber(poetProfile.poemCount),
                      'Poems',
                      isDark,
                    ),
                    _buildStat(
                      context,
                      _formatNumber(poetProfile.viewCount),
                      'Views',
                      isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Poet Name with Verified Badge
          Row(
            children: [
              Flexible(
                child: LocalizedText(
                  poetProfile.name,
                  style: isUrdu
                      ? AppTypography.urduPoetNameStyle.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.8,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                        )
                      : GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                        ),
                ),
              ),
              if (poetProfile.isVerified) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Compact Info Row
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              // Birth Place & Country
              if (poetProfile.birthPlace != null || poetProfile.country != null)
                _buildLocationChip(
                  context,
                  poetProfile.birthPlace,
                  poetProfile.country,
                  poetProfile.countryFlag,
                  isDark,
                  isUrdu,
                ),
              // Birth Year - Death Year
              if (poetProfile.birthYear > 0)
                _buildInfoChip(
                  context,
                  Icons.calendar_today_outlined,
                  poetProfile.deathYear != null && poetProfile.deathYear! > 0
                      ? '${poetProfile.birthYear} - ${poetProfile.deathYear}'
                      : 'b. ${poetProfile.birthYear}',
                  isDark,
                  false,
                ),
              // Language
              if (poetProfile.primaryLanguageName != null)
                _buildInfoChip(
                  context,
                  Icons.language_outlined,
                  poetProfile.primaryLanguageName!,
                  isDark,
                  false,
                ),
              // Era Badge
              if (poetProfile.era != null)
                _buildEraBadge(poetProfile.era!, isDark),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Short Bio
          LocalizedText(
            poetProfile.shortBio,
            style: isUrdu
                ? AppTypography.urduPoetNameStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.8,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  )
                : GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Badges Row
          Wrap(
            spacing: 8,
            children: [
              if (poetProfile.isFeatured)
                _buildStatusBadge(
                  'Featured',
                  Icons.star_rounded,
                  AppColors.secondary,
                ),
              if (poetProfile.isTrending)
                _buildStatusBadge(
                  'Trending',
                  Icons.local_fire_department_rounded,
                  AppColors.primary,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String value,
    String label,
    bool isDark,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String text,
    bool isDark,
    bool isUrdu,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.secondary,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: isUrdu
                ? AppTypography.urduPoetNameStyle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  )
                : GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationChip(
    BuildContext context,
    String? birthPlace,
    String? country,
    String? countryFlag,
    bool isDark,
    bool isUrdu,
  ) {
    // Build location text
    String locationText = '';
    if (birthPlace != null && country != null) {
      locationText = '$birthPlace, $country';
    } else {
      locationText = birthPlace ?? country ?? '';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Country flag emoji
        if (countryFlag != null) ...[
          Text(
            countryFlag,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 6),
        ] else ...[
          Icon(
            Icons.location_on_outlined,
            size: 14,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            locationText,
            style: isUrdu
                ? AppTypography.urduPoetNameStyle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  )
                : GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildEraBadge(String era, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondary,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            size: 12,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            _getEraLabel(era),
            style: GoogleFonts.roboto(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getEraLabel(String era) {
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
        return era;
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

// Tab Bar Delegate
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final bool isDark;

  _TabBarDelegate({
    required this.tabController,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.borderDark
                : AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
        indicatorColor: AppColors.secondary,
        indicatorWeight: 3,
        labelStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
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
