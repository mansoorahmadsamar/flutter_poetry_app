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
    coupletType: result.coupletType,
    coupletTypeName: result.coupletType, // Use type as name for now
    verses: result.verses,
    likeCount: result.likeCount,
    bookmarkCount: result.bookmarkCount,
    shareCount: result.shareCount,
    isLikedByCurrentUser: result.isLiked,
    isBookmarkedByCurrentUser: result.isBookmarked,
    createdAt: null, // Not provided in search results
  );
}
