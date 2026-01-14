import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class LocalAuthRepository implements AuthRepository {
  static const _usersKey = 'auth_users_v1';
  static const _sessionKey = 'auth_session_email_v1';

  final SharedPreferences _prefs;
  final Uuid _uuid;

  LocalAuthRepository(this._prefs, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  @override
  Future<AuthUser?> getCurrentUser() async {
    final email = _prefs.getString(_sessionKey);
    if (email == null || email.trim().isEmpty) return null;
    return AuthUser(email: email);
  }

  @override
  Future<AuthUser> signUp({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      throw const AuthException('Email is required.');
    }
    if (password.length < 6) {
      throw const AuthException('Password must be at least 6 characters.');
    }

    final users = _loadUsers();
    if (users.containsKey(normalizedEmail)) {
      throw const AuthException('An account with this email already exists.');
    }

    final salt = _uuid.v4();
    final hash = _hashPassword(password: password, salt: salt);

    users[normalizedEmail] = {
      'salt': salt,
      'hash': hash,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await _saveUsers(users);
    await _prefs.setString(_sessionKey, normalizedEmail);

    return AuthUser(email: normalizedEmail);
  }

  @override
  Future<AuthUser> signIn({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      throw const AuthException('Email is required.');
    }

    final users = _loadUsers();
    final record = users[normalizedEmail];
    if (record == null) {
      throw const AuthException('No account found for this email.');
    }

    final salt = (record['salt'] ?? '') as String;
    final expectedHash = (record['hash'] ?? '') as String;
    final actualHash = _hashPassword(password: password, salt: salt);

    if (expectedHash != actualHash) {
      throw const AuthException('Incorrect password.');
    }

    await _prefs.setString(_sessionKey, normalizedEmail);
    return AuthUser(email: normalizedEmail);
  }

  @override
  Future<void> signOut() async {
    await _prefs.remove(_sessionKey);
  }

  Map<String, Map<String, Object?>> _loadUsers() {
    final raw = _prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return {};

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return {};

    return decoded.map((k, v) {
      if (v is Map<String, dynamic>) {
        return MapEntry(k, v.map((kk, vv) => MapEntry(kk, vv)));
      }
      return MapEntry(k, <String, Object?>{});
    });
  }

  Future<void> _saveUsers(Map<String, Map<String, Object?>> users) async {
    await _prefs.setString(_usersKey, jsonEncode(users));
  }

  String _hashPassword({required String password, required String salt}) {
    final bytes = utf8.encode('$salt:$password');
    return sha256.convert(bytes).toString();
  }
}
