import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_collection_model.freezed.dart';
part 'image_collection_model.g.dart';

@freezed
class SaveImageRequest with _$SaveImageRequest {
  const factory SaveImageRequest({
    @Default('My Images') String collectionName,
    @Default(false) bool isFavorite,
  }) = _SaveImageRequest;

  factory SaveImageRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveImageRequestFromJson(json);
}

@freezed
class CollectionStatsModel with _$CollectionStatsModel {
  const factory CollectionStatsModel({
    @Default(0) int totalImages,
    @Default(0) int favoriteCount,
    @Default(0) int collectionCount,
    @Default([]) List<String> collectionNames,
  }) = _CollectionStatsModel;

  factory CollectionStatsModel.fromJson(Map<String, dynamic> json) =>
      _$CollectionStatsModelFromJson(json);
}
