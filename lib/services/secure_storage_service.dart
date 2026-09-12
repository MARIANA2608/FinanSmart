import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(
      key: _accessTokenKey,
      value: accessToken,
    );

    await _storage.write(
      key: _refreshTokenKey,
      value: refreshToken,
    );
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(
      key: _accessTokenKey,
      value: token,
    );
  }

  static Future<String?> getToken() async {
    return _storage.read(
      key: _accessTokenKey,
    );
  }

  static Future<String?> getRefreshToken() async {
    return _storage.read(
      key: _refreshTokenKey,
    );
  }

  static Future<void> saveUser({
    required String id,
    required String name,
    String? email,
  }) async {
    await _storage.write(
      key: _userIdKey,
      value: id,
    );

    await _storage.write(
      key: _userNameKey,
      value: name,
    );

    if (email != null) {
      await _storage.write(
        key: _userEmailKey,
        value: email,
      );
    }
  }

  static Future<String?> getUserId() async {
    return _storage.read(
      key: _userIdKey,
    );
  }

  static Future<String?> getUserName() async {
    return _storage.read(
      key: _userNameKey,
    );
  }

  static Future<String?> getUserEmail() async {
    return _storage.read(
      key: _userEmailKey,
    );
  }

  static Future<bool> hasSession() async {
    final accessToken = await getToken();
    final refreshToken = await getRefreshToken();

    return (accessToken != null && accessToken.isNotEmpty) ||
        (refreshToken != null && refreshToken.isNotEmpty);
  }

  static Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}