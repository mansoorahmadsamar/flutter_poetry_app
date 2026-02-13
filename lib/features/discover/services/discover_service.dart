import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/network/dio_client.dart';
import '../models/discover_bundle_model.dart';

final discoverServiceProvider = Provider<DiscoverService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DiscoverService(dioClient);
});

/// Service for fetching discover content bundle
class DiscoverService {
  final DioClient _dioClient;
  final _logger = Logger();

  // In-memory cache for discover bundle
  DiscoverBundle? _cachedBundle;
  DateTime? _cacheTime;
  String? _cachedLanguage;

  static const _cacheDuration = Duration(minutes: 15);

  DiscoverService(this._dioClient);

  /// Get discover bundle with caching
  /// Returns cached data if available and not expired
  Future<DiscoverBundle> getDiscoverBundle({
    required String lang,
    bool forceRefresh = false,
  }) async {
    // Check cache validity
    if (!forceRefresh &&
        _cachedBundle != null &&
        _cacheTime != null &&
        _cachedLanguage == lang &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      _logger.d('Returning cached discover bundle');
      return _cachedBundle!;
    }

    try {
      _logger.d('Fetching discover bundle for lang: $lang');

      final response = await _dioClient.get(
        '/api/discover',
        queryParameters: {'lang': lang},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final bundle = DiscoverBundle.fromJson(data['data']);

          // Update cache
          _cachedBundle = bundle;
          _cacheTime = DateTime.now();
          _cachedLanguage = lang;

          _logger.i('Discover bundle loaded successfully');
          return bundle;
        }
      }

      throw Exception('Failed to load discover bundle');
    } on DioException catch (e) {
      _logger.e('DioException fetching discover bundle: ${e.message}');

      // Return cached data if available on error
      if (_cachedBundle != null && _cachedLanguage == lang) {
        _logger.w('Returning stale cache due to error');
        return _cachedBundle!;
      }

      rethrow;
    } catch (e) {
      _logger.e('Error fetching discover bundle: $e');
      rethrow;
    }
  }

  /// Clear the cache (e.g., on logout or language change)
  void clearCache() {
    _cachedBundle = null;
    _cacheTime = null;
    _cachedLanguage = null;
    _logger.d('Discover bundle cache cleared');
  }

  /// Check if cache is valid
  bool get hasCachedData =>
      _cachedBundle != null &&
      _cacheTime != null &&
      DateTime.now().difference(_cacheTime!) < _cacheDuration;
}
