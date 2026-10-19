import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';

/// Which part of a [UnifiedSearchResponse] each results tab shows, how it
/// pages (`type=…_only`) and how a further page is merged — one definition
/// for the notifier, the tab bar and the filtered list.
///
/// [DiscoverSegment.all] is the grouped preview: it has no list of its own and
/// does not page.
extension SearchSegmentResults on DiscoverSegment {
  /// The `/api/search` `type` that pages this tab.
  String get apiType => switch (this) {
        DiscoverSegment.all => 'all',
        DiscoverSegment.poets => 'poets_only',
        DiscoverSegment.poems => 'poems_only',
        DiscoverSegment.verses => 'couplets_only',
        DiscoverSegment.misras => 'verses_only',
        DiscoverSegment.categories => 'categories_only',
      };

  /// Items of this tab loaded so far.
  int loadedCount(UnifiedSearchResponse r) => switch (this) {
        DiscoverSegment.all => 0,
        DiscoverSegment.poets => r.poets.length,
        DiscoverSegment.poems => r.poems.length,
        DiscoverSegment.verses => r.couplets.length,
        DiscoverSegment.misras => r.verses.length,
        DiscoverSegment.categories => r.categories.length,
      };

  /// Matches in the database (for the tab label and list header).
  int total(UnifiedSearchResponse r) => switch (this) {
        DiscoverSegment.all => 0,
        DiscoverSegment.poets => r.totalPoets,
        DiscoverSegment.poems => r.totalPoems,
        DiscoverSegment.verses => r.totalCouplets,
        DiscoverSegment.misras => r.totalVerses,
        DiscoverSegment.categories => r.totalCategories,
      };

  /// Whether the backend has another page for this tab.
  bool hasMore(UnifiedSearchResponse r) => switch (this) {
        DiscoverSegment.all => false,
        DiscoverSegment.poets => r.hasMorePoets,
        DiscoverSegment.poems => r.hasMorePoems,
        DiscoverSegment.verses => r.hasMoreCouplets,
        DiscoverSegment.misras => r.hasMoreVerses,
        DiscoverSegment.categories => r.hasMoreCategories,
      };

  /// [existing] with [page]'s items for this tab appended. Items already
  /// loaded (same id on two pages) are skipped, and a page that adds nothing
  /// new ends paging so the list cannot request the same page forever.
  UnifiedSearchResponse merge(
    UnifiedSearchResponse existing,
    UnifiedSearchResponse page,
  ) {
    switch (this) {
      case DiscoverSegment.all:
        return existing;
      case DiscoverSegment.poets:
        final items = _appendNew(existing.poets, page.poets, (p) => p.publicId);
        return existing.copyWith(
          poets: items,
          hasMorePoets: _stillMore(page.hasMorePoets, existing.poets, items),
        );
      case DiscoverSegment.poems:
        final items = _appendNew(existing.poems, page.poems, (p) => p.publicId);
        return existing.copyWith(
          poems: items,
          hasMorePoems: _stillMore(page.hasMorePoems, existing.poems, items),
        );
      case DiscoverSegment.verses:
        final items =
            _appendNew(existing.couplets, page.couplets, (c) => c.publicId);
        return existing.copyWith(
          couplets: items,
          hasMoreCouplets:
              _stillMore(page.hasMoreCouplets, existing.couplets, items),
        );
      case DiscoverSegment.misras:
        final items =
            _appendNew(existing.verses, page.verses, (v) => v.resultKey);
        return existing.copyWith(
          verses: items,
          hasMoreVerses: _stillMore(page.hasMoreVerses, existing.verses, items),
        );
      case DiscoverSegment.categories:
        final items =
            _appendNew(existing.categories, page.categories, (c) => c.publicId);
        return existing.copyWith(
          categories: items,
          hasMoreCategories:
              _stillMore(page.hasMoreCategories, existing.categories, items),
        );
    }
  }
}

List<T> _appendNew<T>(List<T> existing, List<T> page, String Function(T) id) {
  final seen = {for (final item in existing) id(item)};
  return [
    ...existing,
    for (final item in page)
      if (seen.add(id(item))) item,
  ];
}

bool _stillMore(bool pageHasMore, List<Object?> before, List<Object?> after) =>
    pageHasMore && after.length > before.length;
