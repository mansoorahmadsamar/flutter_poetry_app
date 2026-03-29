import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/engagement/providers/reaction_providers.dart';
import '../models/poem_model.dart';
import '../models/couplet_model.dart';
import '../providers/poem_providers.dart';
import '../widgets/poem_more_from_poet_section.dart';
import '../widgets/poem_reading_card.dart';

const String _nastaleeq = 'Jameel Noori Nastaleeq';

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
      backgroundColor: const Color(0xFFF7F3EC), // warm parchment
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
            style: TextStyle(
              fontFamily: _selectedScript == 'ur' ? _nastaleeq : null,
              fontSize: _selectedScript == 'ur' ? 20 : 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined, size: 22),
              onPressed: () {},
            ),
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
    final couplets = poem.couplets.isNotEmpty ? poem.couplets : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 12, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPoetHeader(context, poem),
          const SizedBox(height: 12),
          PoemReadingCard(
            key: ValueKey(_selectedScript),
            poem: poem,
            couplets: couplets,
            selectedScript: _selectedScript,
            selectedSherIndex: _selectedSherIndex,
            onSherSelected: (i) => setState(() => _selectedSherIndex = i),
          ),
          const SizedBox(height: 14),
          _buildPoemEngagementBar(context, poem, couplets),
          const SizedBox(height: 20),
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
  // Poet header — minimal: name · era · years · flag badge
  // ────────────────────────────────────────────────────────────

  Widget _buildPoetHeader(BuildContext context, PoemModel poem) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final poet = poem.poet;

    final imageUrl = poet?.profileImageUrl ?? poem.poetProfileImageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty && imageUrl != '-';
    final initials = _poetInitials(poet?.name ?? poem.poetName);
    final poetName = poet?.name ?? poem.poetName;

    final eraLabel = _eraLabel(poet?.era);
    final years = _yearsLabel(poet?.birthYear, poet?.deathYear);
    final subParts = [if (eraLabel != null) eraLabel, if (years != null) years];
    final subLine = subParts.isNotEmpty ? subParts.join('  •  ') : null;

    final flag = poet?.countryFlag;

    return Container(
      decoration: BoxDecoration(
        // themed gradient background
        gradient: isDark
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF0EBE0), Color(0xFFE8F0EB)],
              ),
        color: isDark ? AppColors.surfaceDark : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFD4C9B6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => context.push('/main/poets/${poet?.publicId ?? poem.poetPublicId}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Avatar with gold ring
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary, width: 2),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  child: ClipOval(
                    child: hasImage
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _initialsWidget(initials),
                          )
                        : _initialsWidget(initials),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name + era/years
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      poetName,
                      style: TextStyle(
                        fontFamily: _nastaleeq,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFF0ECE6) : AppColors.textPrimaryLight,
                        height: 1.4,
                      ),
                    ),
                    if (subLine != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subLine,
                        style: TextStyle(
                          fontFamily: _nastaleeq,
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Country flag badge — unique presentation
              if (flag != null) ...[
                const SizedBox(width: 8),
                _buildFlagBadge(flag, isDark),
              ],

              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Flag displayed in a small rounded pill with a subtle border
  Widget _buildFlagBadge(String flag, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A3A3A) : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFD4C9B6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(flag, style: const TextStyle(fontSize: 20)),
    );
  }

  Widget _initialsWidget(String initials) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
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
  // Poem-level engagement bar
  // Aggregates across all couplets + poem-level reactions
  // ────────────────────────────────────────────────────────────

  Widget _buildPoemEngagementBar(BuildContext context, PoemModel poem, List<CoupletModel>? couplets) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Aggregate totals across all couplets
    int totalReactions = 0;
    int totalSaves = 0;
    int totalShares = 0;
    Map<String, int> aggregatedByType = {};

    // Poem-level reactions
    final poemTotal = (poem.reactions?['total'] as int?) ?? 0;
    totalReactions += poemTotal;
    if (poem.reactions?['byType'] != null) {
      final byType = Map<String, int>.from(poem.reactions!['byType'] as Map);
      byType.forEach((k, v) => aggregatedByType[k] = (aggregatedByType[k] ?? 0) + v);
    }

    // Couplet-level aggregation
    if (couplets != null) {
      for (final c in couplets) {
        final ct = (c.reactions?['total'] as int?) ?? 0;
        totalReactions += ct;
        totalSaves += c.bookmarkCount;
        totalShares += c.shareCount;
        if (c.reactions?['byType'] != null) {
          final byType = Map<String, int>.from(c.reactions!['byType'] as Map);
          byType.forEach((k, v) => aggregatedByType[k] = (aggregatedByType[k] ?? 0) + v);
        }
      }
    }

    // Also add poem-level saves/shares
    totalSaves += (poem.isBookmarkedByCurrentUser == true ? 1 : 0);
    totalShares += poem.shareCount;

    final reactionTypesAsync = ref.watch(reactionTypesProvider);
    final reactionTypes = reactionTypesAsync.valueOrNull ?? [];

    // Top 3 reaction emoji by count
    List<MapEntry<String, int>> topReactions = [];
    if (aggregatedByType.isNotEmpty) {
      topReactions = aggregatedByType.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      if (topReactions.length > 3) topReactions = topReactions.take(3).toList();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          // Section label
          Text(
            'غزل کا خلاصہ',
            style: TextStyle(
              fontFamily: _nastaleeq,
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 10),

          // Reactions row
          if (totalReactions > 0 || topReactions.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top reactions with individual counts
                ...topReactions.map((e) {
                  final rt = reactionTypes.isNotEmpty
                      ? reactionTypes.firstWhere(
                          (r) => r.key == e.key,
                          orElse: () => reactionTypes.first,
                        )
                      : null;
                  final emoji = rt?.emoji ?? '❤️';
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 2),
                        Text(
                          _fmt(e.value),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                // If no byType data but we have a total
                if (topReactions.isEmpty && totalReactions > 0) ...[
                  const Text('❤️', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 6),
                  Text(
                    _fmt(totalReactions),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, thickness: 0.5, color: AppColors.dividerLight),
            const SizedBox(height: 10),
          ],

          // Saves • Views • Shares
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statItem(Icons.visibility_outlined, _fmt(poem.viewCount), isDark),
              _dividerDot(isDark),
              _statItem(Icons.bookmark_border, _fmt(totalSaves), isDark),
              _dividerDot(isDark),
              _statItem(Icons.share_outlined, _fmt(totalShares), isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String label, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _dividerDot(bool isDark) {
    return Text(
      '·',
      style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
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
