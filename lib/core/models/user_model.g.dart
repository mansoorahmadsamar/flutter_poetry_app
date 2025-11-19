// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      username: json['username'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      provider: json['provider'] as String,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'fullName': instance.fullName,
      'username': instance.username,
      'profileImageUrl': instance.profileImageUrl,
      'provider': instance.provider,
      'isActive': instance.isActive,
    };
