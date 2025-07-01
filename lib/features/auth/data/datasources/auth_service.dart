import 'dart:convert';
import 'dart:io';

import 'package:vacapp/core/constants/endpoints.dart';
import 'package:vacapp/features/auth/data/models/user_dto.dart';
import 'package:vacapp/features/auth/data/models/user_request_dto.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<UserDTO> login({required String usernameOrEmail, required String password}) async {
    final Uri uri = Uri.parse(Endpoints.login);
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        UserRequestDto(
          usernameOrEmail: usernameOrEmail,
          password: password,
        ).toJson(isSignUp: false),
      ),
    );

    if (response.statusCode == HttpStatus.ok) {
      final json = jsonDecode(response.body);
      return UserDTO.fromJson(json);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<UserDTO> signUp({
    required String username,
    required String password,
    required String email,
  }) async {
    final Uri uri = Uri.parse(Endpoints.register);
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        UserRequestDto(
          usernameOrEmail: username,
          password: password,
          email: email,
        ).toJson(isSignUp: true),
      ),
    );

    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      final json = jsonDecode(response.body);
      return UserDTO.fromJson(json);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }
}