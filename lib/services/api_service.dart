import 'package:http/http.dart' as http;
import 'package:keep_in_touch/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final client = http.Client();
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConfig.tokenKey);
  }
  
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
  
  static Future handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please login again');
    } else {
      throw Exception('Request failed: ${response.statusCode}');
    }
  }
}