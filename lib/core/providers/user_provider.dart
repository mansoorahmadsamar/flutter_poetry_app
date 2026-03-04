import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/user_model.dart';
import '../network/dto/api_response.dart';
import '../network/dio_client.dart';
import '../auth/auth_provider.dart';
import '../storage/secure_storage.dart';

final _logger = Logger();

/// Provider for fetching the current authenticated user's profile
/// Uses autoDispose to clear cache when not in use (e.g., after logout)
final userProfileProvider =
    FutureProvider.autoDispose<UserModel>((ref) async {
  // Watch auth state to invalidate when user changes
  final authState = ref.watch(authProvider);

  // Only fetch if user is authenticated
  if (!authState.isAuthenticated) {
    throw Exception('User not authenticated');
  }

  _logger.i('');
  _logger.i('═══════════════════════════════════════════════════════');
  _logger.i('📡 FETCHING USER PROFILE');
  _logger.i('═══════════════════════════════════════════════════════');

  try {
    final dioClient = ref.watch(dioClientProvider);

    _logger.i('🌐 Sending GET request to /api/auth/me');
    final response =
        await dioClient.get<Map<String, dynamic>>('/api/auth/me');

    _logger.i('📥 Received response with status: ${response.statusCode}');

    if (response.statusCode == 200 && response.data != null) {
      _logger.i('📦 Response data: ${response.data}');

      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final user = apiResponse.data!;
        _logger.i('✅ Successfully parsed user profile');
        _logger.i('   Full Name: ${user.fullName}');
        _logger.i('   Email: ${user.email}');
        _logger.i('   Provider: ${user.provider}');
        _logger.i('   Status: ${user.isActive ? 'Active' : 'Inactive'}');

        // Ensure numeric userId is stored for X-User-Id header (backfill for existing sessions)
        final rawData = response.data!['data'] as Map<String, dynamic>?;
        final numericUserId = rawData?['userId']?.toString();
        if (numericUserId != null && numericUserId.isNotEmpty) {
          final secureStorage = ref.read(secureStorageProvider);
          final storedUserId = await secureStorage.getUserId();
          if (storedUserId == null || storedUserId.isEmpty || storedUserId.contains('-')) {
            await secureStorage.saveUserId(numericUserId);
            _logger.i('   User ID backfilled: $numericUserId');
          }
        }

        _logger.i('═══════════════════════════════════════════════════════');
        _logger.i('');

        return user;
      }

      _logger.e('❌ API returned success=false');
      _logger.e('   Message: ${apiResponse.message}');
      throw Exception(
          apiResponse.message);
    }

    _logger.e('❌ Unexpected status code: ${response.statusCode}');
    throw Exception('Failed to fetch user profile');
  } catch (e, stackTrace) {
    _logger.e('');
    _logger.e('═══════════════════════════════════════════════════════');
    _logger.e('❌ ERROR FETCHING USER PROFILE');
    _logger.e('   Error: $e');
    _logger.e('   Stack Trace: $stackTrace');
    _logger.e('═══════════════════════════════════════════════════════');
    _logger.e('');
    rethrow;
  }
});
