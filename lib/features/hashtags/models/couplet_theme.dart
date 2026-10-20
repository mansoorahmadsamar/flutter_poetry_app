import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../core/utils/api_placeholder.dart';
import '../utils/localized_name.dart';

/// At most this many theme chips are shown on a couplet. The server already
/// sends no more than three, filtered and in rank order; the app caps it too.
const int kMaxCoupletThemes = 3;

/// A theme a couplet is tagged with (`themes[]` on couplet objects: search,
/// hashtag and poem couplets, feed and guest couplet items).
///
/// The slug is an ordinary hashtag slug, so a theme opens `/hashtags/:slug`.
/// Production does not send `themes` yet; every model that carries it reads
/// absent, `null`, a non-list or junk entries as "no themes".
@immutable
class CoupletTheme {
  const CoupletTheme({
    required this.slug,
    this.nameUr,
    this.nameEn,
    this.nameHi,
    this.confidence,
  });

  final String slug;
  final String? nameUr;
  final String? nameEn;
  final String? nameHi;

  /// 0–1, as sent; informational only (the server already filtered).
  final double? confidence;

  /// One entry of `themes[]`, or null when it is not an object or has no
  /// usable slug (absent, blank or `"-"`). Names read `"-"` as absent.
  static CoupletTheme? tryParse(Object? json) {
    if (json is! Map) return null;
    final slug = _string(json['slug']);
    if (slug == null) return null;
    final confidence = json['confidence'];
    return CoupletTheme(
      slug: slug,
      nameUr: _string(json['nameUr']),
      nameEn: _string(json['nameEn']),
      nameHi: _string(json['nameHi']),
      confidence: confidence is num && confidence.isFinite
          ? confidence.toDouble()
          : null,
    );
  }

  static String? _string(Object? value) =>
      value is String ? presentOrNull(value) : null;

  /// The chip label in app language [appLanguage] (fallback Urdu, then
  /// English), or null when the theme has no name — the slug is never shown.
  LocalizedLabel? labelFor(String appLanguage) =>
      pickLocalizedName(appLanguage, ur: nameUr, en: nameEn, hi: nameHi);

  Map<String, dynamic> toJson() => {
        'slug': slug,
        if (nameUr != null) 'nameUr': nameUr,
        if (nameEn != null) 'nameEn': nameEn,
        if (nameHi != null) 'nameHi': nameHi,
        if (confidence != null) 'confidence': confidence,
      };

  @override
  bool operator ==(Object other) =>
      other is CoupletTheme &&
      other.slug == slug &&
      other.nameUr == nameUr &&
      other.nameEn == nameEn &&
      other.nameHi == nameHi &&
      other.confidence == confidence;

  @override
  int get hashCode => Object.hash(slug, nameUr, nameEn, nameHi, confidence);

  @override
  String toString() => 'CoupletTheme($slug)';
}

/// Reads `themes[]` tolerantly: anything but a list is no themes; entries that
/// are not objects or have no slug are dropped; a repeated slug keeps its
/// first entry; the server's order is kept.
List<CoupletTheme> parseCoupletThemes(Object? json) {
  if (json is! List) return const [];
  final seen = <String>{};
  final themes = <CoupletTheme>[];
  for (final entry in json) {
    final theme = CoupletTheme.tryParse(entry);
    if (theme != null && seen.add(theme.slug)) themes.add(theme);
  }
  return List.unmodifiable(themes);
}

/// `@CoupletThemesConverter()` for a `List<CoupletTheme> themes` field.
class CoupletThemesConverter
    implements JsonConverter<List<CoupletTheme>, Object?> {
  const CoupletThemesConverter();

  @override
  List<CoupletTheme> fromJson(Object? json) => parseCoupletThemes(json);

  @override
  Object? toJson(List<CoupletTheme> themes) =>
      [for (final theme in themes) theme.toJson()];
}
