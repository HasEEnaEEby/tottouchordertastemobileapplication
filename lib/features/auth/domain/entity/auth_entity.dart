import 'package:equatable/equatable.dart';

enum UserType { customer, restaurant }

enum AuthStatus { authenticated, unauthenticated, unknown }

class AuthEntity extends Equatable {
  final String? id;
  final String email;
  final String userType;
  final AuthStatus status;
  final UserProfile profile;
  final AuthMetadata metadata;

  const AuthEntity({
    this.id,
    required this.email,
    required this.userType,
    this.status = AuthStatus.unknown,
    required this.profile,
    required this.metadata,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isCustomer => userType == UserType.customer.name;
  bool get isRestaurant => userType == UserType.restaurant.name;

  @override
  List<Object?> get props => [
        id,
        email,
        userType,
        status,
        profile,
        metadata,
      ];

  AuthEntity copyWith({
    String? id,
    String? email,
    String? userType,
    AuthStatus? status,
    UserProfile? profile,
    AuthMetadata? metadata,
  }) {
    return AuthEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      status: status ?? this.status,
      profile: profile ?? this.profile,
      metadata: metadata ?? this.metadata,
    );
  }

  factory AuthEntity.unauthenticated() {
    return AuthEntity(
      email: '',
      userType: UserType.customer.name,
      status: AuthStatus.unauthenticated,
      profile: UserProfile.empty(),
      metadata: AuthMetadata.empty(),
    );
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$').hasMatch(password);
  }
}

class UserProfile extends Equatable {
  final String? username;
  final String? displayName;
  final String? phoneNumber;
  final String? profileImage;
  final Map<String, dynamic> additionalInfo;

  const UserProfile({
    this.username,
    this.displayName,
    this.phoneNumber,
    this.profileImage,
    this.additionalInfo = const {},
  });

  @override
  List<Object?> get props => [
        username,
        displayName,
        phoneNumber,
        profileImage,
        additionalInfo,
      ];

  UserProfile copyWith({
    String? username,
    String? displayName,
    String? phoneNumber,
    String? profileImage,
    Map<String, dynamic>? additionalInfo,
  }) {
    return UserProfile(
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  factory UserProfile.empty() {
    return const UserProfile();
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
}

class AuthMetadata extends Equatable {
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final DateTime? lastUpdatedAt;
  final String? lastLoginIp;
  final Map<String, dynamic> securitySettings;

  const AuthMetadata({
    this.createdAt,
    this.lastLoginAt,
    this.lastUpdatedAt,
    this.lastLoginIp,
    this.securitySettings = const {},
  });

  @override
  List<Object?> get props => [
        createdAt,
        lastLoginAt,
        lastUpdatedAt,
        lastLoginIp,
        securitySettings,
      ];

  AuthMetadata copyWith({
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DateTime? lastUpdatedAt,
    String? lastLoginIp,
    Map<String, dynamic>? securitySettings,
  }) {
    return AuthMetadata(
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      lastLoginIp: lastLoginIp ?? this.lastLoginIp,
      securitySettings: securitySettings ?? this.securitySettings,
    );
  }

  factory AuthMetadata.empty() {
    return AuthMetadata(
      createdAt: DateTime.now(),
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
}
