import 'package:flutter_poetry_app/core/models/user_model.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('UserModel.fromJson (GET /api/auth/me, T-181)', () {
    test('regression: null fullName/username/provider/isActive parse', () {
      final response = ApiResponse.fromJson(
        loadJsonFixture('auth/me_null_name.json'),
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
      final user = response.data!;
      expect(user.fullName, isNull);
      expect(user.username, isNull);
      expect(user.provider, isNull);
      expect(user.profileImageUrl, isNull);
      expect(user.isActive, isTrue);
      expect(user.displayName, 'reader', reason: 'falls back to the email');
      expect(user.handle, isNull);
    });

    test('missing fields and "-" read as absent', () {
      final user = UserModel.fromJson(const {
        'id': 'u1',
        'email': 'a@b.c',
        'fullName': '-',
        'profileImageUrl': '-',
      });
      expect(user.fullName, isNull);
      expect(user.profileImageUrl, isNull);
      expect(user.isActive, isTrue);
    });

    test('a complete user (Urdu name)', () {
      final user = UserModel.fromJson(const {
        'id': 'u1',
        'email': 'a@b.c',
        'fullName': 'منصور احمد',
        'username': 'mansoor',
        'profileImageUrl': 'https://img.test/a.jpg',
        'provider': 'GOOGLE',
        'isActive': false,
      });
      expect(user.displayName, 'منصور احمد');
      expect(user.handle, '@mansoor');
      expect(user.provider, 'GOOGLE');
      expect(user.isActive, isFalse);
    });
  });
}
