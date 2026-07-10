import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_role.dart';

class AuthSession {
  const AuthSession({required this.token, required this.role});

  final String token;
  final UserRole role;

  bool get isValid => token.isNotEmpty;
}

class AuthService {
  AuthService._();

  static const _tokenKey = 'auth_token';
  static const _roleKey = 'user_role';
  static const _loggedInKey = 'is_logged_in';

  static Future<AuthSession?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_loggedInKey) ?? false;
    final token = prefs.getString(_tokenKey);
    final role = UserRoleStorage.fromStorage(prefs.getString(_roleKey));

    if (!isLoggedIn || token == null || token.isEmpty || role == null) {
      return null;
    }

    return AuthSession(token: token, role: role);
  }

  static Future<bool> isLoggedIn() async {
    final session = await getSession();
    return session?.isValid ?? false;
  }

  static Future<void> saveLogin({
    required UserRole role,
    String? token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken =
        token ?? 'pg_${role.name}_${DateTime.now().millisecondsSinceEpoch}';

    await prefs.setBool(_loggedInKey, true);
    await prefs.setString(_tokenKey, authToken);
    await prefs.setString(_roleKey, role.storageValue);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
  }
}
