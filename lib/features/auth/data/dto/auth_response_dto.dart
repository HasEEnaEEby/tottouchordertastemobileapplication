class AuthResponseDTO {
  final String id;
  final String email;
  final String role;
  final String token;
  final UserProfileDTO profile;

  AuthResponseDTO({
    required this.id,
    required this.email,
    required this.role,
    required this.token,
    required this.profile,
  });

  factory AuthResponseDTO.fromJson(Map<String, dynamic> json) {
    return AuthResponseDTO(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      token: json['token'],
      profile: UserProfileDTO.fromJson(json['profile']),
    );
  }
}

class UserProfileDTO {
  final String username;
  final Map<String, dynamic> metadata;

  UserProfileDTO({
    required this.username,
    required this.metadata,
  });

  factory UserProfileDTO.fromJson(Map<String, dynamic> json) {
    return UserProfileDTO(
      username: json['username'],
      metadata: json['metadata'] ?? {},
    );
  }
}
