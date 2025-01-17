import 'package:hive/hive.dart';

import '../../domain/entity/auth_entity.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: 0)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String userType;

  @HiveField(3)
  final String status;

  @HiveField(4)
  final UserProfileHiveModel profile;

  @HiveField(5)
  final AuthMetadataHiveModel metadata;

  AuthHiveModel({
    this.id,
    required this.email,
    required this.userType,
    required this.status,
    required this.profile,
    required this.metadata,
  });

  // Create a copy method to help with Hive object management
  AuthHiveModel copy() {
    return AuthHiveModel(
      id: id,
      email: email,
      userType: userType,
      status: status,
      profile: UserProfileHiveModel(
        username: profile.username,
        displayName: profile.displayName,
        phoneNumber: profile.phoneNumber,
        profileImage: profile.profileImage,
        additionalInfo: Map.from(profile.additionalInfo),
      ),
      metadata: AuthMetadataHiveModel(
        createdAt: metadata.createdAt,
        lastLoginAt: metadata.lastLoginAt,
        lastUpdatedAt: metadata.lastUpdatedAt,
        lastLoginIp: metadata.lastLoginIp,
        securitySettings: Map.from(metadata.securitySettings),
      ),
    );
  }

  factory AuthHiveModel.fromJson(Map<String, dynamic> json) {
    return AuthHiveModel(
      id: json['id'] as String?,
      email: json['email'] as String,
      userType: json['userType'] as String,
      status: json['status'] as String? ?? 'unknown',
      profile: UserProfileHiveModel.fromJson(
          json['profile'] as Map<String, dynamic>? ?? {}),
      metadata: AuthMetadataHiveModel.fromJson(
          json['metadata'] as Map<String, dynamic>? ?? {}),
    );
  }

  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      id: entity.id,
      email: entity.email,
      userType: entity.userType,
      status: entity.status.name,
      profile: UserProfileHiveModel.fromEntity(entity.profile),
      metadata: AuthMetadataHiveModel.fromEntity(entity.metadata),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'userType': userType,
      'status': status,
      'profile': profile.toJson(),
      'metadata': metadata.toJson(),
    };
  }

  AuthEntity toEntity() {
    return AuthEntity(
      id: id,
      email: email,
      userType: userType,
      status: AuthStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => AuthStatus.unknown,
      ),
      profile: profile.toEntity(),
      metadata: metadata.toEntity(),
    );
  }
}

@HiveType(typeId: 1)
class UserProfileHiveModel extends HiveObject {
  @HiveField(0)
  final String? username;

  @HiveField(1)
  final String? displayName;

  @HiveField(2)
  final String? phoneNumber;

  @HiveField(3)
  final String? profileImage;

  @HiveField(4)
  final Map<String, dynamic> additionalInfo;

  UserProfileHiveModel({
    this.username,
    this.displayName,
    this.phoneNumber,
    this.profileImage,
    this.additionalInfo = const {},
  });

  // Add copy method for UserProfileHiveModel
  UserProfileHiveModel copy() {
    return UserProfileHiveModel(
      username: username,
      displayName: displayName,
      phoneNumber: phoneNumber,
      profileImage: profileImage,
      additionalInfo: Map.from(additionalInfo),
    );
  }

  factory UserProfileHiveModel.fromJson(Map<String, dynamic> json) {
    return UserProfileHiveModel(
      username: json['username'] as String?,
      displayName: json['displayName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profileImage: json['profileImage'] as String?,
      additionalInfo: json['additionalInfo'] != null 
          ? Map<String, dynamic>.from(json['additionalInfo'] as Map) 
          : {},
    );
  }

  factory UserProfileHiveModel.fromEntity(UserProfile entity) {
    return UserProfileHiveModel(
      username: entity.username,
      displayName: entity.displayName,
      phoneNumber: entity.phoneNumber,
      profileImage: entity.profileImage,
      additionalInfo: Map<String, dynamic>.from(entity.additionalInfo),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'additionalInfo': additionalInfo,
    };
  }

  UserProfile toEntity() {
    return UserProfile(
      username: username,
      displayName: displayName,
      phoneNumber: phoneNumber,
      profileImage: profileImage,
      additionalInfo: Map<String, dynamic>.from(additionalInfo),
    );
  }
}

@HiveType(typeId: 2)
class AuthMetadataHiveModel extends HiveObject {
  @HiveField(0)
  final DateTime? createdAt;

  @HiveField(1)
  final DateTime? lastLoginAt;

  @HiveField(2)
  final DateTime? lastUpdatedAt;

  @HiveField(3)
  final String? lastLoginIp;

  @HiveField(4)
  final Map<String, dynamic> securitySettings;

  AuthMetadataHiveModel({
    this.createdAt,
    this.lastLoginAt,
    this.lastUpdatedAt,
    this.lastLoginIp,
    this.securitySettings = const {},
  });

  // Add copy method for AuthMetadataHiveModel
  AuthMetadataHiveModel copy() {
    return AuthMetadataHiveModel(
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      lastUpdatedAt: lastUpdatedAt,
      lastLoginIp: lastLoginIp,
      securitySettings: Map.from(securitySettings),
    );
  }

  factory AuthMetadataHiveModel.fromJson(Map<String, dynamic> json) {
    return AuthMetadataHiveModel(
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.parse(json['lastUpdatedAt'] as String)
          : null,
      lastLoginIp: json['lastLoginIp'] as String?,
      securitySettings: json['securitySettings'] != null
          ? Map<String, dynamic>.from(json['securitySettings'] as Map)
          : {},
    );
  }

  factory AuthMetadataHiveModel.fromEntity(AuthMetadata entity) {
    return AuthMetadataHiveModel(
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
      lastUpdatedAt: entity.lastUpdatedAt,
      lastLoginIp: entity.lastLoginIp,
      securitySettings: Map<String, dynamic>.from(entity.securitySettings),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
      'lastLoginIp': lastLoginIp,
      'securitySettings': securitySettings,
    };
  }

  AuthMetadata toEntity() {
    return AuthMetadata(
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      lastUpdatedAt: lastUpdatedAt,
      lastLoginIp: lastLoginIp,
      securitySettings: Map<String, dynamic>.from(securitySettings),
    );
  }
}