import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage(this._storage);

  // Keys
  static const String _accessTokenKey = 'access_token';
  // static const String _refreshTokenKey = 'refresh_token';

  // Token operations
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // Future<void> saveRefreshToken(String token) async {
  //   await _storage.write(key: _refreshTokenKey, value: token);
  // }

  // Future<String?> getRefreshToken() async {
  //   return await _storage.read(key: _refreshTokenKey);
  // }

  // Clear all tokens
  Future<void> clearAllTokens() async {
    await _storage.delete(key: _accessTokenKey);
    // await _storage.delete(key: _refreshTokenKey);
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

final secureStorageProvider = Provider<SecureStorage>((ref) {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  return SecureStorage(storage);
});
