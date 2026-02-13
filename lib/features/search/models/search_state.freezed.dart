// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SearchPaginationState {
  List<PoetModel> get results => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  int get totalElements => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String? get currentQuery => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SearchPaginationStateCopyWith<SearchPaginationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchPaginationStateCopyWith<$Res> {
  factory $SearchPaginationStateCopyWith(SearchPaginationState value,
          $Res Function(SearchPaginationState) then) =
      _$SearchPaginationStateCopyWithImpl<$Res, SearchPaginationState>;
  @useResult
  $Res call(
      {List<PoetModel> results,
      int currentPage,
      bool isLoading,
      bool isLoadingMore,
      bool hasMore,
      int totalElements,
      String? error,
      String? currentQuery});
}

/// @nodoc
class _$SearchPaginationStateCopyWithImpl<$Res,
        $Val extends SearchPaginationState>
    implements $SearchPaginationStateCopyWith<$Res> {
  _$SearchPaginationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? results = null,
    Object? currentPage = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? hasMore = null,
    Object? totalElements = null,
    Object? error = freezed,
    Object? currentQuery = freezed,
  }) {
    return _then(_value.copyWith(
      results: null == results
          ? _value.results
          : results // ignore: cast_nullable_to_non_nullable
              as List<PoetModel>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      totalElements: null == totalElements
          ? _value.totalElements
          : totalElements // ignore: cast_nullable_to_non_nullable
              as int,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      currentQuery: freezed == currentQuery
          ? _value.currentQuery
          : currentQuery // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchPaginationStateImplCopyWith<$Res>
    implements $SearchPaginationStateCopyWith<$Res> {
  factory _$$SearchPaginationStateImplCopyWith(
          _$SearchPaginationStateImpl value,
          $Res Function(_$SearchPaginationStateImpl) then) =
      __$$SearchPaginationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<PoetModel> results,
      int currentPage,
      bool isLoading,
      bool isLoadingMore,
      bool hasMore,
      int totalElements,
      String? error,
      String? currentQuery});
}

/// @nodoc
class __$$SearchPaginationStateImplCopyWithImpl<$Res>
    extends _$SearchPaginationStateCopyWithImpl<$Res,
        _$SearchPaginationStateImpl>
    implements _$$SearchPaginationStateImplCopyWith<$Res> {
  __$$SearchPaginationStateImplCopyWithImpl(_$SearchPaginationStateImpl _value,
      $Res Function(_$SearchPaginationStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? results = null,
    Object? currentPage = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? hasMore = null,
    Object? totalElements = null,
    Object? error = freezed,
    Object? currentQuery = freezed,
  }) {
    return _then(_$SearchPaginationStateImpl(
      results: null == results
          ? _value._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<PoetModel>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      totalElements: null == totalElements
          ? _value.totalElements
          : totalElements // ignore: cast_nullable_to_non_nullable
              as int,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      currentQuery: freezed == currentQuery
          ? _value.currentQuery
          : currentQuery // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$SearchPaginationStateImpl extends _SearchPaginationState {
  const _$SearchPaginationStateImpl(
      {final List<PoetModel> results = const [],
      this.currentPage = 0,
      this.isLoading = false,
      this.isLoadingMore = false,
      this.hasMore = true,
      this.totalElements = 0,
      this.error,
      this.currentQuery})
      : _results = results,
        super._();

  final List<PoetModel> _results;
  @override
  @JsonKey()
  List<PoetModel> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isLoadingMore;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  @JsonKey()
  final int totalElements;
  @override
  final String? error;
  @override
  final String? currentQuery;

  @override
  String toString() {
    return 'SearchPaginationState(results: $results, currentPage: $currentPage, isLoading: $isLoading, isLoadingMore: $isLoadingMore, hasMore: $hasMore, totalElements: $totalElements, error: $error, currentQuery: $currentQuery)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchPaginationStateImpl &&
            const DeepCollectionEquality().equals(other._results, _results) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.totalElements, totalElements) ||
                other.totalElements == totalElements) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.currentQuery, currentQuery) ||
                other.currentQuery == currentQuery));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_results),
      currentPage,
      isLoading,
      isLoadingMore,
      hasMore,
      totalElements,
      error,
      currentQuery);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchPaginationStateImplCopyWith<_$SearchPaginationStateImpl>
      get copyWith => __$$SearchPaginationStateImplCopyWithImpl<
          _$SearchPaginationStateImpl>(this, _$identity);
}

abstract class _SearchPaginationState extends SearchPaginationState {
  const factory _SearchPaginationState(
      {final List<PoetModel> results,
      final int currentPage,
      final bool isLoading,
      final bool isLoadingMore,
      final bool hasMore,
      final int totalElements,
      final String? error,
      final String? currentQuery}) = _$SearchPaginationStateImpl;
  const _SearchPaginationState._() : super._();

