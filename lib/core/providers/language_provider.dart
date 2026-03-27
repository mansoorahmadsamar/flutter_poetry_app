import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/language_model.dart';
import '../services/language_service.dart';
import '../storage/preferences_service.dart';

/// Provider for fetching available languages from API
final availableLanguagesProvider = FutureProvider<List<LanguageModel>>((ref) async {
  final languageService = ref.watch(languageServiceProvider);
  return languageService.getActiveLanguages();
});

/// State class for selected language
class SelectedLanguageState {
  final String code;
  final bool isLoading;
  final String? error;

  const SelectedLanguageState({
    required this.code,
    this.isLoading = false,
    this.error,
  });

  SelectedLanguageState copyWith({
    String? code,
    bool? isLoading,
    String? error,
  }) {
    return SelectedLanguageState(
      code: code ?? this.code,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing selected language with persistence
class SelectedLanguageNotifier extends StateNotifier<SelectedLanguageState> {
  final PreferencesService _preferencesService;
  final LanguageService _languageService;

  SelectedLanguageNotifier(this._preferencesService, this._languageService)
      : super(SelectedLanguageState(code: 'ur')) {
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() {
    final savedLanguage = _preferencesService.getLanguage();
    state = state.copyWith(code: savedLanguage);
  }

  /// Change language - saves to SharedPreferences and updates profile on backend
  Future<void> setLanguage(String languageCode) async {
    if (state.code == languageCode) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Save to local preferences first
      await _preferencesService.setLanguage(languageCode);

      // Update profile on backend
      await _languageService.updateProfileLanguage(languageCode);

      state = state.copyWith(code: languageCode, isLoading: false);
    } catch (e) {
      // Even if backend fails, keep local preference
      await _preferencesService.setLanguage(languageCode);
      state = state.copyWith(
        code: languageCode,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Get current language code (for backward compatibility)
  String get currentLanguage => state.code;
}

/// Provider for selected language notifier
final selectedLanguageNotifierProvider =
    StateNotifierProvider<SelectedLanguageNotifier, SelectedLanguageState>((ref) {
  final preferencesService = ref.watch(preferencesServiceProvider);
  final languageService = ref.watch(languageServiceProvider);
  return SelectedLanguageNotifier(preferencesService, languageService);
});

/// Simple string provider for backward compatibility with existing code
/// This is what poet_providers and other files will use
final selectedLanguageProvider = Provider<String>((ref) {
  return ref.watch(selectedLanguageNotifierProvider).code;
});

/// Provider to get the full LanguageModel of selected language
final selectedLanguageModelProvider = FutureProvider<LanguageModel?>((ref) async {
  final selectedCode = ref.watch(selectedLanguageProvider);
  final languages = await ref.watch(availableLanguagesProvider.future);

  return languages.where((lang) => lang.code == selectedCode).firstOrNull;
});
