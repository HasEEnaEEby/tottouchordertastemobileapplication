class AuthRequestDTO {
  final String email;
  final String password;
  final String? role;
  final String? username;

  AuthRequestDTO({
    required this.email,
    required this.password,
    this.role,
    this.username,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      if (role != null) 'role': role,
      if (username != null) 'username': username,
    };
  }
}