import '../models/hashtag_model.dart';

/// The tabs of the hashtag screen, in display order.
enum HashtagTab { couplets, poems, images, poets }

/// How many items [meta] reports for [tab].
int hashtagTabCount(HashtagDto meta, HashtagTab tab) => switch (tab) {
      HashtagTab.couplets => meta.coupletCount,
      HashtagTab.poems => meta.poemCount,
      HashtagTab.images => meta.imageCount,
      HashtagTab.poets => meta.poetCount,
    };

/// The tab the hashtag screen opens on: the first tab, in display order, that
/// has content (T-178: #Politics has 0 couplets and 1 poem, so it opens on
/// نظمیں rather than an empty اشعار). With no metadata or every tab empty it
/// stays on the first tab.
HashtagTab initialHashtagTab(HashtagDto? meta) {
  if (meta == null) return HashtagTab.values.first;
  return HashtagTab.values.firstWhere(
    (tab) => hashtagTabCount(meta, tab) > 0,
    orElse: () => HashtagTab.values.first,
  );
}
