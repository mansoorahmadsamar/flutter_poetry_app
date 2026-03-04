// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'canvas_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CanvasStateModelImpl _$$CanvasStateModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CanvasStateModelImpl(
      backgroundImagePath: json['backgroundImagePath'] as String?,
      textLayers: (json['textLayers'] as List<dynamic>?)
              ?.map((e) => TextLayerModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      selectedLayerId: json['selectedLayerId'] as String?,
      canvasScale: (json['canvasScale'] as num?)?.toDouble() ?? 1.0,
      canvasOffset: json['canvasOffset'] == null
          ? Offset.zero
          : const OffsetConverter()
              .fromJson(json['canvasOffset'] as Map<String, dynamic>),
      canvasSize: json['canvasSize'] == null
          ? const Size(1080, 1920)
          : const SizeConverter()
              .fromJson(json['canvasSize'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CanvasStateModelImplToJson(
        _$CanvasStateModelImpl instance) =>
    <String, dynamic>{
      'backgroundImagePath': instance.backgroundImagePath,
      'textLayers': instance.textLayers,
      'selectedLayerId': instance.selectedLayerId,
      'canvasScale': instance.canvasScale,
      'canvasOffset': const OffsetConverter().toJson(instance.canvasOffset),
      'canvasSize': const SizeConverter().toJson(instance.canvasSize),
    };
