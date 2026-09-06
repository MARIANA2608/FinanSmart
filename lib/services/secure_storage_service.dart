import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';

  /// Guarda el token de acceso de forma cifrada.
  static Future<void> saveToken(String token) async {
    await _storage.write(
      key: _accessTokenKey,
      value: token,
    );
  }

  /// Recupera el token almacenado.
  static Future<String?> getToken() async {
    return _storage.read(
      key: _accessTokenKey,
    );
  }

  /// Guarda información mínima del usuario.
  static Future<void> saveUser({
    required String id,
    required String name,
  }) async {
    await _storage.write(
      key: _userIdKey,
      value: id,
    );

    await _storage.write(
      key: _userNameKey,
      value: name,
    );
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

  /// Indica si existe una sesión almacenada.
  static Future<bool> hasSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Elimina completamente los datos seguros al cerrar sesión.
  static Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}