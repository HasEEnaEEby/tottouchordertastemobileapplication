class AuthRequestDTO {
  final String email;
  final String password;
  final String role;
  final String? adminCode;
  final String? username;

  AuthRequestDTO({
    required this.email,
    required this.password,
    required this.role,
    this.adminCode,
    this.username,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email.trim().toLowerCase(),
      'password': password,
      'role': role.toLowerCase(),
      if (adminCode != null) 'adminCode': adminCode,
      if (username != null) 'username': username,
    };
  }
}
