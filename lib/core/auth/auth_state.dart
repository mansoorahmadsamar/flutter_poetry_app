import 'package:equatable/equatable.dart';

/// Authentication state for the app
class AuthState extends Equatable {
  final bool isAuthenticated;
  final bool isLoading;
  final String? accessToken;
  final String? refreshToken;
  final String? userEmail;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.accessToken,
    this.refreshToken,
    this.userEmail,
    this.errorMessage,
  });

  /// True when the user has finished resolving any stored session and is
  /// browsing without an account. Used by services to branch onto the
  /// `/api/guest/**` surface and by the router to allow guest navigation.
  bool get isGuest => !isAuthenticated && !isLoading;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? accessToken,
    String? refreshToken,
    String? userEmail,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userEmail: userEmail ?? this.userEmail,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isAuthenticated,
        isLoading,
        accessToken,
        refreshToken,
        userEmail,
        errorMessage,
      ];
}
