import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';

part 'bookmark_search_state.freezed.dart';

@freezed
class BookmarkSearchState with _$BookmarkSearchState {
  const factory BookmarkSearchState({
    @Default([]) List<PoemModel> results,
    @Default(0) int currentPage,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
    @Default(0) int totalElements,
    String? error,
    String? currentQuery,
    String? poetryTypeFilter,
    String? sortBy,
  }) = _BookmarkSearchState;

  const BookmarkSearchState._();

  bool get isEmpty => results.isEmpty && !isLoading;
  bool get hasResults => results.isNotEmpty;
  bool get hasFilters => poetryTypeFilter != null;
}
