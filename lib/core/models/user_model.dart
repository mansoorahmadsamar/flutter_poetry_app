import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../utils/api_placeholder.dart';

part 'user_model.g.dart';

/// User model representing the authenticated user
@JsonSerializable()
class UserModel extends Equatable {
  final String id;
  final String email;

  /// `GET /api/auth/me` builds its answer as a plain map
  /// (`AuthController.getCurrentUser`), so the backend's `"-"` placeholder
  /// does not apply: a NULL `users.full_name` / `username` / `provider`
  /// arrives as JSON null. `full_name` is null when the sign-in provider
  /// gave no name (e.g. Apple "Hide my name"); the profile used to fail to
  /// load for those users (T-181).
  @PlaceholderStringConverter()
  final String? fullName;
  @PlaceholderStringConverter()
  final String? username;
  @PlaceholderStringConverter()
  final String? profileImageUrl;
  @PlaceholderStringConverter()
  final String? provider;
  @JsonKey(defaultValue: true)
  final bool isActive;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.username,
    this.profileImageUrl,
    this.provider,
    this.isActive = true,
  });

  /// The name to show: the full name, else the part of the email before `@`.
  String get displayName =>
      fullName ?? (email.contains('@') ? email.split('@').first : email);

  /// `@username`, or null when the user has none.
  String? get handle => username == null ? null : '@$username';

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
