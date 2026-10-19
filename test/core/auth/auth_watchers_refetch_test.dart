import 'package:flutter_poetry_app/core/constants/app_constants.dart';
import 'package:flutter_poetry_app/core/providers/user_provider.dart';
import 'package:flutter_poetry_app/features/engagement/providers/reaction_providers.dart';
import 'package:flutter_poetry_app/features/engagement/providers/unified_bookmark_provider.dart';
import 'package:flutter_poetry_app/features/main/tabs/bookmarks/models/unified_bookmark_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/creator/providers/creator_providers.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/providers/poets_discovery_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/auth_harness.dart';
import '../../helpers/fake_dio_adapter.dart';

/// Lets queued network futures and provider rebuilds run.
Future<void> _settle() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late AuthHarness h;
  tearDown(() => h.dispose());

  test('regression: a token refresh re-runs none of the auth-dependent fetches', () async {
    h = await AuthHarness.create(
      accessToken: validAccessToken,
      refreshToken: validRefreshToken,
    );
    await h.restored();

    final watched = <ProviderListenable<Object?>>[
      userProfileProvider,
      ownedPoetProvider,
      creatorTranslationsProvider,
      reactionTypesProvider,
      bookmarkStatsProvider,
      unifiedBookmarksProvider(const BookmarkFilters()),
      poetsDiscoveryProvider,
    ];
    for (final provider in watched) {
      h.container.listen(provider, (_, __) {}, onError: (_, __) {});
    }
    await _settle();
    final fetchesBefore = h.adapter.requests.length;
    expect(fetchesBefore, greaterThan(0));

    h.adapter.on('POST', AppConstants.authRefreshPath,
        (_) => FakeReply(200, refreshSuccessBody()));
    expect(await h.notifier.refreshAccessToken(), isTrue);
    await _settle();

    final newRequests = h.adapter.requests.skip(fetchesBefore).map((r) => r.path);
    expect(newRequests, [AppConstants.authRefreshPath]);
  });

  test('signing out still re-runs them (they switch to guest data)', () async {
    h = await AuthHarness.create(
      accessToken: validAccessToken,
      refreshToken: validRefreshToken,
    );
    await h.restored();
    h.container.listen(ownedPoetProvider, (_, __) {}, onError: (_, __) {});
    h.container.listen(reactionTypesProvider, (_, __) {}, onError: (_, __) {});
    await _settle();
    await h.notifier.logout();
    await _settle();
    expect(await h.container.read(ownedPoetProvider.future), isNull);
    expect(await h.container.read(reactionTypesProvider.future), isEmpty);
  });
}
