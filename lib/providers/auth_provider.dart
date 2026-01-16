import 'package:flutter/foundation.dart';
import 'package:keep_in_touch/models/token.dart';
import 'package:keep_in_touch/models/user.dart';
import 'package:keep_in_touch/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  Token? _token;
  User? _user;
  String? _username;
  bool _isLoading = false;
  String? _errorMessage;

  Token? get token => _token;
  User? get user => _user;
  String? get username => _username;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null;

  Future<bool> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        final token = await _authService.getToken();
        if (token != null) {
          _token = Token(accessToken: token, tokenType: 'Bearer');
        }
      }
      _isLoading = false;
      notifyListeners();
      return isAuth;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> login(String name, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _token = await _authService.login(name, password);
      _username = name;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _token = null;
      _user = null;
      _username = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}