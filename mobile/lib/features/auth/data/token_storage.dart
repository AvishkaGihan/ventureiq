import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper around [FlutterSecureStorage] for managing auth tokens.
///
/// Stores access and refresh tokens securely using platform-native encryption:
/// - Android: RSA OAEP (key wrapping) + AES-GCM (storage)
/// - iOS: Keychain with [KeychainAccessibility.first_unlock]
///
/// Note: Does NOT use deprecated `encryptedSharedPreferences` (flutter_secure_storage v10.x).
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'viq_access_token';
  static const _refreshTokenKey = 'viq_refresh_token';

  /// Read the stored access token, or `null` if not present.
  Future<String?> readAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  /// Read the stored refresh token, or `null` if not present.
  Future<String?> readRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  /// Write both access and refresh tokens sequentially.
  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Delete both tokens sequentially (used on sign-out or refresh failure).
  Future<void> deleteTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Check if any access token is stored.
  Future<bool> hasTokens() async {
    final token = await readAccessToken();
    return token != null && token.isNotEmpty;
  }
}
