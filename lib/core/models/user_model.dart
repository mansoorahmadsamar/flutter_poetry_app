import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// User model representing the authenticated user
@JsonSerializable()
class UserModel extends Equatable {
  final int id;
  final String email;
  final String fullName;
  final String username;
  final String? profileImageUrl;
  final String provider;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.username,
    this.profileImageUrl,
    required this.provider,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        username,
        profileImageUrl,
        provider,
        isActive,
      ];
}
