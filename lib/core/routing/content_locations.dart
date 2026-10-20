import '../utils/api_placeholder.dart';

/// Locations of the content screens that cards link to, built in one place.
///
/// `/main/poems/:publicId` takes an optional `?couplet=<coupletNumber>`: the
/// poem opens scrolled to that couplet, highlighted. The number is the
/// couplet's position in its poem (`coupletNumber`), the same in every script,
/// so one link works in Urdu, Roman and Devanagari. A link without it (every
/// link before this change) opens the poem at the top, as before.
abstract final class ContentLocations {
  /// Query parameter of the poem route naming the couplet to open at.
  static const String coupletParam = 'couplet';

  /// `/main/poems/<poemPublicId>`, plus `?couplet=<n>` when [coupletNumber]
  /// is a real couplet number (positive).
  static String poem(String poemPublicId, {int? coupletNumber}) {
    final query = poemQuery(coupletNumber);
    return Uri(
      path: '/main/poems/$poemPublicId',
      queryParameters: query.isEmpty ? null : query,
    ).toString();
  }

  /// The poem route's query parameters for [coupletNumber]: empty when it is
  /// null or not positive. For `pushNamed(..., queryParameters: ...)`.
  static Map<String, String> poemQuery(int? coupletNumber) {
    final number = positiveIntOrNull(coupletNumber);
    return number == null ? const {} : {coupletParam: '$number'};
  }

  /// The couplet number a poem route was opened with, or null when the link
  /// has none, or it is not a positive whole number (`?couplet=abc`, `0`).
  static int? coupletFrom(Map<String, String> queryParameters) =>
      positiveIntOrNull(queryParameters[coupletParam]);

  /// `/hashtags/<slug>`, with the slug percent-encoded (some slugs are Urdu
  /// script or contain spaces).
  static String hashtag(String slug) =>
      '/hashtags/${Uri.encodeComponent(slug)}';
}
