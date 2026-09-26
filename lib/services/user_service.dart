import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/user.dart';

class UserService {
  static const String _kUserId = 'user_id';
  static const String _kToken = 'access_token';
  static const String _kFullName = 'user_full_name';
  static const String _kUsername = 'user_username';
  static const String _kEmail = 'user_email';
  static const String _kImage = 'user_image';
  static const String _kInitials = 'user_initials';
  static const String _kLoggedIn = 'is_logged_in';

  // LOGIN via DummyJSON auth
  Future<User?> login(String username, String password) async {
    final url = Uri.parse('$host/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 60,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveSession(data);
      return User.fromJson(data);
    } else {
      throw Exception('Invalid credentials');
    }
  }

  // Fetch a single user's full data by id (used on Profile screen)
  Future<User> getUserById(int id) async {
    final url = Uri.parse('$host/users/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user: ${response.statusCode}');
    }
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = data['firstName'] ?? '';
    final lastName = data['lastName'] ?? '';
    final initials =
        '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
            .toUpperCase();

    await prefs.setBool(_kLoggedIn, true);
    await prefs.setInt(_kUserId, data['id'] ?? 0);
    await prefs.setString(_kToken, data['accessToken'] ?? data['token'] ?? '');
    await prefs.setString(_kFullName, '$firstName $lastName');
    await prefs.setString(_kUsername, data['username'] ?? '');
    await prefs.setString(_kEmail, data['email'] ?? '');
    await prefs.setString(_kImage, data['image'] ?? '');
    await prefs.setString(_kInitials, initials);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kLoggedIn) ?? false;
  }

  Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kUserId) ?? 0;
  }

  Future<String> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kFullName) ?? '';
  }

  Future<String> getImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kImage) ?? '';
  }

  Future<String> getInitials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kInitials) ?? '';
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}