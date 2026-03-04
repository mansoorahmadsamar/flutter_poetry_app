/// Feed engagement event sent to POST /api/events/batch.
/// Plain Dart class — only serialized TO json, never deserialized.
class FeedEvent {
  final String eid;
  final String t;
  final String itemKey;
  final String sid;
  final int ts;
  final int? v;

  FeedEvent({
    required this.eid,
    required this.t,
    required this.itemKey,
    required this.sid,
    required this.ts,
    this.v,
  });

  Map<String, dynamic> toJson() => {
        'eid': eid,
        't': t,
        'itemKey': itemKey,
        'sid': sid,
        'ts': ts,
        if (v != null) 'v': v,
      };
}
