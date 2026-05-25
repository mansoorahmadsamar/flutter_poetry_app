import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:flutter_poetry_app/core/auth/auth_provider.dart';
import '../models/poet_model.dart';
import '../services/poet_service.dart';
import 'poet_providers.dart';

part 'poets_discovery_provider.freezed.dart';

final Logger _logger = Logger();

/// Status for the discovery feed loading
enum PoetsDiscoveryStatus { initial, loading, loaded, error }

/// Data for one horizontal section
@freezed
class PoetSection with _$PoetSection {
  const factory PoetSection({
    @Default([]) List<PoetModel> poets,
    @Default(0) int totalCount,
  }) = _PoetSection;
}

/// Combined state for all discovery sections
@freezed
class PoetsDiscoveryState with _$PoetsDiscoveryState {
  const factory PoetsDiscoveryState({
    @Default(PoetsDiscoveryStatus.initial) PoetsDiscoveryStatus status,
    @Default(PoetSection()) PoetSection trending,
    @Default(PoetSection()) PoetSection featured,
    @Default(PoetSection()) PoetSection topRead,
    @Default(PoetSection()) PoetSection classical,
    @Default(PoetSection()) PoetSection modern,
    @Default(PoetSection()) PoetSection women,
    String? errorMessage,
  }) = _PoetsDiscoveryState;
}

/// Notifier that loads all 6 poet sections in parallel
class PoetsDiscoveryNotifier extends StateNotifier<PoetsDiscoveryState> {
  final PoetService _poetService;
  final String _language;
  final bool _isGuest;

  static const int _sectionSize = 8;

  PoetsDiscoveryNotifier(this._poetService, this._language, this._isGuest)
      : super(const PoetsDiscoveryState()) {
    _loadAll();
  }

  Future<void> _loadAll() async {
    state = state.copyWith(status: PoetsDiscoveryStatus.loading);

    try {
      // Era/gender sections have no guest API equivalent. Routing them to
      // the flat guest directory would mislabel the data ("Classical
      // Poets" showing an unfiltered list), so for guests we skip those
      // three sections entirely. The screen also hides their headers +
      // filter chips (see poets_list_screen).
      final results = await Future.wait([
        _poetService.getTrendingPoets(page: 0, size: _sectionSize, lang: _language),
        _poetService.getFeaturedPoets(page: 0, size: _sectionSize, lang: _language),
        _poetService.getTopPoetsByViews(page: 0, size: _sectionSize, lang: _language),
        if (!_isGuest) ...[
          _poetService.getPoetsByEra(era: 'CLASSICAL', page: 0, size: _sectionSize, lang: _language),
          _poetService.getPoetsByEra(era: 'MODERN', page: 0, size: _sectionSize, lang: _language),
          _poetService.getPoetsByGender(gender: 'FEMALE', page: 0, size: _sectionSize, lang: _language),
        ],
      ]);

      if (!mounted) return;

      state = state.copyWith(
        status: PoetsDiscoveryStatus.loaded,
        trending: PoetSection(poets: results[0].content, totalCount: results[0].totalElements),
        featured: PoetSection(poets: results[1].content, totalCount: results[1].totalElements),
        topRead: PoetSection(poets: results[2].content, totalCount: results[2].totalElements),
        classical: _isGuest
            ? const PoetSection(poets: [], totalCount: 0)
            : PoetSection(poets: results[3].content, totalCount: results[3].totalElements),
        modern: _isGuest
            ? const PoetSection(poets: [], totalCount: 0)
            : PoetSection(poets: results[4].content, totalCount: results[4].totalElements),
        women: _isGuest
            ? const PoetSection(poets: [], totalCount: 0)
            : PoetSection(poets: results[5].content, totalCount: results[5].totalElements),
        errorMessage: null,
      );

      _logger.i('✅ Poets discovery loaded (guest=$_isGuest): '
          'trending=${results[0].content.length}, '
          'featured=${results[1].content.length}, '
          'topRead=${results[2].content.length}');
    } catch (e) {
      if (!mounted) return;
      _logger.e('❌ Error loading poets discovery: $e');
      state = state.copyWith(
        status: PoetsDiscoveryStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await _loadAll();
  }
}

/// Provider for the poets discovery feed
final poetsDiscoveryProvider =
    StateNotifierProvider<PoetsDiscoveryNotifier, PoetsDiscoveryState>((ref) {
  final poetService = ref.watch(poetServiceProvider);
  final language = ref.watch(selectedLanguageProvider);
  final isGuest = ref.watch(authProvider).isGuest;
  return PoetsDiscoveryNotifier(poetService, language, isGuest);
});
