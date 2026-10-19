import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/routing/app_router.dart';

/// Where a tap on a search result goes — one place for every search surface
/// ("All" preview, filtered tabs, autocomplete), so each result type always
/// opens the same screen with the right id.
///
/// All destinations load for guests: poet and poem detail go through
/// `PoetService.getPoetProfile/getPoemById`, which use `/api/guest/**` when
/// signed out. Hashtag pages call authenticated endpoints, but guests never
/// see tag results (guest search and autocomplete return no tags).
abstract final class SearchResultNavigation {
  /// `/main/poets/:publicId`.
  static void openPoet(BuildContext context, String publicId) {
    context.pushNamed(
      AppRoutes.poetDetailName,
      pathParameters: {'publicId': publicId},
    );
  }

  /// `/main/poems/:publicId`. For a couplet or verse result this must be the
  /// parent poem's id, never the couplet's.
  static void openPoem(BuildContext context, String publicId) {
    context.pushNamed(
      AppRoutes.poemDetailName,
      pathParameters: {'publicId': publicId},
    );
  }

  /// `/hashtags/:slug`. Search tags are the admin `Tag` rows whose slugs are
  /// the hashtag slugs stored on poems (`HashtagService.buildHashtagDto` on the
  /// backend looks the tag up by the same slug).
  static void openHashtag(BuildContext context, String slug) {
    context.pushNamed(
      AppRoutes.hashtagDetailName,
      pathParameters: {'slug': slug},
    );
  }
}
