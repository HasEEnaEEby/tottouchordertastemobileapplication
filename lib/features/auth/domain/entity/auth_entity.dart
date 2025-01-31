// features/auth/domain/entity/auth_entity.dart

import 'package:equatable/equatable.dart';

enum UserType { customer, restaurant, admin }

enum AuthStatus {
  authenticated,
  unauthenticated,
  pendingVerification,
  pendingApproval,
  rejected,
  unknown
}

class AuthEntity extends Equatable {
  final String? id;
  final String email;
  final String userType;
  final AuthStatus status;
  final UserProfile profile;
  final AuthMetadata metadata;
  final bool isEmailVerified;
  final String? token;
  final String? refreshToken;
  final RestaurantDetails? restaurantDetails;

  const AuthEntity({
    this.id,
    required this.email,
    required this.userType,
    this.status = AuthStatus.unknown,
    required this.profile,
    required this.metadata,
    this.isEmailVerified = false,
    this.token,
    this.refreshToken,
    this.restaurantDetails,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isCustomer => userType == UserType.customer.name;
  bool get isRestaurant => userType == UserType.restaurant.name;
  bool get isAdmin => userType == UserType.admin.name;
  bool get isPendingVerification => status == AuthStatus.pendingVerification;
  bool get isPendingApproval => status == AuthStatus.pendingApproval;
  bool get isRejected => status == AuthStatus.rejected;

  bool get canAccessDashboard =>
      isAuthenticated &&
      isEmailVerified &&
      (isCustomer || (isRestaurant && !isPendingApproval && !isRejected));

  @override
  List<Object?> get props => [
        id,
        email,
        userType,
        status,
        profile,
        metadata,
        isEmailVerified,
        token,
        refreshToken,
        restaurantDetails,
      ];

  AuthEntity copyWith({
    String? id,
    String? email,
    String? userType,
    AuthStatus? status,
    UserProfile? profile,
    AuthMetadata? metadata,
    bool? isEmailVerified,
    String? token,
    String? refreshToken,
    RestaurantDetails? restaurantDetails,
  }) {
    return AuthEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      status: status ?? this.status,
      profile: profile ?? this.profile,
      metadata: metadata ?? this.metadata,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      restaurantDetails: restaurantDetails ?? this.restaurantDetails,
    );
  }

  factory AuthEntity.fromJson(Map<String, dynamic> json) {
    return AuthEntity(
      id: json['id'],
      email: json['email'],
      userType: json['role'],
      status: _parseStatus(json['status']),
      isEmailVerified: json['isEmailVerified'] ?? false,
      profile: UserProfile.fromJson(json['profile'] ?? {}),
      metadata: AuthMetadata.fromJson(json['metadata'] ?? {}),
      token: json['token'],
      refreshToken: json['refreshToken'],
      restaurantDetails: json['restaurantDetails'] != null
          ? RestaurantDetails.fromJson(json['restaurantDetails'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': userType,
      'status': status.toString(),
      'isEmailVerified': isEmailVerified,
      'profile': profile.toJson(),
      'metadata': metadata.toJson(),
      if (restaurantDetails != null)
        'restaurantDetails': restaurantDetails!.toJson(),
    };
  }

  static AuthStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return AuthStatus.pendingApproval;
      case 'rejected':
        return AuthStatus.rejected;
      case 'approved':
        return AuthStatus.authenticated;
      default:
        return AuthStatus.unknown;
    }
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

class RestaurantDetails extends Equatable {
  final String name;
  final String? location;
  final String? description;
  final String? cuisine;
  final bool isOpen;
  final Map<String, dynamic> additionalDetails;

  const RestaurantDetails({
    required this.name,
    this.location,
    this.description,
    this.cuisine,
    this.isOpen = false,
    this.additionalDetails = const {},
  });

  @override
  List<Object?> get props => [
        name,
        location,
        description,
        cuisine,
        isOpen,
        additionalDetails,
      ];

  factory RestaurantDetails.fromJson(Map<String, dynamic> json) {
    return RestaurantDetails(
      name: json['name'] ?? '',
      location: json['location'],
      description: json['description'],
      cuisine: json['cuisine'],
      isOpen: json['isOpen'] ?? false,
      additionalDetails: json['additionalDetails'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'cuisine': cuisine,
      'isOpen': isOpen,
      'additionalDetails': additionalDetails,
    };
  }
}

// Update UserProfile to match backend
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

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'],
      displayName: json['displayName'],
      phoneNumber: json['phoneNumber'],
      profileImage: json['profileImage'],
      additionalInfo: json['additionalInfo'] ?? {},
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

  factory UserProfile.empty() => const UserProfile();
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

  factory AuthMetadata.fromJson(Map<String, dynamic> json) {
    return AuthMetadata(
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.parse(json['lastUpdatedAt'])
          : null,
      lastLoginIp: json['lastLoginIp'],
      securitySettings: json['securitySettings'] ?? {},
    );
  }

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
