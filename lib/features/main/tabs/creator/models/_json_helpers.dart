/// API global convention: `"-"` represents null for nullable string fields
/// (Jackson serializer config — see FLUTTER_API_DOCUMENTATION.md §20).
/// Treat both `null` and `"-"` as Dart null so the UI never accidentally
/// renders the sentinel.
String? nullableStr(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  if (s.isEmpty || s == '-') return null;
  return s;
}

DateTime? parseApiDate(dynamic v) {
  final s = nullableStr(v);
  if (s == null) return null;
  return DateTime.tryParse(s);
}
