import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/couplet_model.dart';

/// Utility functions to convert search models to display models
///
/// These adapters bridge the gap between search API models and existing UI components

/// Convert CoupletSearchResult to CoupletModel for CoupletCard
CoupletModel convertSearchResultToCoupletModel(CoupletSearchResult result) {
  return CoupletModel(
    publicId: result.publicId,
    coupletNumber: result.coupletNumber,
    coupletType: result.coupletType ?? 'SHER',  // Default to SHER if null
    coupletTypeName: result.coupletTypeName ?? result.coupletType,
    verses: result.verses,
    likeCount: result.likeCount,
    bookmarkCount: result.bookmarkCount,
    shareCount: result.shareCount,
    isLikedByCurrentUser: result.isLiked ?? false,
    isBookmarkedByCurrentUser: result.isBookmarked ?? false,
    createdAt: result.createdAt,
  );
}
