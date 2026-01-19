import '../core/models/user_model.dart';
import 'package:uuid/uuid.dart';

/// Mock authentication service
class AuthService {
  final _uuid = const Uuid();
  
  // Mock user database
  final Map<String, Map<String, String>> _users = {};

  /// Sign up with email and password
  Future<User?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check if user already exists
    if (_users.containsKey(email)) {
      throw Exception('User already exists');
    }

    // Create new user
    _users[email] = {
      'password': password,
      'username': username,
    };

    final user = User(
      id: _uuid.v4(),
      username: username,
      email: email,
      lastActiveDate: DateTime.now(),
      createdAt: DateTime.now(),
    );

    return user;
  }

  /// Login with email and password
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check credentials
    final userData = _users[email];
    if (userData == null || userData['password'] != password) {
      return null;
    }

    // Return user
    return User(
      id: _uuid.v4(),
      username: userData['username']!,
      email: email,
      lastActiveDate: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  /// Logout
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Reset password
  Future<bool> resetPassword({required String email}) async {
    await Future.delayed(const Duration(seconds: 1));
    return _users.containsKey(email);
  }
}
