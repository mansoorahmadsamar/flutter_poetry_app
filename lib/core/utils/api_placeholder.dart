import 'package:json_annotation/json_annotation.dart';

/// The value the API sends for an absent string field (`firstMisra`,
/// `excerpt`, `era`, `thumbnailUrl`, `profileImageUrl`, `color`, ids on
/// search results, …). It is not null, so every reader must treat it as
/// absent before it is shown or used as an id.
const String kApiPlaceholder = '-';

/// Returns [value] trimmed, or `null` when it is null, blank or the API's
/// [kApiPlaceholder].
String? presentOrNull(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed == kApiPlaceholder) return null;
  return trimmed;
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

/// Returns [value] as an int when it is a positive whole number (an `int`, a
/// whole finite `double` or a numeric string), otherwise `null`. Production sends a
/// null `Integer` as `0`, so `0` reads as absent too — e.g. a couplet number
/// the backend does not know.
int? positiveIntOrNull(Object? value) {
  final int? parsed = switch (value) {
    int v => v,
    double v when v.isFinite && v == v.truncateToDouble() => v.toInt(),
    String v => int.tryParse(v.trim()),
    _ => null,
  };
  return parsed != null && parsed > 0 ? parsed : null;
}

/// Reads an optional positive int (see [positiveIntOrNull]): `0`, negative,
/// fractional, `"-"` and non-numeric values are absent.
class PositiveIntConverter implements JsonConverter<int?, Object?> {
  const PositiveIntConverter();

  @override
  int? fromJson(Object? json) => positiveIntOrNull(json);

  @override
  Object? toJson(int? value) => value;
}
