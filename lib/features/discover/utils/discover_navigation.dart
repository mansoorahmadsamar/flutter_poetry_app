import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/content_locations.dart';
import '../../../core/utils/api_placeholder.dart';
import '../../search/models/search_origin.dart';
import '../models/discover_bundle_model.dart';

/// Where a tap on a Discover rail card goes, or null when it cannot open
/// anything.
///
/// A couplet or verse card opens its **poem** (`poemPublicId`), never
/// `/main/poems/<couplet id>` — the guest bundle's trending couplets carry
/// `poemPublicId`, but the card used to push its own (couplet) id (T-181).
/// Without a poem id the card opens nothing rather than a wrong poem. With a
/// `coupletNumber` the poem opens scrolled to the couplet (`?couplet=`).
({String path, Object? extra})? discoverCardDestination(ContentCard card) {
  final id = presentOrNull(card.publicId);
  switch (card.type) {
    case 'POET':
      return id == null ? null : (path: '/main/poets/$id', extra: null);
    case 'POEM':
      return id == null ? null : (path: '/main/poems/$id', extra: null);
    case 'VERSE':
    case 'COUPLET':
      final poemId = card.poemPublicId;
      return poemId == null
          ? null
          : (
              path: ContentLocations.poem(poemId,
                  coupletNumber: card.coupletNumber),
              extra: null,
            );
    case 'CATEGORY':
    case 'TAG':
      return (
        path: '/search',
        extra: SearchRouteExtra.of(card.primaryText, SearchOrigin.browse),
      );
    default:
      return null;
  }
}

/// Opens [card] (see [discoverCardDestination]); does nothing when it has no
/// destination.
void openDiscoverCard(BuildContext context, ContentCard card) {
  final destination = discoverCardDestination(card);
  if (destination == null) return;
  context.push(destination.path, extra: destination.extra);
}
