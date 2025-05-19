import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService apiService;

  AuthRepository(this.apiService);

  Future<bool> register(User user) async {
    return await apiService.register(user);
  }

  Future<String?> login(String email, String password) async {
    try {
      final loginResponse = await apiService.login(email, password);
      if (!loginResponse.error && loginResponse.loginResult != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', loginResponse.loginResult!.token);
        await prefs.setString('name', loginResponse.loginResult!.name);
        return loginResponse.loginResult!.token;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('name');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }
}
