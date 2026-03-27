import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import '../models/feed_item.dart';
import '../services/feed_event_tracker.dart';
import '../services/feed_service.dart';
import 'feed_engagement_provider.dart';

/// Immutable feed state
class FeedState {
  final List<FeedItem> items;
  final String? nextCursor;
  final String? sessionId;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool isInitial;

  const FeedState({
    this.items = const [],
    this.nextCursor,
    this.sessionId,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.isInitial = true,
  });

  FeedState copyWith({
    List<FeedItem>? items,
    String? Function()? nextCursor,
    String? Function()? sessionId,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? Function()? error,
    bool? isInitial,
  }) {
    return FeedState(
      items: items ?? this.items,
      nextCursor: nextCursor != null ? nextCursor() : this.nextCursor,
      sessionId: sessionId != null ? sessionId() : this.sessionId,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error != null ? error() : this.error,
      isInitial: isInitial ?? this.isInitial,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  final FeedService _feedService;
  final String _lang;
  final FeedEventTracker _tracker = FeedEventTracker();
  final Ref _ref;

  /// Synchronous lock to prevent duplicate in-flight fetches.
  /// Scroll listener can fire multiple times before Riverpod state propagates.
  bool _fetchLock = false;

  /// Client-side dedup: tracks seen item keys within a session.
  final Set<String> _seenItemKeys = {};

  /// Guard for auto-advance on empty first page — prevents infinite retry loops.
  bool _autoAdvanceAttempted = false;

  FeedNotifier({
    required FeedService feedService,
    required String lang,
    required Ref ref,
  })  : _feedService = feedService,
        _lang = lang,
        _ref = ref,
        super(const FeedState()) {
    loadFirstPage();
  }

  FeedEventTracker get tracker => _tracker;

  /// Load first page — call on init or pull-to-refresh.
  Future<void> loadFirstPage() async {
    // Flush events from previous session
    await _flushEvents();
    _tracker.reset();
    _seenItemKeys.clear();
    _autoAdvanceAttempted = false;

    // Clear optimistic engagement overlay on refresh
    _ref.read(feedEngagementProvider.notifier).state = {};

    state = const FeedState(isLoading: true);

    try {
      final response = await _feedService.getFeed(lang: _lang);
      final newItems = _dedup(response.items);

      // Auto-advance: if first page returns empty but has a cursor, try once more
      if (newItems.isEmpty &&
          response.nextCursor != null &&
          !_autoAdvanceAttempted) {
        _autoAdvanceAttempted = true;
        state = FeedState(
          nextCursor: response.nextCursor,
          sessionId: response.sessionId,
          hasMore: true,
          isLoading: true,
          isInitial: false,
        );
        // Fetch next page automatically
        try {
          final retry = await _feedService.getFeed(
            lang: _lang,
            cursor: response.nextCursor,
          );
          final retryItems = _dedup(retry.items);
          state = FeedState(
            items: retryItems,
            nextCursor: retry.nextCursor,
            sessionId: retry.sessionId,
            hasMore: retry.hasMore,
            isInitial: false,
          );
        } catch (_) {
          // Auto-advance failed — show empty state
          state = FeedState(
            nextCursor: response.nextCursor,
            sessionId: response.sessionId,
            hasMore: true,
            isInitial: false,
          );
        }
        return;
      }

      state = FeedState(
        items: newItems,
        nextCursor: response.nextCursor,
        sessionId: response.sessionId,
        hasMore: response.hasMore,
        isInitial: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isInitial: false,
        error: () => e.toString(),
      );
    }
  }

  /// Load next page — call when user scrolls near bottom.
  Future<void> loadNextPage() async {
    if (_fetchLock || !state.hasMore) return;
    _fetchLock = true;

    state = state.copyWith(isLoadingMore: true, error: () => null);

    try {
      await _flushEvents();
      final response = await _feedService.getFeed(
        lang: _lang,
        cursor: state.nextCursor,
      );
      final newItems = _dedup(response.items);
      state = state.copyWith(
        items: [...state.items, ...newItems],
        nextCursor: () => response.nextCursor,
        sessionId: () => response.sessionId,
        hasMore: response.hasMore,
        isLoadingMore: false,
      );
    } on Exception catch (e) {
      // Check for tampered/expired cursor (400)
      final errorMsg = e.toString();
      if (errorMsg.contains('Invalid or expired feed cursor')) {
        // Treat as new session — reload from scratch
        _fetchLock = false;
        await loadFirstPage();
        return;
      }
      state = state.copyWith(
        isLoadingMore: false,
        error: () => errorMsg,
      );
    } finally {
      _fetchLock = false;
    }
  }

  /// Filter out items already seen in this session.
  List<FeedItem> _dedup(List<FeedItem> items) {
    final result = <FeedItem>[];
    for (final item in items) {
      final key = '${item.type}:${item.publicId}';
      if (_seenItemKeys.add(key)) {
        result.add(item);
      }
    }
    return result;
  }

  /// Pull-to-refresh alias (full reset).
  Future<void> refresh() => loadFirstPage();

  /// Smart refresh: fetch new items since last cursor and prepend them.
  /// Returns the number of new items added.
  Future<int> smartRefresh() async {
    // No cursor yet — fall back to full reload
    if (state.nextCursor == null) {
      await loadFirstPage();
      return 0;
    }

    await _flushEvents();

    try {
      final response = await _feedService.getFeed(
        lang: _lang,
        cursor: state.nextCursor,
        refresh: true,
      );
      final newItems = _dedup(response.items);
      if (newItems.isEmpty) return 0;

      state = state.copyWith(
        items: [...newItems, ...state.items],
        nextCursor: () => response.nextCursor ?? state.nextCursor,
        sessionId: () =>
            response.sessionId.isNotEmpty ? response.sessionId : state.sessionId,
        hasMore: response.hasMore,
      );
      return response.newCount ?? newItems.length;
    } catch (_) {
      // Smart refresh should not show errors — silently fail
      return 0;
    }
  }

  /// Remove an item from the feed and send a hide event.
  void hideItem(FeedItem item) {
    trackAction(item, 'hide');
    state = state.copyWith(
      items: state.items
          .where((i) => i.publicId != item.publicId)
          .toList(),
    );
  }

  /// Track item becoming visible in viewport.
  void onItemVisible(FeedItem item) {
    final sid = state.sessionId;
    if (sid == null) return;
    _tracker.onItemVisible(item, sid);
  }

  /// Track item leaving viewport.
  void onItemHidden(FeedItem item) {
    final sid = state.sessionId;
    if (sid == null) return;
    _tracker.onItemHidden(item, sid);
  }

  /// Track user action (open_item, bookmark, share, follow).
  void trackAction(FeedItem item, String eventType) {
    final sid = state.sessionId;
    if (sid == null) return;
    _tracker.trackAction(item, sid, eventType);
  }

  /// Flush pending events. Called on dispose, app background, and before page loads.
  Future<void> flushEvents() => _flushEvents();

  Future<void> _flushEvents() async {
    if (state.sessionId == null) return;
    await _tracker.flush(_feedService);
  }

  @override
  void dispose() {
    _flushEvents();
    super.dispose();
  }
}

/// Main feed provider.
/// Watches selectedLanguageProvider — when language changes, notifier is
/// recreated with a fresh feed.
final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final feedService = ref.watch(feedServiceProvider);
  final lang = ref.watch(selectedLanguageProvider);
  return FeedNotifier(feedService: feedService, lang: lang, ref: ref);
});
