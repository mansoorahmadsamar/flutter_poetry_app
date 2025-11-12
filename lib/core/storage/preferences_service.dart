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
    return _prefs.getString(AppConstants.languagePreferenceKey) ?? 'en';
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

  // Clear all preferences
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

/// Riverpod provider for PreferencesService
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError('PreferencesService must be initialized in main()');
});
