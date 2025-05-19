import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService apiService;
  bool isLoadingLogin = false;
  bool isLoadingRegister = false;
  bool isLoggedIn = false;
  String? token;

  AuthProvider(this.apiService);

  Future<bool> login(String email, String password) async {
    isLoadingLogin = true;
    notifyListeners();
    try {
      final loginResponse = await apiService.login(email, password);
      if (!loginResponse.error && loginResponse.loginResult != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', loginResponse.loginResult!.token);
        isLoggedIn = true;
        token = loginResponse.loginResult!.token;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error
    }
    isLoadingLogin = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(User user) async {
    isLoadingRegister = true;
    notifyListeners();
    try {
      final result = await apiService.register(user);
      isLoadingRegister = false;
      notifyListeners();
      return result;
    } catch (e) {
      isLoadingRegister = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    isLoggedIn = false;
    token = null;
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    isLoggedIn = token != null;
    notifyListeners();
  }
}
