import 'package:flutter_test/flutter_test.dart';

import '../../helpers/auth_harness.dart';
import '../../helpers/fake_dio_adapter.dart';

void main() {
  late AuthHarness h;
  tearDown(() => h.dispose());

  final devicePrefs = <String, Object>{
    'language_preference': 'ur',
    'search_history': <String>['غالب', 'dil'],
    'global_search_history': <String>['ghazal', 'محبت'],
  };

  Future<void> signedIn() async {
    h = await AuthHarness.create(
      accessToken: validAccessToken,
      refreshToken: validRefreshToken,
      prefs: devicePrefs,
    );
    await h.restored();
  }

  test('regression: logout keeps the language choice and search histories (T-046)',
      () async {
    await signedIn();
    await h.notifier.logout();

    expect(h.prefs.getString('language_preference'), 'ur');
    expect(h.prefs.getStringList('search_history'), ['غالب', 'dil']);
    expect(h.prefs.getStringList('global_search_history'), ['ghazal', 'محبت']);
  });

  test('an expired session also keeps them', () async {
    await signedIn();
    await h.notifier.expireSession();
    expect(h.prefs.getString('language_preference'), 'ur');
    expect(h.prefs.getStringList('global_search_history'), ['ghazal', 'محبت']);
  });

  test('logout clears the account bookmark searches and creator settings', () async {
    h = await AuthHarness.create(
      accessToken: validAccessToken,
      refreshToken: validRefreshToken,
      prefs: {
        ...devicePrefs,
        'bookmark_search_history': <String>['میر'],
        'creator.compose.variant': 'sher-helper',
      },
    );
    await h.restored();
    await h.notifier.logout();

    expect(h.prefs.getStringList('bookmark_search_history'), isNull);
    expect(h.prefs.getString('creator.compose.variant'), isNull);
    expect(h.prefs.getString('language_preference'), 'ur');
  });

  test('account deletion also forgets search history but keeps the language', () async {
    await signedIn();
    h.adapter.on('DELETE', '/api/users/me',
        (_) => const FakeReply(200, {'success': true}));
    await h.notifier.deleteAccount();

    expect(h.prefs.getStringList('search_history'), isNull);
    expect(h.prefs.getStringList('global_search_history'), isNull);
    expect(h.prefs.getString('language_preference'), 'ur');
    expect(h.auth.isGuest, isTrue);
  });
}
