// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'global_search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GlobalSearchState {
  SearchMode get mode => throw _privateConstructorUsedError;
  String get currentQuery => throw _privateConstructorUsedError;
  String? get selectedFilter =>
      throw _privateConstructorUsedError; // Poet filter (publicId)
  String get sortBy =>
      throw _privateConstructorUsedError; // relevance, likes, shares, bookmarks, trending
// Autocomplete data
  AutocompleteResponse? get autocompleteResults =>
      throw _privateConstructorUsedError;
  bool get isLoadingAutocomplete =>
      throw _privateConstructorUsedError; // Search results data
  PaginatedResponse<CoupletSearchResult>? get coupletResults =>
      throw _privateConstructorUsedError;
  bool get isLoadingResults =>
      throw _privateConstructorUsedError; // Discovery data
  List<String> get recentSearches => throw _privateConstructorUsedError;
  TrendingSearchesResponse? get trendingSearches =>
      throw _privateConstructorUsedError;
  RecommendationResponse? get recommendations =>
      throw _privateConstructorUsedError;
  RelatedSearchesResponse? get relatedSearches =>
      throw _privateConstructorUsedError; // Error state
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of GlobalSearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GlobalSearchStateCopyWith<GlobalSearchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GlobalSearchStateCopyWith<$Res> {
  factory $GlobalSearchStateCopyWith(
          GlobalSearchState value, $Res Function(GlobalSearchState) then) =
      _$GlobalSearchStateCopyWithImpl<$Res, GlobalSearchState>;
  @useResult
  $Res call(
      {SearchMode mode,
      String currentQuery,
      String? selectedFilter,
      String sortBy,
      AutocompleteResponse? autocompleteResults,
      bool isLoadingAutocomplete,
      PaginatedResponse<CoupletSearchResult>? coupletResults,
      bool isLoadingResults,
      List<String> recentSearches,
      TrendingSearchesResponse? trendingSearches,
      RecommendationResponse? recommendations,
      RelatedSearchesResponse? relatedSearches,
      String? errorMessage});

  $AutocompleteResponseCopyWith<$Res>? get autocompleteResults;
  $TrendingSearchesResponseCopyWith<$Res>? get trendingSearches;
  $RecommendationResponseCopyWith<$Res>? get recommendations;
  $RelatedSearchesResponseCopyWith<$Res>? get relatedSearches;
}

