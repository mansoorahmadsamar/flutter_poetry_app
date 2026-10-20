import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/portrait.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poet_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/providers/poet_providers.dart';

/// Claim flow — search yourself.
/// First match is highlighted with a gold "BEST MATCH" ribbon per the design.
class ClaimPoetSearchScreen extends ConsumerStatefulWidget {
  const ClaimPoetSearchScreen({super.key});

  @override
  ConsumerState<ClaimPoetSearchScreen> createState() =>
      _ClaimPoetSearchScreenState();
}

class _ClaimPoetSearchScreenState extends ConsumerState<ClaimPoetSearchScreen> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  List<PoetModel> _results = const [];
  bool _loading = false;
  bool _searched = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() {
        _results = const [];
        _searched = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(value.trim()));
  }

  Future<void> _search(String q) async {
    setState(() => _loading = true);
    try {
      final svc = ref.read(poetServiceProvider);
      final res = await svc.searchPoets(query: q, page: 0, size: 10);
      if (!mounted) return;
      setState(() {
        _results = res.content;
        _loading = false;
        _searched = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _results = const [];
        _loading = false;
        _searched = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _appBar(),
      body: Column(
        children: [
          _header(),
          _searchField(),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          if (!_loading)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  for (var i = 0; i < _results.length; i++) ...[
                    _MatchTile(
                      poet: _results[i],
                      isBestMatch: i == 0 && _results.length > 1,
                      onTap: () => context
                          .push('/main/become-poet/claim/${_results[i].publicId}'),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (!_searched)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Center(
                        child: Text(
                          'Type your name above to search',
                          style: SukhanText.italic(
                            size: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ),
                  if (_searched && _results.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: _NotHereCard(
                        onTap: () =>
                            context.go('/main/become-poet/new'),
                      ),
                    )
                  else if (_results.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: _NotHereCard(
                        onTap: () =>
                            context.go('/main/become-poet/new'),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: AppColors.paperSurface,
      surfaceTintColor: AppColors.paperSurface,
      foregroundColor: AppColors.textPrimaryLight,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Find your page',
              style: SukhanText.display(
                size: 17,
                color: AppColors.textPrimaryLight,
                weight: FontWeight.w600,
                height: 1.1,
                letterSpacing: -0.17,
              )),
          Text('اپنا صفحہ تلاش کریں',
              textDirection: TextDirection.rtl,
              style: SukhanText.nastaleeq(
                size: 12,
                color: AppColors.textSecondaryLight,
              )),
        ],
      ),
      titleSpacing: 0,
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STEP 1 · CLAIM',
            style: SukhanText.eyebrow(color: AppColors.secondary),
          ),
          const SizedBox(height: 6),
          Text(
            'Search by your name',
            style: SukhanText.display(
              size: 22,
              color: AppColors.textPrimaryLight,
              weight: FontWeight.w500,
              letterSpacing: -0.22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.search, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _ctrl,
                onChanged: _onChanged,
                style: SukhanText.sans(
                  size: 14,
                  color: AppColors.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Hamza Qadir / حمزہ',
                  hintStyle: SukhanText.sans(
                    size: 14,
                    color: AppColors.inkSubtle,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_results.isNotEmpty)
              Text(
                '${_results.length} matches',
                style: SukhanText.eyebrow(
                  size: 10,
                  color: AppColors.inkSubtle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({
    required this.poet,
    required this.isBestMatch,
    required this.onTap,
  });

  final PoetModel poet;
  final bool isBestMatch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initialChar = poet.name.isEmpty
        ? 'م'
        : String.fromCharCode(poet.name.runes.first);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isBestMatch ? AppColors.secondary : AppColors.dividerLight,
                  width: isBestMatch ? 1.5 : 1,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  Portrait(
                    size: 48,
                    initial: initialChar,
                    hue: isBestMatch ? PortraitHue.gold : PortraitHue.green,
                    ring: isBestMatch,
                    imageUrl: poet.profileImageUrl,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          poet.name,
                          textDirection: TextDirection.rtl,
                          style: SukhanText.nastaleeq(
                            size: 17,
                            color: AppColors.textPrimaryLight,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${poet.birthYear > 0 ? poet.birthYear : ""}${poet.deathYear > 0 ? " – ${poet.deathYear}" : poet.birthYear > 0 ? " – " : ""}',
                          style: SukhanText.italic(
                            size: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.menu_book_outlined,
                                size: 11, color: AppColors.inkSubtle),
                            const SizedBox(width: 4),
                            Text(
                              '${poet.poemCount} poems on Sukhan',
                              style: SukhanText.sans(
                                size: 11,
                                color: AppColors.inkSubtle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '›',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      color: isBestMatch
                          ? AppColors.secondary
                          : AppColors.inkSubtle,
                    ),
                  ),
                ],
              ),
            ),
            if (isBestMatch)
              Positioned(
                top: -8,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'BEST MATCH',
                    style: SukhanText.eyebrow(
                      color: AppColors.backgroundLight,
                      size: 9,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotHereCard extends StatelessWidget {
  const _NotHereCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: AppColors.paperSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Row(
            children: [
              const Icon(Icons.add, size: 16, color: AppColors.textSecondaryLight),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Not here?',
                        style: SukhanText.sans(
                          size: 13,
                          weight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        )),
                    const SizedBox(height: 1),
                    Text('Start a new poet page instead',
                        style: SukhanText.italic(
                          size: 11,
                          color: AppColors.textSecondaryLight,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
