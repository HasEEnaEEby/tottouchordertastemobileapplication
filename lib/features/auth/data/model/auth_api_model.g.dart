// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthApiModel _$AuthApiModelFromJson(Map<String, dynamic> json) => AuthApiModel(
      id: json['_id'] as String? ?? '',
      email: json['email'] as String,
      userType: json['role'] as String,
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      profile:
          UserProfileModel.fromJson(json['profile'] as Map<String, dynamic>),
      metadata:
          AuthMetadataModel.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthApiModelToJson(AuthApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'email': instance.email,
      'role': instance.userType,
      'token': instance.token,
      'refreshToken': instance.refreshToken,
      'isEmailVerified': instance.isEmailVerified,
      'profile': instance.profile.toJson(),
      'metadata': instance.metadata.toJson(),
    };

UserProfileModel _$UserProfileModelFromJson(Map<String, dynamic> json) =>
    UserProfileModel(
      username: json['username'] as String? ?? '',
      displayName: json['displayName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profileImage: json['profileImage'] as String?,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>? ?? {},
    );

Map<String, dynamic> _$UserProfileModelToJson(UserProfileModel instance) =>
    <String, dynamic>{
      'username': instance.username,
      'displayName': instance.displayName,
      'phoneNumber': instance.phoneNumber,
      'profileImage': instance.profileImage,
      'additionalInfo': instance.additionalInfo,
    };

AuthMetadataModel _$AuthMetadataModelFromJson(Map<String, dynamic> json) =>
    AuthMetadataModel(
      createdAt: AuthMetadataModel._dateFromJson(json['createdAt']),
      lastLoginAt: AuthMetadataModel._dateFromJson(json['lastLoginAt']),
      lastUpdatedAt: AuthMetadataModel._dateFromJson(json['lastUpdatedAt']),
      lastLoginIp: json['lastLoginIp'] as String?,
      securitySettings: json['securitySettings'] as Map<String, dynamic>? ?? {},
    );

Map<String, dynamic> _$AuthMetadataModelToJson(AuthMetadataModel instance) =>
    <String, dynamic>{
      'createdAt': AuthMetadataModel._dateToJson(instance.createdAt),
      'lastLoginAt': AuthMetadataModel._dateToJson(instance.lastLoginAt),
      'lastUpdatedAt': AuthMetadataModel._dateToJson(instance.lastUpdatedAt),
      'lastLoginIp': instance.lastLoginIp,
      'securitySettings': instance.securitySettings,
    };
