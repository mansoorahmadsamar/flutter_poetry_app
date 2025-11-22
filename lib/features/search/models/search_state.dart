import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poet_model.dart';

part 'search_state.freezed.dart';

/// State for search pagination
@freezed
class SearchPaginationState with _$SearchPaginationState {
  const factory SearchPaginationState({
    @Default([]) List<PoetModel> results,
    @Default(0) int currentPage,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
    @Default(0) int totalElements,
    String? error,
    String? currentQuery,
  }) = _SearchPaginationState;

  const SearchPaginationState._();

  bool get isEmpty => results.isEmpty && !isLoading;
  bool get hasResults => results.isNotEmpty;
}

/// Filter state for search
@freezed
class SearchFilters with _$SearchFilters {
  const factory SearchFilters({
    @Default([]) List<String> selectedEras,
    @Default([]) List<String> selectedGenders,
    @Default(false) bool onlyFeatured,
    @Default(false) bool onlyTrending,
  }) = _SearchFilters;

  const SearchFilters._();

  bool get hasActiveFilters =>
      selectedEras.isNotEmpty ||
      selectedGenders.isNotEmpty ||
      onlyFeatured ||
      onlyTrending;

  int get activeFilterCount =>
      selectedEras.length +
      selectedGenders.length +
      (onlyFeatured ? 1 : 0) +
      (onlyTrending ? 1 : 0);
}
