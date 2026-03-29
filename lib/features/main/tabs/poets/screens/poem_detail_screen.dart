import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/core/widgets/localized_text.dart';
import 'package:flutter_poetry_app/features/engagement/providers/couplet_providers.dart';
import '../models/couplet_model.dart';
import '../models/poem_model.dart';
import '../providers/poem_providers.dart';
import '../widgets/poem_more_from_poet_section.dart';
import '../widgets/poem_reading_card.dart';

class PoemDetailScreen extends ConsumerStatefulWidget {
  final String publicId;

  const PoemDetailScreen({
    super.key,
    required this.publicId,
  });

  @override
  ConsumerState<PoemDetailScreen> createState() => _PoemDetailScreenState();
}

class _PoemDetailScreenState extends ConsumerState<PoemDetailScreen> {
  // Used for reading card rendering and "more from poet" section.
  // Always 'ur' for now — no toggle exposed to user.
  String _selectedScript = 'ur';
  bool _scriptInitialized = false;

  // Which sher block is currently highlighted. null = none.
  int? _selectedSherIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_scriptInitialized) {
      _selectedScript = ref.read(selectedLanguageProvider);
      _scriptInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final poemAsync = ref.watch(poemDetailProvider(widget.publicId));

    return Scaffold(
      appBar: poemAsync.maybeWhen(
        data: (poem) => AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          title: Text(
            poem.getDisplayTitle(_selectedScript),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.share_outlined, size: 22), onPressed: () {}),
          ],
        ),
        orElse: () => AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
        ),
      ),
      body: poemAsync.when(
        data: (poem) => _buildContent(context, poem),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(context, error),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Main scrollable body
  // ────────────────────────────────────────────────────────────

  Widget _buildContent(BuildContext context, PoemModel poem) {
    final coupletsAsync = ref.watch(coupletsProvider(poem.publicId));

    final couplets = coupletsAsync.when(
      data: (c) => c,
      loading: () => null,
      error: (_, __) => const <CoupletModel>[],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Poet hero header
          _buildPoetHeader(context, poem),
          const SizedBox(height: 16),

          // 2. Poem reading surface
          PoemReadingCard(
            key: ValueKey(_selectedScript),
            poem: poem,
            couplets: couplets,
            selectedScript: _selectedScript,
            selectedSherIndex: _selectedSherIndex,
            onSherSelected: (i) => setState(() => _selectedSherIndex = i),
          ),
          const SizedBox(height: 16),

          // 3. Compact stats row
          _buildStatsRow(context, poem),
          const SizedBox(height: 20),

          // 4. More from this poet
          PoemMoreFromPoetSection(
            poetPublicId: poem.poetPublicId,
            poetName: poem.poetName,
            poetryType: poem.poetryType,
            currentPoemPublicId: poem.publicId,
            selectedScript: _selectedScript,
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Poet hero header
  // ────────────────────────────────────────────────────────────

  Widget _buildPoetHeader(BuildContext context, PoemModel poem) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = poem.poetProfileImageUrl != null &&
        poem.poetProfileImageUrl!.isNotEmpty &&
        poem.poetProfileImageUrl != '-';
    final initials = _poetInitials(poem.poetName);
    final typeLabel = poem.poetryTypeName ?? poem.poetryTypeUrduName ?? poem.poetryType;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => context.push('/main/poets/${poem.poetPublicId}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: ClipOval(
                  child: hasImage
                      ? CachedNetworkImage(
                          imageUrl: poem.poetProfileImageUrl!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _initialsWidget(initials),
                        )
                      : _initialsWidget(initials),
                ),
              ),
              const SizedBox(width: 12),

              // Name + type badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LocalizedText(
                      poem.poetName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                      ),
                      child: LocalizedText(
                        typeLabel,
                        style: const TextStyle(fontSize: 11, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initialsWidget(String initials) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _poetInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // ────────────────────────────────────────────────────────────
  // Compact stats row
  // ────────────────────────────────────────────────────────────

  Widget _buildStatsRow(BuildContext context, PoemModel poem) {
    final isLiked = poem.isLikedByCurrentUser ?? false;
    final parts = [
      '${_fmt(poem.viewCount)} views',
      '${_fmt(poem.likeCount)} likes',
      '${_fmt(poem.commentCount ?? 0)} comments',
      '${_fmt(poem.shareCount)} shares',
    ];

    return Text(
      parts.join('  •  '),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: isLiked ? AppColors.feedLiked.withValues(alpha: 0.85) : Colors.grey,
        height: 1.4,
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  // ────────────────────────────────────────────────────────────
  // Error state
  // ────────────────────────────────────────────────────────────

  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.red),
            const SizedBox(height: AppSpacing.lg),
            const Text('Failed to load poem'),
            const SizedBox(height: AppSpacing.md),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

}
