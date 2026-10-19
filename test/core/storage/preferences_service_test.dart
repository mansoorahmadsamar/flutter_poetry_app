import 'package:flutter_poetry_app/core/constants/app_constants.dart';
import 'package:flutter_poetry_app/core/storage/preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late PreferencesService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.languagePreferenceKey: 'ur',
      AppConstants.themePreferenceKey: 'light',
      AppConstants.onboardingCompletedKey: true,
      AppConstants.searchHistoryKey: <String>['غالب'],
      AppConstants.globalSearchHistoryKey: <String>['dil'],
      AppConstants.bookmarkSearchHistoryKey: <String>['میر'],
      AppConstants.composeVariantPreferenceKey: 'sher-helper',
    });
    prefs = await SharedPreferences.getInstance();
    service = PreferencesService(prefs);
  });

  group('PreferencesService.clearUserData', () {
    test('removes only account-scoped keys', () async {
      await service.clearUserData();
      expect(prefs.getKeys(), {
        AppConstants.languagePreferenceKey,
        AppConstants.themePreferenceKey,
        AppConstants.onboardingCompletedKey,
        AppConstants.searchHistoryKey,
        AppConstants.globalSearchHistoryKey,
      });
      expect(service.getLanguage(), 'ur');
    });

    test('includeSearchHistory also removes search history', () async {
      await service.clearUserData(includeSearchHistory: true);
      expect(prefs.getKeys(), {
        AppConstants.languagePreferenceKey,
        AppConstants.themePreferenceKey,
        AppConstants.onboardingCompletedKey,
      });
    });
  });
}
