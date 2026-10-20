import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Service for managing app preferences
/// Uses SharedPreferences for non-sensitive data
class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  // Language preference
  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(AppConstants.languagePreferenceKey, languageCode);
  }

  String getLanguage() {
    return _prefs.getString(AppConstants.languagePreferenceKey) ?? 'ur';
  }

  // Theme preference
  Future<void> setThemeMode(String themeMode) async {
    await _prefs.setString(AppConstants.themePreferenceKey, themeMode);
  }

  String getThemeMode() {
    return _prefs.getString(AppConstants.themePreferenceKey) ?? 'system';
  }

  // Onboarding
  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(AppConstants.onboardingCompletedKey, completed);
  }

  bool isOnboardingCompleted() {
    return _prefs.getBool(AppConstants.onboardingCompletedKey) ?? false;
  }

  /// Preferences that belong to the signed-in account: searches inside
  /// their bookmarks and their creator settings.
  static const userScopedKeys = <String>[
    AppConstants.bookmarkSearchHistoryKey,
    AppConstants.composeVariantPreferenceKey,
  ];

  /// What the person searched for on this device.
  static const searchHistoryKeys = <String>[
    AppConstants.searchHistoryKey,
    AppConstants.globalSearchHistoryKey,
  ];

  /// Remove the signed-in account's preferences on logout. Device choices —
  /// language, theme, onboarding, search history — stay.
  /// [includeSearchHistory] also clears search history (account deletion).
  Future<void> clearUserData({bool includeSearchHistory = false}) async {
    for (final key in [
      ...userScopedKeys,
      if (includeSearchHistory) ...searchHistoryKeys,
    ]) {
      await _prefs.remove(key);
    }
  }
}

/// Riverpod provider for PreferencesService
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError('PreferencesService must be initialized in main()');
});
