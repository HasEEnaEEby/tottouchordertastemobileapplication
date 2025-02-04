import 'package:json_annotation/json_annotation.dart';

import '../../domain/entity/auth_entity.dart';

part 'auth_api_model.g.dart';

@JsonSerializable(explicitToJson: true)
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

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    // Handle nested 'data' structure from backend
    final userData = json['data']?['user'] ?? json['user'] ?? json;

    return AuthApiModel(
      id: userData['_id'] ?? userData['id'] ?? '',
      email: userData['email'] ?? '',
      userType: userData['role'] ?? userData['userType'] ?? 'customer',
      token: json['data']?['token'] ?? userData['token'],
      refreshToken: json['data']?['refreshToken'] ?? userData['refreshToken'],
      isEmailVerified: userData['isEmailVerified'] ?? false,
      profile: userData['profile'] != null
          ? UserProfileModel.fromJson(userData['profile'])
          : const UserProfileModel(),
      metadata: userData['metadata'] != null
          ? AuthMetadataModel.fromJson(userData['metadata'])
          : const AuthMetadataModel(),
    );
  }

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
      token: token,
      refreshToken: refreshToken,
      isEmailVerified: isEmailVerified,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class UserProfileModel {
  @JsonKey(defaultValue: '')
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

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // Handle potential null or missing fields
    return UserProfileModel(
      username: json['username'],
      displayName: json['displayName'] ?? json['name'],
      phoneNumber: json['phoneNumber'] ?? json['contact'],
      profileImage: json['profileImage'] ?? json['avatar'],
      additionalInfo: json['additionalInfo'] ?? {},
    );
  }

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

@JsonSerializable(explicitToJson: true)
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

  factory AuthMetadataModel.fromJson(Map<String, dynamic> json) {
    return AuthMetadataModel(
      createdAt: _dateFromJson(json['createdAt']),
      lastLoginAt: _dateFromJson(json['lastLoginAt']),
      lastUpdatedAt: _dateFromJson(json['updatedAt'] ?? json['lastUpdatedAt']),
      lastLoginIp: json['lastLoginIp'],
      securitySettings: json['securitySettings'] ?? {},
    );
  }

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

  static DateTime? _dateFromJson(String? date) {
    if (date == null) return null;
    try {
      return DateTime.parse(date);
    } catch (e) {
      print('Error parsing date: $date');
      return null;
    }
  }

  static String? _dateToJson(DateTime? date) => date?.toIso8601String();
}
