import 'dart:convert';

/// How close to its `exp` a token is treated as already expired, so a request
/// sent "just in time" doesn't arrive at the server a second too late.
const Duration jwtExpiryLeeway = Duration(seconds: 30);

/// Reads the `exp` claim of a JWT without verifying it.
///
/// Returns null when [token] is not a JWT or has no numeric `exp`. The
/// signature is the server's concern; the app only needs to know whether a
/// stored token is worth sending.
DateTime? jwtExpiry(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final claims = jsonDecode(payload);
    if (claims is! Map) return null;
    final exp = claims['exp'];
    if (exp is! num) return null;
    return DateTime.fromMillisecondsSinceEpoch(
      (exp * 1000).round(),
      isUtc: true,
    );
  } on FormatException {
    return null;
  }
}

/// True only when [token] carries an `exp` that is at or before [now]
/// (plus [leeway]).
///
/// A token whose expiry can't be read is NOT reported as expired: the server
/// still decides (it answers 401), and the 401 path handles it.
bool isJwtExpired(
  String token, {
  required DateTime now,
  Duration leeway = jwtExpiryLeeway,
}) {
  final exp = jwtExpiry(token);
  if (exp == null) return false;
  return !now.toUtc().add(leeway).isBefore(exp);
}
