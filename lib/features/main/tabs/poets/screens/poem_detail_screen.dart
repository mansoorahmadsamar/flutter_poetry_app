import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/engagement/providers/bookmark_providers.dart';
import 'package:flutter_poetry_app/features/engagement/providers/reaction_providers.dart';
import 'package:flutter_poetry_app/features/engagement/widgets/reaction_button.dart';
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
  // ────────────────────────────────────────────────────────────

  Widget _buildPoemEngagementBar(BuildContext context, PoemModel poem, List<CoupletModel>? couplets) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Aggregate across poem + all couplets ──
    int totalSaves = poem.shareCount; // poem-level shares counted here
    int totalShares = poem.shareCount;
    Map<String, int> aggregatedByType = {};

    // poem-level reactions
    if (poem.reactions?['byType'] != null) {
      final byType = Map<String, int>.from(poem.reactions!['byType'] as Map);
      byType.forEach((k, v) => aggregatedByType[k] = (aggregatedByType[k] ?? 0) + v);
    }

    // couplet-level aggregation
    if (couplets != null) {
      for (final c in couplets) {
        totalSaves += c.bookmarkCount;
        totalShares += c.shareCount;
        if (c.reactions?['byType'] != null) {
          final byType = Map<String, int>.from(c.reactions!['byType'] as Map);
          byType.forEach((k, v) => aggregatedByType[k] = (aggregatedByType[k] ?? 0) + v);
        }
      }
    }

    final totalReactions = aggregatedByType.values.fold(0, (s, v) => s + v);

    final reactionTypes = ref.watch(reactionTypesProvider).valueOrNull ?? [];

    // ── Pick top-3, break ties randomly ──
    List<MapEntry<String, int>> topReactions = [];
    if (aggregatedByType.isNotEmpty) {
      final sorted = aggregatedByType.entries.toList()
        ..sort((a, b) {
          final cmp = b.value.compareTo(a.value);
          if (cmp != 0) return cmp;
          // tie-break: stable random via hashCode so it doesn't flicker
          return a.key.hashCode.compareTo(b.key.hashCode);
        });
      topReactions = sorted.take(3).toList();
    }

    final isBookmarked = poem.isBookmarkedByCurrentUser ?? false;
    final userReaction = poem.reactions?['userReaction'] as String?;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        children: [
          // ── Section label ──
          Text(
            'غزل کا خلاصہ',
            style: TextStyle(
              fontFamily: _nastaleeq,
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),

          // ── Reaction summary row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: topReactions.isNotEmpty
                ? topReactions.map((e) {
                    final rt = reactionTypes.isNotEmpty
                        ? reactionTypes.firstWhere(
                            (r) => r.key == e.key,
                            orElse: () => reactionTypes.first,
                          )
                        : null;
                    final emoji = rt?.emoji ?? '❤️';
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 3),
                          Text(
                            _fmt(e.value),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList()
                // No reactions yet — show placeholder heart without count
                : [const Text('❤️', style: TextStyle(fontSize: 24))],
          ),

          // Total count below emoji row (only when > 0)
          if (totalReactions > 0) ...[
            const SizedBox(height: 4),
            Text(
              '${_fmt(totalReactions)} ردعمل',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5, color: AppColors.dividerLight),
          const SizedBox(height: 10),

          // ── Stats row: views · saves · shares ──
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

          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5, color: AppColors.dividerLight),
          const SizedBox(height: 8),

          // ── Poem-level actions: React · Save · Share ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // React to whole poem
              ReactionButton(
                userReaction: userReaction,
                totalCount: (poem.reactions?['total'] as int?) ?? 0,
                reactionsByType: poem.reactions?['byType'] != null
                    ? Map<String, int>.from(poem.reactions!['byType'] as Map)
                    : null,
                size: ReactionButtonSize.compact,
                onReact: (reactionType) async {
                  try {
                    await ref.read(reactionActionProvider.notifier).react(
                          targetType: 'poems',
                          publicId: poem.publicId,
                          reactionType: reactionType,
                        );
                  } catch (_) {}
                },
              ),

              // Save / bookmark poem
              InkWell(
                onTap: () async {
                  try {
                    await ref.read(bookmarkActionProvider.notifier)
                        .toggleBookmark(poem.publicId, lang: _selectedScript);
                  } catch (_) {}
                },
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    size: 22,
                    color: isBookmarked ? AppColors.primary : AppColors.textSecondaryLight,
                  ),
                ),
              ),

              // Share poem
              InkWell(
                onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => _PoemShareSheet(poem: poem),
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Icon(
                    Icons.share_outlined,
                    size: 22,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Poem-level share sheet
// ─────────────────────────────────────────────────────────────────────────────

class _PoemShareSheet extends StatelessWidget {
  final PoemModel poem;

  const _PoemShareSheet({required this.poem});

  @override
  Widget build(BuildContext context) {
    final title = poem.title ?? poem.contents.firstOrNull?.title ?? '';
    final excerpt = poem.excerpt ?? poem.contents.firstOrNull?.fullText.split('\n').take(4).join('\n') ?? '';
    final shareText = title.isNotEmpty ? '$title\n\n$excerpt' : excerpt;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'شعر شیئر کریں',
              style: TextStyle(
                fontFamily: _nastaleeq,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            _ShareOption(
              icon: Icons.copy_outlined,
              label: 'متن کاپی کریں',
              onTap: () {
                Navigator.pop(context);
                // Copy poem text to clipboard
                final clipboardData = ClipboardData(text: shareText);
                Clipboard.setData(clipboardData);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('کاپی ہو گیا'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            _ShareOption(
              icon: Icons.image_outlined,
              label: 'تصویر کے طور پر شیئر کریں',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('جلد آ رہا ہے'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontFamily: _nastaleeq,
                fontSize: 16,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