/// @nodoc
class _$GlobalSearchStateCopyWithImpl<$Res, $Val extends GlobalSearchState>
    implements $GlobalSearchStateCopyWith<$Res> {
  _$GlobalSearchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GlobalSearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? currentQuery = null,
    Object? selectedFilter = freezed,
    Object? sortBy = null,
    Object? autocompleteResults = freezed,
    Object? isLoadingAutocomplete = null,
    Object? coupletResults = freezed,
    Object? isLoadingResults = null,
    Object? recentSearches = null,
    Object? trendingSearches = freezed,
    Object? recommendations = freezed,
    Object? relatedSearches = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as SearchMode,
      currentQuery: null == currentQuery
          ? _value.currentQuery
          : currentQuery // ignore: cast_nullable_to_non_nullable
              as String,
      selectedFilter: freezed == selectedFilter
          ? _value.selectedFilter
          : selectedFilter // ignore: cast_nullable_to_non_nullable
              as String?,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as String,
      autocompleteResults: freezed == autocompleteResults
          ? _value.autocompleteResults
          : autocompleteResults // ignore: cast_nullable_to_non_nullable
              as AutocompleteResponse?,
      isLoadingAutocomplete: null == isLoadingAutocomplete
          ? _value.isLoadingAutocomplete
          : isLoadingAutocomplete // ignore: cast_nullable_to_non_nullable
              as bool,
      coupletResults: freezed == coupletResults
          ? _value.coupletResults
          : coupletResults // ignore: cast_nullable_to_non_nullable
              as PaginatedResponse<CoupletSearchResult>?,
      isLoadingResults: null == isLoadingResults
          ? _value.isLoadingResults
          : isLoadingResults // ignore: cast_nullable_to_non_nullable
              as bool,
      recentSearches: null == recentSearches
          ? _value.recentSearches
          : recentSearches // ignore: cast_nullable_to_non_nullable
              as List<String>,
      trendingSearches: freezed == trendingSearches
          ? _value.trendingSearches
          : trendingSearches // ignore: cast_nullable_to_non_nullable
              as TrendingSearchesResponse?,
      recommendations: freezed == recommendations
          ? _value.recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as RecommendationResponse?,
      relatedSearches: freezed == relatedSearches
          ? _value.relatedSearches
          : relatedSearches // ignore: cast_nullable_to_non_nullable
              as RelatedSearchesResponse?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of GlobalSearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AutocompleteResponseCopyWith<$Res>? get autocompleteResults {
    if (_value.autocompleteResults == null) {
      return null;
    }

    return $AutocompleteResponseCopyWith<$Res>(_value.autocompleteResults!,
        (value) {
      return _then(_value.copyWith(autocompleteResults: value) as $Val);
    });
  }

  /// Create a copy of GlobalSearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrendingSearchesResponseCopyWith<$Res>? get trendingSearches {
    if (_value.trendingSearches == null) {
      return null;
    }

    return $TrendingSearchesResponseCopyWith<$Res>(_value.trendingSearches!,
        (value) {
      return _then(_value.copyWith(trendingSearches: value) as $Val);
    });
  }

  /// Create a copy of GlobalSearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecommendationResponseCopyWith<$Res>? get recommendations {
    if (_value.recommendations == null) {
      return null;
    }

    return $RecommendationResponseCopyWith<$Res>(_value.recommendations!,
        (value) {
      return _then(_value.copyWith(recommendations: value) as $Val);
    });
  }

  /// Create a copy of GlobalSearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RelatedSearchesResponseCopyWith<$Res>? get relatedSearches {
    if (_value.relatedSearches == null) {
      return null;
    }

    return $RelatedSearchesResponseCopyWith<$Res>(_value.relatedSearches!,
        (value) {
      return _then(_value.copyWith(relatedSearches: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GlobalSearchStateImplCopyWith<$Res>
    implements $GlobalSearchStateCopyWith<$Res> {
  factory _$$GlobalSearchStateImplCopyWith(_$GlobalSearchStateImpl value,
          $Res Function(_$GlobalSearchStateImpl) then) =
      __$$GlobalSearchStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {SearchMode mode,
      String currentQuery,
      String? selectedFilter,
      String sortBy,
      AutocompleteResponse? autocompleteResults,
      bool isLoadingAutocomplete,
      PaginatedResponse<CoupletSearchResult>? coupletResults,
      bool isLoadingResults,
      List<String> recentSearches,
      TrendingSearchesResponse? trendingSearches,
      RecommendationResponse? recommendations,
      RelatedSearchesResponse? relatedSearches,
      String? errorMessage});

  @override
  $AutocompleteResponseCopyWith<$Res>? get autocompleteResults;
  @override
  $TrendingSearchesResponseCopyWith<$Res>? get trendingSearches;
  @override
  $RecommendationResponseCopyWith<$Res>? get recommendations;
  @override
  $RelatedSearchesResponseCopyWith<$Res>? get relatedSearches;
}

/// @nodoc
class __$$GlobalSearchStateImplCopyWithImpl<$Res>
    extends _$GlobalSearchStateCopyWithImpl<$Res, _$GlobalSearchStateImpl>
    implements _$$GlobalSearchStateImplCopyWith<$Res> {
  __$$GlobalSearchStateImplCopyWithImpl(_$GlobalSearchStateImpl _value,
      $Res Function(_$GlobalSearchStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of GlobalSearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? currentQuery = null,
    Object? selectedFilter = freezed,
    Object? sortBy = null,
    Object? autocompleteResults = freezed,
    Object? isLoadingAutocomplete = null,
    Object? coupletResults = freezed,
    Object? isLoadingResults = null,
    Object? recentSearches = null,
    Object? trendingSearches = freezed,
    Object? recommendations = freezed,
    Object? relatedSearches = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_$GlobalSearchStateImpl(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as SearchMode,
      currentQuery: null == currentQuery
          ? _value.currentQuery
          : currentQuery // ignore: cast_nullable_to_non_nullable
              as String,
      selectedFilter: freezed == selectedFilter
          ? _value.selectedFilter
          : selectedFilter // ignore: cast_nullable_to_non_nullable
              as String?,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as String,
      autocompleteResults: freezed == autocompleteResults
          ? _value.autocompleteResults
          : autocompleteResults // ignore: cast_nullable_to_non_nullable
              as AutocompleteResponse?,
      isLoadingAutocomplete: null == isLoadingAutocomplete
          ? _value.isLoadingAutocomplete
          : isLoadingAutocomplete // ignore: cast_nullable_to_non_nullable
              as bool,
      coupletResults: freezed == coupletResults
          ? _value.coupletResults
          : coupletResults // ignore: cast_nullable_to_non_nullable
              as PaginatedResponse<CoupletSearchResult>?,
      isLoadingResults: null == isLoadingResults
          ? _value.isLoadingResults
          : isLoadingResults // ignore: cast_nullable_to_non_nullable
              as bool,
      recentSearches: null == recentSearches
          ? _value._recentSearches
          : recentSearches // ignore: cast_nullable_to_non_nullable
              as List<String>,
      trendingSearches: freezed == trendingSearches
          ? _value.trendingSearches
          : trendingSearches // ignore: cast_nullable_to_non_nullable
              as TrendingSearchesResponse?,
      recommendations: freezed == recommendations
          ? _value.recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as RecommendationResponse?,
      relatedSearches: freezed == relatedSearches
          ? _value.relatedSearches
          : relatedSearches // ignore: cast_nullable_to_non_nullable
              as RelatedSearchesResponse?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$GlobalSearchStateImpl implements _GlobalSearchState {
  const _$GlobalSearchStateImpl(
      {this.mode = SearchMode.idle,
      this.currentQuery = '',
      this.selectedFilter,
      this.sortBy = 'relevance',
      this.autocompleteResults,
      this.isLoadingAutocomplete = false,
      this.coupletResults,
      this.isLoadingResults = false,
      final List<String> recentSearches = const [],
      this.trendingSearches,
      this.recommendations,
      this.relatedSearches,
      this.errorMessage})
      : _recentSearches = recentSearches;

  @override
  @JsonKey()
  final SearchMode mode;
  @override
  @JsonKey()
  final String currentQuery;
  @override
  final String? selectedFilter;
// Poet filter (publicId)
  @override
  @JsonKey()
  final String sortBy;
// relevance, likes, shares, bookmarks, trending
// Autocomplete data
  @override
  final AutocompleteResponse? autocompleteResults;
  @override
  @JsonKey()
  final bool isLoadingAutocomplete;
// Search results data
  @override
  final PaginatedResponse<CoupletSearchResult>? coupletResults;
  @override
  @JsonKey()
  final bool isLoadingResults;
// Discovery data
  final List<String> _recentSearches;
// Discovery data
  @override
  @JsonKey()
  List<String> get recentSearches {
    if (_recentSearches is EqualUnmodifiableListView) return _recentSearches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentSearches);
  }

  @override
  final TrendingSearchesResponse? trendingSearches;
  @override
  final RecommendationResponse? recommendations;
  @override
  final RelatedSearchesResponse? relatedSearches;
// Error state
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'GlobalSearchState(mode: $mode, currentQuery: $currentQuery, selectedFilter: $selectedFilter, sortBy: $sortBy, autocompleteResults: $autocompleteResults, isLoadingAutocomplete: $isLoadingAutocomplete, coupletResults: $coupletResults, isLoadingResults: $isLoadingResults, recentSearches: $recentSearches, trendingSearches: $trendingSearches, recommendations: $recommendations, relatedSearches: $relatedSearches, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GlobalSearchStateImpl &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.currentQuery, currentQuery) ||
                other.currentQuery == currentQuery) &&
            (identical(other.selectedFilter, selectedFilter) ||
                other.selectedFilter == selectedFilter) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.autocompleteResults, autocompleteResults) ||
                other.autocompleteResults == autocompleteResults) &&
            (identical(other.isLoadingAutocomplete, isLoadingAutocomplete) ||
                other.isLoadingAutocomplete == isLoadingAutocomplete) &&
            (identical(other.coupletResults, coupletResults) ||
                other.coupletResults == coupletResults) &&
            (identical(other.isLoadingResults, isLoadingResults) ||
                other.isLoadingResults == isLoadingResults) &&
            const DeepCollectionEquality()
                .equals(other._recentSearches, _recentSearches) &&
            (identical(other.trendingSearches, trendingSearches) ||
                other.trendingSearches == trendingSearches) &&
            (identical(other.recommendations, recommendations) ||
                other.recommendations == recommendations) &&
            (identical(other.relatedSearches, relatedSearches) ||
                other.relatedSearches == relatedSearches) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      mode,
      currentQuery,
      selectedFilter,
      sortBy,
      autocompleteResults,
      isLoadingAutocomplete,
      coupletResults,
      isLoadingResults,
      const DeepCollectionEquality().hash(_recentSearches),
      trendingSearches,
      recommendations,
      relatedSearches,
      errorMessage);

  /// Create a copy of GlobalSearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GlobalSearchStateImplCopyWith<_$GlobalSearchStateImpl> get copyWith =>
      __$$GlobalSearchStateImplCopyWithImpl<_$GlobalSearchStateImpl>(
          this, _$identity);
}

abstract class _GlobalSearchState implements GlobalSearchState {
  const factory _GlobalSearchState(
      {final SearchMode mode,
      final String currentQuery,
      final String? selectedFilter,
      final String sortBy,
      final AutocompleteResponse? autocompleteResults,
      final bool isLoadingAutocomplete,
      final PaginatedResponse<CoupletSearchResult>? coupletResults,
      final bool isLoadingResults,
      final List<String> recentSearches,
      final TrendingSearchesResponse? trendingSearches,
      final RecommendationResponse? recommendations,
      final RelatedSearchesResponse? relatedSearches,
      final String? errorMessage}) = _$GlobalSearchStateImpl;

  @override
  SearchMode get mode;
  @override
  String get currentQuery;
  @override
  String? get selectedFilter; // Poet filter (publicId)
  @override
  String get sortBy; // relevance, likes, shares, bookmarks, trending
// Autocomplete data
  @override
  AutocompleteResponse? get autocompleteResults;
  @override
  bool get isLoadingAutocomplete; // Search results data
  @override
  PaginatedResponse<CoupletSearchResult>? get coupletResults;
  @override
  bool get isLoadingResults; // Discovery data
  @override
  List<String> get recentSearches;
  @override
  TrendingSearchesResponse? get trendingSearches;
  @override
  RecommendationResponse? get recommendations;
  @override
  RelatedSearchesResponse? get relatedSearches; // Error state
  @override
  String? get errorMessage;

  /// Create a copy of GlobalSearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GlobalSearchStateImplCopyWith<_$GlobalSearchStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
