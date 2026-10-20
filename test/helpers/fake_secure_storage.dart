import 'package:flutter_poetry_app/core/constants/app_constants.dart';
import 'package:flutter_poetry_app/core/storage/secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A real [SecureStorageService] backed by flutter_secure_storage's in-memory
/// test platform, so the service's own code runs but no keychain is touched.
SecureStorageService fakeSecureStorage({
  String? accessToken,
  String? refreshToken,
  String? userId,
  String? email,
}) {
  FlutterSecureStorage.setMockInitialValues({
    if (accessToken != null) AppConstants.accessTokenKey: accessToken,
    if (refreshToken != null) AppConstants.refreshTokenKey: refreshToken,
    if (userId != null) AppConstants.userIdKey: userId,
    if (email != null) AppConstants.userEmailKey: email,
  });
  return SecureStorageService(const FlutterSecureStorage());
}
