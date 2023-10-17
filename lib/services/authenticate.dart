import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:app_emergen/constants.dart';
import 'package:app_emergen/model/user.dart';
import 'package:app_emergen/services/helper.dart';

class APIUtils {
  static const BASE_URL = "https://appemergencia.com/api";

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data, [String? token]) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token'
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}

class UserAuth {
  final String? accessToken;
  final String? tokenType;
  
  UserAuth({this.accessToken, this.tokenType});

  factory UserAuth.fromJson(Map<String, dynamic> json) {
    return UserAuth(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }
}

class UserAuthentication {
  Future<UserAuth> register({
    required String name,
    required String email,
    required String password,
    required String celular,
    required String dni,
  }) async {
    final data = {
      'name': name,
      'email': email,
      'password': password,
      'celular': celular,
      'dni': dni,
    };

    final response = await APIUtils.post('register', data);

    return UserAuth.fromJson(response);
  }

  Future<UserAuth> login({
    required String email,
    required String password,
  }) async {
    final data = {
      'email': email,
      'password': password,
    };

    final response = await APIUtils.post('login', data);

    return UserAuth.fromJson(response);
  }

  resetPassword(String email) {}
}
