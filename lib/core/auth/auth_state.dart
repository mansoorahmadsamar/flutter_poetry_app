import 'package:equatable/equatable.dart';

/// Authentication state for the app
class AuthState extends Equatable {
  final bool isAuthenticated;
  final bool isLoading;
  final String? accessToken;
  final String? refreshToken;
  final String? userEmail;
  final String? errorMessage;

  /// True only while the stored session is being restored at app start.
  /// The router holds the splash screen during it. Unlike [isLoading] it is
  /// not set by sign-in or logout, so those never move the user to splash.
  final bool isRestoringSession;

  /// True after the app signed the user out because their session could no
  /// longer be refreshed. The login screen explains this; cleared on sign-in
  /// or "Continue as guest".
  final bool sessionExpired;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.accessToken,
    this.refreshToken,
    this.userEmail,
    this.errorMessage,
    this.isRestoringSession = false,
    this.sessionExpired = false,
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
    bool? isRestoringSession,
    bool? sessionExpired,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userEmail: userEmail ?? this.userEmail,
      errorMessage: errorMessage ?? this.errorMessage,
      isRestoringSession: isRestoringSession ?? this.isRestoringSession,
      sessionExpired: sessionExpired ?? this.sessionExpired,
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
        isRestoringSession,
        sessionExpired,
      ];
}
