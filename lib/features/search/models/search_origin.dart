/// Why a `/api/search` request was made, sent as the `origin` query parameter
/// (T-183). The backend logs every `/api/search` call as a search that feeds
/// trending searches; with the origin it can tell a typed search from a tap
/// on a UI shortcut. Released backends ignore the extra parameter
/// (`SearchController.search` on `main` binds only q, type, lang, script,
/// page, size).
enum SearchOrigin {
  /// The user typed a query and submitted it (keyboard search, or the
  /// "Search for …" row under the suggestions).
  typed,

  /// The user tapped an autocomplete suggestion that runs a text search.
  suggestion,

  /// The user tapped one of their recent searches.
  history,

  /// The user tapped a trending-search chip.
  trending,

  /// Any other UI shortcut: a genre/category/hashtag chip, a related search,
  /// a category result.
  browse;

  /// The `/api/search` query parameter that carries the origin.
  static const queryParameter = 'origin';

  /// The value sent to the backend.
  String get apiValue => name;

  /// Parses [value] (an [apiValue]); null when absent or unknown.
  static SearchOrigin? tryParse(Object? value) {
    for (final origin in values) {
      if (origin.apiValue == value) return origin;
    }
    return null;
  }
}

/// The `extra` map of the `/search` route: the query to run on open and why.
abstract final class SearchRouteExtra {
  static const query = 'query';
  static const origin = 'origin';

  /// `extra` for `context.push('/search', extra: …)` that searches [text] at
  /// once, logged with [searchOrigin].
  static Map<String, Object> of(String text, SearchOrigin searchOrigin) =>
      {query: text, origin: searchOrigin.apiValue};

  /// The origin in a `/search` route's [extra]. A query that arrives without
  /// one comes from a UI shortcut, so it defaults to [SearchOrigin.browse].
  static SearchOrigin originOf(Map<String, dynamic>? extra) =>
      SearchOrigin.tryParse(extra?[origin]) ?? SearchOrigin.browse;
}
