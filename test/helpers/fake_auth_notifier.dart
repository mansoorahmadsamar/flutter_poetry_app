import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/auth/auth_provider.dart';
import 'package:flutter_poetry_app/core/auth/auth_state.dart';

/// An [AuthNotifier] stand-in with a fixed [AuthState]. The real notifier
/// touches Firebase and secure storage in its constructor, so tests override
/// `authProvider` with this instead. Any auth action fails loudly.
class FakeAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  FakeAuthNotifier(super.state);

  /// A guest: finished loading, not signed in.
  FakeAuthNotifier.guest() : super(const AuthState());

  /// A signed-in user (fake tokens, never sent anywhere).
  FakeAuthNotifier.signedIn()
      : super(const AuthState(
          isAuthenticated: true,
          accessToken: 'test-access',
          refreshToken: 'test-refresh',
        ));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Provider override for [authProvider] with a fixed state.
Override authOverride(FakeAuthNotifier notifier) =>
    authProvider.overrideWith((ref) => notifier);