  @override
  List<PoetModel> get results;
  @override
  int get currentPage;
  @override
  bool get isLoading;
  @override
  bool get isLoadingMore;
  @override
  bool get hasMore;
  @override
  int get totalElements;
  @override
  String? get error;
  @override
  String? get currentQuery;
  @override
  @JsonKey(ignore: true)
  _$$SearchPaginationStateImplCopyWith<_$SearchPaginationStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SearchFilters {
  List<String> get selectedEras => throw _privateConstructorUsedError;
  List<String> get selectedGenders => throw _privateConstructorUsedError;
  bool get onlyFeatured => throw _privateConstructorUsedError;
  bool get onlyTrending => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SearchFiltersCopyWith<SearchFilters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchFiltersCopyWith<$Res> {
  factory $SearchFiltersCopyWith(
          SearchFilters value, $Res Function(SearchFilters) then) =
      _$SearchFiltersCopyWithImpl<$Res, SearchFilters>;
  @useResult
  $Res call(
      {List<String> selectedEras,
      List<String> selectedGenders,
      bool onlyFeatured,
      bool onlyTrending});
}

/// @nodoc
class _$SearchFiltersCopyWithImpl<$Res, $Val extends SearchFilters>
    implements $SearchFiltersCopyWith<$Res> {
  _$SearchFiltersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedEras = null,
    Object? selectedGenders = null,
    Object? onlyFeatured = null,
    Object? onlyTrending = null,
  }) {
    return _then(_value.copyWith(
      selectedEras: null == selectedEras
          ? _value.selectedEras
          : selectedEras // ignore: cast_nullable_to_non_nullable
              as List<String>,
      selectedGenders: null == selectedGenders
          ? _value.selectedGenders
          : selectedGenders // ignore: cast_nullable_to_non_nullable
              as List<String>,
      onlyFeatured: null == onlyFeatured
          ? _value.onlyFeatured
          : onlyFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      onlyTrending: null == onlyTrending
          ? _value.onlyTrending
          : onlyTrending // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchFiltersImplCopyWith<$Res>
    implements $SearchFiltersCopyWith<$Res> {
  factory _$$SearchFiltersImplCopyWith(
          _$SearchFiltersImpl value, $Res Function(_$SearchFiltersImpl) then) =
      __$$SearchFiltersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> selectedEras,
      List<String> selectedGenders,
      bool onlyFeatured,
      bool onlyTrending});
}

/// @nodoc
class __$$SearchFiltersImplCopyWithImpl<$Res>
    extends _$SearchFiltersCopyWithImpl<$Res, _$SearchFiltersImpl>
    implements _$$SearchFiltersImplCopyWith<$Res> {
  __$$SearchFiltersImplCopyWithImpl(
      _$SearchFiltersImpl _value, $Res Function(_$SearchFiltersImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedEras = null,
    Object? selectedGenders = null,
    Object? onlyFeatured = null,
    Object? onlyTrending = null,
  }) {
    return _then(_$SearchFiltersImpl(
      selectedEras: null == selectedEras
          ? _value._selectedEras
          : selectedEras // ignore: cast_nullable_to_non_nullable
              as List<String>,
      selectedGenders: null == selectedGenders
          ? _value._selectedGenders
          : selectedGenders // ignore: cast_nullable_to_non_nullable
              as List<String>,
      onlyFeatured: null == onlyFeatured
          ? _value.onlyFeatured
          : onlyFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      onlyTrending: null == onlyTrending
          ? _value.onlyTrending
          : onlyTrending // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$SearchFiltersImpl extends _SearchFilters {
  const _$SearchFiltersImpl(
      {final List<String> selectedEras = const [],
      final List<String> selectedGenders = const [],
      this.onlyFeatured = false,
      this.onlyTrending = false})
      : _selectedEras = selectedEras,
        _selectedGenders = selectedGenders,
        super._();

  final List<String> _selectedEras;
  @override
  @JsonKey()
  List<String> get selectedEras {
    if (_selectedEras is EqualUnmodifiableListView) return _selectedEras;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedEras);
  }

  final List<String> _selectedGenders;
  @override
  @JsonKey()
  List<String> get selectedGenders {
    if (_selectedGenders is EqualUnmodifiableListView) return _selectedGenders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedGenders);
  }

  @override
  @JsonKey()
  final bool onlyFeatured;
  @override
  @JsonKey()
  final bool onlyTrending;

  @override
  String toString() {
    return 'SearchFilters(selectedEras: $selectedEras, selectedGenders: $selectedGenders, onlyFeatured: $onlyFeatured, onlyTrending: $onlyTrending)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchFiltersImpl &&
            const DeepCollectionEquality()
                .equals(other._selectedEras, _selectedEras) &&
            const DeepCollectionEquality()
                .equals(other._selectedGenders, _selectedGenders) &&
            (identical(other.onlyFeatured, onlyFeatured) ||
                other.onlyFeatured == onlyFeatured) &&
            (identical(other.onlyTrending, onlyTrending) ||
                other.onlyTrending == onlyTrending));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_selectedEras),
      const DeepCollectionEquality().hash(_selectedGenders),
      onlyFeatured,
      onlyTrending);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchFiltersImplCopyWith<_$SearchFiltersImpl> get copyWith =>
      __$$SearchFiltersImplCopyWithImpl<_$SearchFiltersImpl>(this, _$identity);
}

abstract class _SearchFilters extends SearchFilters {
  const factory _SearchFilters(
      {final List<String> selectedEras,
      final List<String> selectedGenders,
      final bool onlyFeatured,
      final bool onlyTrending}) = _$SearchFiltersImpl;
  const _SearchFilters._() : super._();

  @override
  List<String> get selectedEras;
  @override
  List<String> get selectedGenders;
  @override
  bool get onlyFeatured;
  @override
  bool get onlyTrending;
  @override
  @JsonKey(ignore: true)
  _$$SearchFiltersImplCopyWith<_$SearchFiltersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
