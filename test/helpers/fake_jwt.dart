import 'dart:convert';

/// Builds an unsigned JWT-shaped string whose payload carries [exp].
/// The app only ever reads `exp`; the signature is the server's business.
String fakeJwt({required DateTime exp, String subject = '42'}) {
  String part(Map<String, Object?> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  return [
    part({'alg': 'HS256', 'typ': 'JWT'}),
    part({'sub': subject, 'exp': exp.millisecondsSinceEpoch ~/ 1000}),
    'signature',
  ].join('.');
}
