import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:keep_in_touch/config/api_config.dart';
import 'package:keep_in_touch/models/token.dart';
import 'package:keep_in_touch/models/user.dart';
import 'package:keep_in_touch/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<Token> login(String name, String password) async {
    final headers = await ApiService.getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/users/login'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'password': password,
      }),
    );

    await ApiService.handleResponse(response);

    final token = Token.fromJson(jsonDecode(response.body));
    await saveToken(token);
    return token;
  }

  Future<User?> getCurrentUser(int userId) async {
    final headers = await ApiService.getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/users/$userId'),
      headers: headers,
    );

    await ApiService.handleResponse(response);
    return User.fromJson(jsonDecode(response.body));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConfig.tokenKey);
  }

  Future<void> saveToken(Token token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.tokenKey, token.accessToken);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConfig.tokenKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}