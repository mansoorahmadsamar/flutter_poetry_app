import 'package:json_annotation/json_annotation.dart';

/// The value the API sends for an absent string field (`firstMisra`, `era`,
/// `thumbnailUrl`, `profileImageUrl`, `color`, ids on search results, …).
/// It is not null, so it must be filtered before it is shown or used as an id.
const String kApiPlaceholder = '-';

/// [value] when it carries data; `null` for null, blank or [kApiPlaceholder].
String? presentOrNull(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed == kApiPlaceholder) return null;
  return value;
}

/// Reads an optional string field, treating null, blank, `"-"` and
/// non-string values as absent.
class PlaceholderStringConverter implements JsonConverter<String?, Object?> {
  const PlaceholderStringConverter();

  @override
  String? fromJson(Object? json) => json is String ? presentOrNull(json) : null;

  @override
  Object? toJson(String? value) => value;
}
