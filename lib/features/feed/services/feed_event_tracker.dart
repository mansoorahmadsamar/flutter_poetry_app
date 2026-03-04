import 'package:uuid/uuid.dart';
import '../models/feed_event.dart';
import '../models/feed_item.dart';
import 'feed_service.dart';

/// Buffers feed engagement events and handles impression/dwell tracking.
/// Events are flushed in batches before each page load and on dispose.
class FeedEventTracker {
  static const _uuid = Uuid();

  final List<FeedEvent> _pendingEvents = [];
  final Map<String, int> _impressionStartTimes = {};
  final Set<String> _impressedItemKeys = {};

  List<FeedEvent> get pendingEvents => List.unmodifiable(_pendingEvents);

  /// Called when an item becomes >50% visible on screen.
  /// Deduplicates: only one impression per itemKey per session.
  void onItemVisible(FeedItem item, String sessionId) {
    final itemKey = _itemKey(item);

    // Deduplicate impressions — VisibilityDetector fires multiple times
    if (_impressedItemKeys.contains(itemKey)) return;
    _impressedItemKeys.add(itemKey);

    _impressionStartTimes[item.publicId] =
        DateTime.now().millisecondsSinceEpoch;

    _addEvent(FeedEvent(
      eid: _uuid.v4(),
      t: 'impression',
      itemKey: itemKey,
      sid: sessionId,
      ts: _nowSec(),
    ));
  }

  /// Called when an item leaves the visible viewport.
  /// Emits dwell_ms (≥500ms) or skip_fast (<500ms).
  void onItemHidden(FeedItem item, String sessionId) {
    final start = _impressionStartTimes.remove(item.publicId);
    if (start == null) return;

    final dwellMs = DateTime.now().millisecondsSinceEpoch - start;
    final itemKey = _itemKey(item);

    if (dwellMs < 500) {
      _addEvent(FeedEvent(
        eid: _uuid.v4(),
        t: 'skip_fast',
        itemKey: itemKey,
        sid: sessionId,
        ts: _nowSec(),
      ));
    } else {
      _addEvent(FeedEvent(
        eid: _uuid.v4(),
        t: 'dwell_ms',
        itemKey: itemKey,
        sid: sessionId,
        ts: _nowSec(),
        v: dwellMs,
      ));
    }
  }

  /// Track an explicit user action (open_item, bookmark, share, follow).
  void trackAction(FeedItem item, String sessionId, String eventType) {
    _addEvent(FeedEvent(
      eid: _uuid.v4(),
      t: eventType,
      itemKey: _itemKey(item),
      sid: sessionId,
      ts: _nowSec(),
    ));
  }

  /// Flush all pending events to the server via [service].
  /// Clears the buffer after sending.
  Future<void> flush(FeedService service) async {
    if (_pendingEvents.isEmpty) return;
    final batch = List<FeedEvent>.from(_pendingEvents);
    _pendingEvents.clear();
    await service.sendEvents(batch);
  }

  /// Reset tracking state for a new session (pull-to-refresh).
  void reset() {
    _impressedItemKeys.clear();
    _impressionStartTimes.clear();
  }

  void _addEvent(FeedEvent event) {
    _pendingEvents.add(event);
  }

  String _itemKey(FeedItem item) => '${item.type}:${item.publicId}';

  int _nowSec() => DateTime.now().millisecondsSinceEpoch ~/ 1000;
}
