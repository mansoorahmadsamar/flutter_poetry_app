import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/core/widgets/localized_text.dart';
import 'package:flutter_poetry_app/features/engagement/providers/reaction_providers.dart';
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
  String _selectedScript = 'ur';
  bool _scriptInitialized = false;
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
    // Use embedded couplets from v1.6.0 response — no separate provider needed.
    // null = no couplets at all (trigger fullText fallback in reading card)
    final couplets = poem.couplets.isNotEmpty ? poem.couplets : null;

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

          // 3. Stats + reactions row
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
  // Poet hero header — uses v1.6.0 embedded poet object
  // ────────────────────────────────────────────────────────────

  Widget _buildPoetHeader(BuildContext context, PoemModel poem) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final poet = poem.poet;

    // Avatar source — prefer embedded poet.profileImageUrl
    final imageUrl = poet?.profileImageUrl ?? poem.poetProfileImageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty && imageUrl != '-';
    final initials = _poetInitials(poet?.name ?? poem.poetName);

    // Sub-info line: era • years
    final eraLabel = _eraLabel(poet?.era);
    final years = _yearsLabel(poet?.birthYear, poet?.deathYear);
    final subParts = [if (eraLabel != null) eraLabel, if (years != null) years];
    final subLine = subParts.isNotEmpty ? subParts.join('  •  ') : null;

    // Tags + poem count bottom row
    final topTags = poet?.topTags ?? [];
    final poemCount = poet?.poemCount;
    final showBottomRow = topTags.isNotEmpty || poemCount != null;

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
        onTap: () => context.push('/main/poets/${poet?.publicId ?? poem.poetPublicId}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    child: ClipOval(
                      child: hasImage
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => _initialsWidget(initials),
                            )
                          : _initialsWidget(initials),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name + meta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: LocalizedText(
                                poet?.name ?? poem.poetName,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (poet?.countryFlag != null) ...[
                              const SizedBox(width: 6),
                              Text(poet!.countryFlag!, style: const TextStyle(fontSize: 18)),
                            ],
                          ],
                        ),
                        if (subLine != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subLine,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              height: 1.3,
                            ),
                          ),
                        ],
                        if (poet != null && poet.shortBio != null && poet.shortBio!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            poet.shortBio!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                ],
              ),

              // Tags + poem count row
              if (showBottomRow) ...[
                const SizedBox(height: 10),
                const Divider(height: 1, thickness: 0.5, color: AppColors.dividerLight),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ...topTags.take(3).map((tag) => _tagChip(tag, isDark)),
                    const Spacer(),
                    if (poemCount != null)
                      Text(
                        '$poemCount نظمیں',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _tagChip(String tag, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
      ),
      child: Text(
        tag,
        style: const TextStyle(fontSize: 11, color: AppColors.primary),
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

  String? _eraLabel(String? era) => switch (era) {
    'CLASSICAL' => 'کلاسیکی',
    'MODERN' => 'جدید',
    'CONTEMPORARY' => 'معاصر',
    'SUFI' => 'صوفی',
    'MEDIEVAL' => 'قرون وسطیٰ',
    'ROMANTIC' => 'رومانوی',
    _ => era,
  };

  String? _yearsLabel(int? birth, int? death) {
    if (birth == null) return null;
    if (death != null) return '$birth–$death';
    return '$birth–';
  }

  // ────────────────────────────────────────────────────────────
  // Stats + reactions row
  // ────────────────────────────────────────────────────────────

  Widget _buildStatsRow(BuildContext context, PoemModel poem) {
    final reactionsMap = poem.reactions;
    final total = (reactionsMap?['total'] as int?) ?? 0;
    final byType = reactionsMap?['byType'] != null
        ? Map<String, int>.from(reactionsMap!['byType'] as Map)
        : null;

    return Column(
      children: [
        if (total > 0) _buildReactionSummary(context, total, byType),
        const SizedBox(height: 6),
        Text(
          '${_fmt(poem.viewCount)} مناظر  •  ${_fmt(poem.shareCount)} شیئر',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildReactionSummary(BuildContext context, int total, Map<String, int>? byType) {
    final reactionTypesAsync = ref.watch(reactionTypesProvider);
    final reactionTypes = reactionTypesAsync.valueOrNull ?? [];

    // Top 3 emoji by count
    List<String> topEmoji = [];
    if (byType != null && byType.isNotEmpty && reactionTypes.isNotEmpty) {
      final sorted = byType.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      topEmoji = sorted.take(3).map((e) {
        return reactionTypes.firstWhere(
          (r) => r.key == e.key,
          orElse: () => reactionTypes.first,
        ).emoji;
      }).toList();
    }
    if (topEmoji.isEmpty) topEmoji = ['❤️'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: topEmoji.length * 20.0 + 4,
          height: 28,
          child: Stack(
            children: [
              for (int i = 0; i < topEmoji.length; i++)
                Positioned(
                  left: i * 16.0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Center(
                      child: Text(topEmoji[i], style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${_fmt(total)} ردعمل',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
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

