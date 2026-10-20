import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/auth/auth_provider.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/core/network/guest_service.dart';
import '../models/feed_event.dart';
import '../models/feed_response.dart';

class FeedService {
  final Dio _dio;
  final Ref _ref;

  FeedService(this._dio, this._ref);

  /// Fetch a page of the personalized feed.
  /// Omit [cursor] for first page or pull-to-refresh (starts new session).
  ///
  /// For anonymous users this delegates to [GuestService.getDiscoverBundle]
  /// and adapts the response into a [FeedResponse]. The personalized feed
  /// (`/api/feed`) requires auth; there is no anonymous equivalent.
  Future<FeedResponse> getFeed({
    String lang = 'ur',
    String? cursor,
    int limit = 20,
    bool refresh = false,
  }) async {
    if (_ref.read(authProvider).isGuest) {
      final bundle =
          await _ref.read(guestServiceProvider).getDiscoverBundle(lang: lang);
      return FeedResponse.fromGuestBundle(bundle);
    }

    final queryParams = <String, dynamic>{
      'lang': lang,
      'limit': limit,
    };
    if (cursor != null) {
      queryParams['cursor'] = cursor;
    }
    if (refresh) {
      queryParams['refresh'] = 'true';
    }

    final response = await _dio.get(
      '/api/feed',
      queryParameters: queryParams,
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    return FeedResponse.fromJson(apiResponse.data!);
  }

  /// Send engagement events in batch. Fire-and-forget — never throws.
  /// No-op for guests: they have no user id to attribute events to and the
  /// `/api/events/batch` endpoint is auth-only.
  Future<void> sendEvents(List<FeedEvent> events) async {
    if (events.isEmpty) return;
    if (_ref.read(authProvider).isGuest) return;
    try {
      await _dio.post(
        '/api/events/batch',
        data: events.map((e) => e.toJson()).toList(),
      );
    } catch (_) {
      // Events are non-critical — never let this crash the UI.
      // Server returns 202 Accepted; processing is async.
    }
  }
}

/// Riverpod provider for FeedService
final feedServiceProvider = Provider<FeedService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return FeedService(dioClient.dio, ref);
});
