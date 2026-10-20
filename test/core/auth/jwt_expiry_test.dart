import 'dart:convert';

import 'package:flutter_poetry_app/core/auth/jwt_expiry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_jwt.dart';

void main() {
  final now = DateTime.utc(2026, 10, 19, 12);

  group('jwtExpiry', () {
    test('reads exp from a base64url payload without padding', () {
      final token = fakeJwt(exp: DateTime.utc(2027, 1, 1));
      expect(jwtExpiry(token), DateTime.utc(2027, 1, 1));
    });

    test('reads exp when the payload contains Urdu text and url-safe chars', () {
      // A display name in Urdu makes the base64 use '-'/'_' and multi-byte UTF-8.
      final payload = base64Url
          .encode(utf8.encode(jsonEncode({'name': 'جہانِ سخن؟؟>>', 'exp': 1800000000})))
          .replaceAll('=', '');
      expect(jwtExpiry('h.$payload.s'),
          DateTime.fromMillisecondsSinceEpoch(1800000000 * 1000, isUtc: true));
    });

    test('returns null for garbage, opaque tokens and missing exp', () {
      expect(jwtExpiry(''), isNull);
      expect(jwtExpiry('not-a-jwt'), isNull);
      expect(jwtExpiry('a.!!!.c'), isNull);
      final noExp = base64Url.encode(utf8.encode('{"sub":"1"}')).replaceAll('=', '');
      expect(jwtExpiry('h.$noExp.s'), isNull);
      final stringExp = base64Url.encode(utf8.encode('{"exp":"soon"}')).replaceAll('=', '');
      expect(jwtExpiry('h.$stringExp.s'), isNull);
      final notJson = base64Url.encode(utf8.encode('[1,2]')).replaceAll('=', '');
      expect(jwtExpiry('h.$notJson.s'), isNull);
    });
  });

  group('isJwtExpired', () {
    test('a token that expired yesterday is expired', () {
      expect(isJwtExpired(fakeJwt(exp: now.subtract(const Duration(days: 1))), now: now), isTrue);
    });

    test('a token valid for 100 more days is not expired', () {
      expect(isJwtExpired(fakeJwt(exp: now.add(const Duration(days: 100))), now: now), isFalse);
    });

    test('a token inside the leeway window counts as expired', () {
      expect(isJwtExpired(fakeJwt(exp: now.add(const Duration(seconds: 10))), now: now), isTrue);
    });

    test('an unreadable token is left for the server to judge', () {
      expect(isJwtExpired('garbage', now: now), isFalse);
    });
  });
}
