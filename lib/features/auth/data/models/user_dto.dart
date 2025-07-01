class UserDTO {
  final String username;
  final String email;
  final String token;

  UserDTO({
    required this.username,
    required this.email,
    required this.token,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      username: json['userName'] ?? '', 
      email: json['email'] ?? '',
      token: json['token'] ?? '',
    );
  }
}