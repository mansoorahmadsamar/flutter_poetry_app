import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/models/user_model.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/core/providers/user_provider.dart';
import 'package:flutter_poetry_app/core/storage/preferences_service.dart';
import 'package:flutter_poetry_app/features/main/tabs/creator/providers/creator_providers.dart';
import 'package:flutter_poetry_app/features/main/tabs/profile/providers/app_content_providers.dart';
import 'package:flutter_poetry_app/features/main/tabs/profile_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/fake_auth_notifier.dart';
import '../../../helpers/fixtures.dart';
import '../../../helpers/test_config.dart';

Future<void> _pump(WidgetTester tester, UserModel user,
    {String lang = 'ur'}) async {
  SharedPreferences.setMockInitialValues({'language_preference': lang});
  final prefs = await SharedPreferences.getInstance();
  tester.view.physicalSize = const Size(900, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      authOverride(FakeAuthNotifier.signedIn()),
      preferencesServiceProvider.overrideWithValue(PreferencesService(prefs)),
      userProfileProvider.overrideWith((ref) async => user),
      ownedPoetProvider.overrideWith((ref) async => null),
      availableLanguagesProvider.overrideWith((ref) async => const []),
      appContentListProvider.overrideWith((ref) async => const []),
    ],
    child: const MaterialApp(home: Scaffold(body: ProfileTab())),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  setUpTestConfig();

  UserModel nullNameUser() => ApiResponse.fromJson(
        loadJsonFixture('auth/me_null_name.json'),
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      ).data!;

  group('ProfileTab header (T-181)', () {
    testWidgets(
        'regression: a user with no name/username/provider still gets a '
        'profile (Urdu)', (tester) async {
      await _pump(tester, nullNameUser());

      expect(tester.takeException(), isNull);
      expect(find.text('reader'), findsOneWidget, reason: 'email fallback');
      expect(find.textContaining('@null'), findsNothing);
      expect(find.text('null'), findsNothing);
      expect(find.text('—'), findsOneWidget, reason: 'provider unknown');
    });

    testWidgets('English: a complete user shows name and @username',
        (tester) async {
      await _pump(
        tester,
        const UserModel(
          id: 'u1',
          email: 'a@b.c',
          fullName: 'Mansoor Ahmad',
          username: 'mansoor',
          provider: 'GOOGLE',
        ),
        lang: 'en',
      );

      expect(find.text('Mansoor Ahmad'), findsOneWidget);
      expect(find.text('@mansoor'), findsOneWidget);
      expect(find.text('GOOGLE'), findsOneWidget);
    });
  });
}
