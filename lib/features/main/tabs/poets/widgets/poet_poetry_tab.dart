import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/auth/auth_provider.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/features/auth/widgets/sign_in_prompt_sheet.dart';
import '../models/poem_model.dart';
import '../providers/poem_providers.dart';
import 'poem_card.dart';
import 'poetry_section_header.dart';
import 'poem_preview_bottom_sheet.dart';

class PoetPoetryTab extends ConsumerStatefulWidget {
  final String publicId;

  const PoetPoetryTab({super.key, required this.publicId});

  @override
  ConsumerState<PoetPoetryTab> createState() => _PoetPoetryTabState();
}

/// Inline CTA shown when a guest opens a poet's Poetry tab. The guest API
/// surface has no per-poet poem listing, so we tell the user signing in
/// unlocks the full back-catalog.
class _GuestPoemsCta extends StatelessWidget {
  final String? poetName;
  const _GuestPoemsCta({this.poetName});

  @override
  Widget build(BuildContext context) {
    final who = poetName != null ? 'by $poetName' : 'by this poet';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_outlined,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sign in to see all poems $who',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Browse the full back-catalog, follow the poet for new releases, and save what you love.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Color(0xFF5C5C5C),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => SignInPromptSheet.show(
                context,
                reason: 'Sign in to see all poems $who',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Center(
                child: Text(
                  'Sign in',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PoetPoetryTabState extends ConsumerState<PoetPoetryTab> {
  // Track expanded sections (default all expanded)
  final Map<String, bool> _expandedSections = {};

  // Poetry types to fetch
  final List<String> _poetryTypes = [
    'GHAZAL',
    'NAZAM',
    'VERSE',
    'RUBAI',
    'AZAD_NAZAM',
  ];

  // Store loaded poems per type
  final Map<String, List<PoemModel>> _poemsByType = {};

  @override
  void initState() {
    super.initState();
    // Initialize all sections as expanded
    for (final type in _poetryTypes) {
      _expandedSections[type] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = ref.watch(authProvider).isGuest;

    // For guests, the guest API has no `/poems/poet/{id}` endpoint, so the
    // per-poetry-type sections will all be empty. Surface an inline CTA at
    // the top instead — guideline 5.1.1(v)-friendly: the tab is reachable,
    // there's a clear next step, no error state. Authed users see the
    // normal per-type sections.
    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        if (isGuest) _GuestPoemsCta(poetName: null),
        if (!isGuest)
          ..._poetryTypes.map(_buildPoetryTypeSection),
      ],
    );
  }

  Widget _buildPoetryTypeSection(String poetryType) {
    // Get current page for this poetry type
    final pagesMap = ref.watch(poemPagesProvider(widget.publicId));
    final currentPage = pagesMap[poetryType] ?? 0;

    // Fetch poems for this type and page
    final poemsAsync = ref.watch(poetPoemsProvider((
      poetPublicId: widget.publicId,
      poetryType: poetryType,
      page: currentPage,
    )));

    return poemsAsync.when(
      data: (response) {
        // Update cached poems
        if (currentPage == 0) {
          _poemsByType[poetryType] = response.content;
        } else if (_poemsByType[poetryType] != null) {
          // Add new poems to existing list, avoiding duplicates
          final existingIds = _poemsByType[poetryType]!
              .map((p) => p.publicId)
              .toSet();
          final newPoems = response.content
              .where((p) => !existingIds.contains(p.publicId))
              .toList();
          _poemsByType[poetryType]!.addAll(newPoems);
        } else {
          _poemsByType[poetryType] = response.content;
        }

        final poems = _poemsByType[poetryType] ?? [];
        final isExpanded = _expandedSections[poetryType] ?? true;
        final hasMore = !response.last;

        // Don't show section if no poems
        if (response.totalElements == 0) {
          return SizedBox.shrink();
        }

        return Column(
          children: [
            // Section header
            PoetrySectionHeader(
              poetryType: poetryType,
              count: response.totalElements,
              isExpanded: isExpanded,
              onToggle: () => _toggleSection(poetryType),
            ),

            // Section content
            if (isExpanded) ...[
              ...poems.map((poem) => PoemCard(
                poem: poem,
                onTap: () => _showPoemBottomSheet(context, poem.publicId),
              )),

              // Load More button
              if (hasMore)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: OutlinedButton.icon(
                    onPressed: () => _loadMorePoems(poetryType),
                    icon: Icon(Icons.expand_more),
                    label: Text('Load More ${_getTypeLabel(poetryType)}'),
                  ),
                ),
            ],

            SizedBox(height: AppSpacing.lg),
          ],
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Card(
          color: Colors.red[50],
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Error loading $poetryType poems',
                  style: TextStyle(color: Colors.red[900]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleSection(String poetryType) {
    setState(() {
      _expandedSections[poetryType] = !(_expandedSections[poetryType] ?? true);
    });
  }

  void _loadMorePoems(String poetryType) {
    final pagesMap = ref.read(poemPagesProvider(widget.publicId));
    final currentPage = pagesMap[poetryType] ?? 0;

    // Update the page number
    ref.read(poemPagesProvider(widget.publicId).notifier).state = {
      ...pagesMap,
      poetryType: currentPage + 1,
    };
  }

  void _showPoemBottomSheet(BuildContext context, String poemPublicId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PoemPreviewBottomSheet(poemPublicId: poemPublicId),
    );
  }

  String _getTypeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'GHAZAL': return 'Ghazals';
      case 'NAZAM': return 'Nazams';
      case 'VERSE': return 'Verses';
      case 'RUBAI': return 'Rubais';
      case 'AZAD_NAZAM': return 'Azad Nazams';
      default: return type;
    }
  }
}
