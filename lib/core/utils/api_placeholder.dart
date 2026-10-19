/// The API sends `"-"` in place of a missing string value (for example
/// `firstMisra`, `excerpt`, `era`, `thumbnailUrl`, `profileImageUrl`, `color`).
/// `"-"` is not null, so every reader must treat it as absent.
const String kApiMissingValue = '-';

/// Returns [value] trimmed, or `null` when it is null, blank or the API's
/// [kApiMissingValue] placeholder.
String? presentOrNull(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed == kApiMissingValue) return null;
  return trimmed;
}
