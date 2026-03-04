// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_layer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TextLayerModelImpl _$$TextLayerModelImplFromJson(Map<String, dynamic> json) =>
    _$TextLayerModelImpl(
      id: json['id'] as String,
      text: json['text'] as String,
      languageCode: json['languageCode'] as String,
      position: const OffsetConverter()
          .fromJson(json['position'] as Map<String, dynamic>),
      fontSize: (json['fontSize'] as num).toDouble(),
      textColor:
          const ColorConverter().fromJson((json['textColor'] as num).toInt()),
      backgroundColor: _$JsonConverterFromJson<int, Color>(
          json['backgroundColor'], const ColorConverter().fromJson),
      strokeColor: _$JsonConverterFromJson<int, Color>(
          json['strokeColor'], const ColorConverter().fromJson),
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble(),
      shadowColor: _$JsonConverterFromJson<int, Color>(
          json['shadowColor'], const ColorConverter().fromJson),
      shadowOffset: _$JsonConverterFromJson<Map<String, dynamic>, Offset>(
          json['shadowOffset'], const OffsetConverter().fromJson),
      shadowBlur: (json['shadowBlur'] as num?)?.toDouble(),
      textAlign:
          const TextAlignConverter().fromJson(json['textAlign'] as String),
      rotation: (json['rotation'] as num).toDouble(),
      scale: (json['scale'] as num).toDouble(),
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.8,
      isSelected: json['isSelected'] as bool? ?? false,
    );

Map<String, dynamic> _$$TextLayerModelImplToJson(
        _$TextLayerModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'languageCode': instance.languageCode,
      'position': const OffsetConverter().toJson(instance.position),
      'fontSize': instance.fontSize,
      'textColor': const ColorConverter().toJson(instance.textColor),
      'backgroundColor': _$JsonConverterToJson<int, Color>(
          instance.backgroundColor, const ColorConverter().toJson),
      'strokeColor': _$JsonConverterToJson<int, Color>(
          instance.strokeColor, const ColorConverter().toJson),
      'strokeWidth': instance.strokeWidth,
      'shadowColor': _$JsonConverterToJson<int, Color>(
          instance.shadowColor, const ColorConverter().toJson),
      'shadowOffset': _$JsonConverterToJson<Map<String, dynamic>, Offset>(
          instance.shadowOffset, const OffsetConverter().toJson),
      'shadowBlur': instance.shadowBlur,
      'textAlign': const TextAlignConverter().toJson(instance.textAlign),
      'rotation': instance.rotation,
      'scale': instance.scale,
      'opacity': instance.opacity,
      'lineHeight': instance.lineHeight,
      'isSelected': instance.isSelected,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
