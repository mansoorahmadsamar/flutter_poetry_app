import '../models/discover_bundle_model.dart';

/// [queries] ordered by `searchCount`, highest first; equal counts keep the
/// server's order (stable).
///
/// The backend already sends trending searches by count, descending (an
/// Elasticsearch `terms` aggregation in `SearchAnalyticsService
/// .getTrendingSearches`, main and develop; production 2026-10-20: Ghazal 85,
/// Nazam 74, Naat 57, Rubai 37). The chips' numbers are ranks (1–4), not
/// counts (T-180). Sorting here keeps the chips in count order if a backend
/// change ever stops guaranteeing it.
List<TrendingQuery> byCountDescending(List<TrendingQuery> queries) {
  final indexed = queries.indexed.toList()
    ..sort((a, b) {
      final byCount = b.$2.searchCount.compareTo(a.$2.searchCount);
      return byCount != 0 ? byCount : a.$1.compareTo(b.$1);
    });
  return [for (final (_, query) in indexed) query];
}
