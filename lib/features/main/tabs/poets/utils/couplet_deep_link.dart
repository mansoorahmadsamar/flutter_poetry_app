import '../models/couplet_model.dart';

/// Where a poem opened with `?couplet=<coupletNumber>` lands.
abstract final class CoupletDeepLink {
  /// Fraction of the viewport above the target couplet once scrolled: it sits
  /// a quarter of the way down, with the lines before it still in view.
  static const double scrollAlignment = 0.25;

  /// How long the scroll to the couplet takes.
  static const Duration scrollDuration = Duration(milliseconds: 350);

  /// Index in [couplets] (the poem's API couplets, in display order) of the
  /// couplet numbered [coupletNumber], or null when there is none — a stale
  /// link, a number from another poem, or a poem without couplets. The poem
  /// then opens at the top, as it did before deep links.
  static int? targetIndex(List<CoupletModel>? couplets, int? coupletNumber) {
    if (couplets == null || coupletNumber == null || coupletNumber <= 0) {
      return null;
    }
    final index = couplets.indexWhere((c) => c.coupletNumber == coupletNumber);
    return index < 0 ? null : index;
  }
}
