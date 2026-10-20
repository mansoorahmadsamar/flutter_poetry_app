import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/guest_service.dart';
import '../models/discover_bundle_model.dart';

final discoverServiceProvider = Provider<DiscoverService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DiscoverService(dioClient, ref);
});

/// Service for fetching discover content bundle
class DiscoverService {
  final DioClient _dioClient;
  final Ref _ref;
  final _logger = Logger();

  // In-memory cache for discover bundle
  DiscoverBundle? _cachedBundle;
  DateTime? _cacheTime;
  String? _cachedLanguage;
  // Bucket the cache by auth state so a guest-mode bundle never bleeds into
  // a signed-in user's session (or vice-versa). Auth notifier also calls
  // [clearCache] on sign-in/sign-out as belt-and-suspenders.
  bool? _cachedIsGuest;

  static const _cacheDuration = Duration(minutes: 15);

  DiscoverService(this._dioClient, this._ref);

  /// Get discover bundle with caching
  /// Returns cached data if available and not expired
  Future<DiscoverBundle> getDiscoverBundle({
    required String lang,
    bool forceRefresh = false,
  }) async {
    final isGuest = _ref.read(authProvider).isGuest;

    // Check cache validity — bucket by (lang, isGuest).
    if (!forceRefresh &&
        _cachedBundle != null &&
        _cacheTime != null &&
        _cachedLanguage == lang &&
        _cachedIsGuest == isGuest &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      _logger.d('Returning cached discover bundle (isGuest=$isGuest)');
      return _cachedBundle!;
    }

    try {
      _logger.d('Fetching discover bundle for lang: $lang (isGuest=$isGuest)');

      // Guests hit the anonymous endpoint via GuestService, which also
      // adapts the slimmer payload into the DiscoverBundle shape the UI
      // already understands.
      DiscoverBundle bundle;
      if (isGuest) {
        bundle =
            await _ref.read(guestServiceProvider).getDiscoverBundle(lang: lang);
      } else {
        final response = await _dioClient.get(
          '/api/discover',
          queryParameters: {'lang': lang},
        );

        if (response.statusCode != 200 || response.data == null) {
          throw Exception('Failed to load discover bundle');
        }
        final data = response.data;
        if (data['success'] != true || data['data'] == null) {
          throw Exception('Failed to load discover bundle');
        }
        final rawData = data['data'] as Map<String, dynamic>;
        _flattenPoetAvatars(rawData);
        bundle = DiscoverBundle.fromJson(rawData);
      }

      // Update cache
      _cachedBundle = bundle;
      _cacheTime = DateTime.now();
      _cachedLanguage = lang;
      _cachedIsGuest = isGuest;

      _logger.i('Discover bundle loaded successfully (isGuest=$isGuest)');
      return bundle;
    } on DioException catch (e) {
      _logger.e('DioException fetching discover bundle: ${e.message}');

      // Return cached data if available on error — only if the auth bucket
      // still matches, so an authed user doesn't accidentally see stale
      // guest data when their token refresh fails (or vice-versa).
      if (_cachedBundle != null &&
          _cachedLanguage == lang &&
          _cachedIsGuest == isGuest) {
        _logger.w('Returning stale cache due to error');
        return _cachedBundle!;
      }

      rethrow;
    } catch (e) {
      _logger.e('Error fetching discover bundle: $e');
      rethrow;
    }
  }

  /// Flatten nested poetInfo.profileImageUrl into imageUrl for each content card item
  void _flattenPoetAvatars(Map<String, dynamic> data) {
    for (final sectionKey in ['editorsPicks', 'recommended', 'featuredPoets', 'categories']) {
      final section = data[sectionKey];
      if (section is Map<String, dynamic> && section['items'] is List) {
        for (final item in section['items']) {
          if (item is Map<String, dynamic>) {
            final currentImage = item['imageUrl'];
            final hasValidImage = currentImage != null &&
                currentImage is String &&
                currentImage != '-' &&
                currentImage.isNotEmpty;

            if (!hasValidImage && item['poetInfo'] is Map<String, dynamic>) {
              final poetInfo = item['poetInfo'] as Map<String, dynamic>;
              final profileUrl = poetInfo['profileImageUrl'];
              if (profileUrl != null && profileUrl != '-' && profileUrl.toString().isNotEmpty) {
                item['imageUrl'] = profileUrl;
              }
            }
          }
        }
      }
    }
  }

  /// Clear the cache (e.g., on sign-in, sign-out, or language change). The
  /// auth notifier calls this whenever `isAuthenticated` flips so guest data
  /// never bleeds into a signed-in session.
  void clearCache() {
    _cachedBundle = null;
    _cacheTime = null;
    _cachedLanguage = null;
    _cachedIsGuest = null;
    _logger.d('Discover bundle cache cleared');
  }

  /// Check if cache is valid
  bool get hasCachedData =>
      _cachedBundle != null &&
      _cacheTime != null &&
      DateTime.now().difference(_cacheTime!) < _cacheDuration;
}
