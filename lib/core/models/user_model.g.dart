// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: const PlaceholderStringConverter().fromJson(json['fullName']),
      username: const PlaceholderStringConverter().fromJson(json['username']),
      profileImageUrl:
          const PlaceholderStringConverter().fromJson(json['profileImageUrl']),
      provider: const PlaceholderStringConverter().fromJson(json['provider']),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'fullName': const PlaceholderStringConverter().toJson(instance.fullName),
      'username': const PlaceholderStringConverter().toJson(instance.username),
      'profileImageUrl':
          const PlaceholderStringConverter().toJson(instance.profileImageUrl),
      'provider': const PlaceholderStringConverter().toJson(instance.provider),
      'isActive': instance.isActive,
    };
