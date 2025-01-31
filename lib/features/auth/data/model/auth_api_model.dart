import 'package:json_annotation/json_annotation.dart';

import '../../domain/entity/auth_entity.dart';

part 'auth_api_model.g.dart';

@JsonSerializable()
class AuthApiModel {
  @JsonKey(name: '_id', defaultValue: '')
  final String id;
  final String email;
  @JsonKey(name: 'role')
  final String userType;
  final String? token;
  final String? refreshToken;
  @JsonKey(name: 'isEmailVerified', defaultValue: false)
  final bool isEmailVerified;
  final UserProfileModel profile;
  final AuthMetadataModel metadata;

  const AuthApiModel({
    required this.id,
    required this.email,
    required this.userType,
    this.token,
    this.refreshToken,
    required this.isEmailVerified,
    required this.profile,
    required this.metadata,
  });

  factory AuthApiModel.fromJson(Map<String, dynamic> json) =>
      _$AuthApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthApiModelToJson(this);

  AuthEntity toEntity() {
    return AuthEntity(
      id: id,
      email: email,
      userType: userType,
      status: isEmailVerified
          ? AuthStatus.authenticated
          : AuthStatus.pendingVerification,
      profile: profile.toEntity(),
      metadata: metadata.toEntity(),
    );
  }
}

@JsonSerializable()
class UserProfileModel {
  final String? username;
  final String? displayName;
  final String? phoneNumber;
  final String? profileImage;
  @JsonKey(defaultValue: {})
  final Map<String, dynamic> additionalInfo;

  const UserProfileModel({
    this.username,
    this.displayName,
    this.phoneNumber,
    this.profileImage,
    this.additionalInfo = const {},
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);

  UserProfile toEntity() {
    return UserProfile(
      username: username,
      displayName: displayName,
      phoneNumber: phoneNumber,
      profileImage: profileImage,
      additionalInfo: additionalInfo,
    );
  }
}

@JsonSerializable()
class AuthMetadataModel {
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? createdAt;
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? lastLoginAt;
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? lastUpdatedAt;
  final String? lastLoginIp;
  @JsonKey(defaultValue: {})
  final Map<String, dynamic> securitySettings;

  const AuthMetadataModel({
    this.createdAt,
    this.lastLoginAt,
    this.lastUpdatedAt,
    this.lastLoginIp,
    this.securitySettings = const {},
  });

  factory AuthMetadataModel.fromJson(Map<String, dynamic> json) =>
      _$AuthMetadataModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthMetadataModelToJson(this);

  AuthMetadata toEntity() {
    return AuthMetadata(
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      lastUpdatedAt: lastUpdatedAt,
      lastLoginIp: lastLoginIp,
      securitySettings: securitySettings,
    );
  }

  static DateTime? _dateFromJson(String? date) =>
      date == null ? null : DateTime.parse(date);

  static String? _dateToJson(DateTime? date) => date?.toIso8601String();
}
