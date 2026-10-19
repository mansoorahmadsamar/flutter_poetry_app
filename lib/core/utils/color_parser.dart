import 'dart:ui' show Color;

import 'api_placeholder.dart';

final RegExp _hexDigits = RegExp(r'^[0-9a-fA-F]+$');

/// Parses an API colour string into a [Color], returning [fallback] for
/// anything it cannot read.
///
/// Accepted forms (the leading `#` is optional): `#RGB`, `#RRGGBB` (opaque)
/// and `#AARRGGBB`. `null`, blank, the API's `"-"` placeholder and any other
/// input fall back — this never throws, so one bad colour cannot blank a row
/// of hashtags.
Color parseHexColor(String? raw, {required Color fallback}) {
  final value = presentOrNull(raw);
  if (value == null) return fallback;

  var hex = value.startsWith('#') ? value.substring(1) : value;
  if (!_hexDigits.hasMatch(hex)) return fallback;

  switch (hex.length) {
    case 3:
      hex = 'FF${hex.split('').map((digit) => '$digit$digit').join()}';
    case 6:
      hex = 'FF$hex';
    case 8:
      break;
    default:
      return fallback;
  }
  return Color(int.parse(hex, radix: 16));
}
