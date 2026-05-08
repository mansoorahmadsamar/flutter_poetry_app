import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_poetry_app/core/auth/auth_provider.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';
import '../models/creator_analytics_model.dart';
import '../models/creator_book_model.dart';
import '../models/creator_fact_model.dart';
import '../models/creator_image_model.dart';
import '../models/creator_translation_model.dart';
import '../models/owned_poet_model.dart';
import '../services/creator_service.dart';

/// CreatorService provider — depends on the configured DioClient.
final creatorServiceProvider = Provider<CreatorService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return CreatorService(dio.dio);
});

/// The user's owned poet profile, or null if they haven't onboarded.
/// 404 from the backend is treated as "no poet" — anything else rethrows.
final ownedPoetProvider = FutureProvider.autoDispose<OwnedPoet?>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) return null;
  final service = ref.watch(creatorServiceProvider);
  try {
    return await service.getMyPoetProfile();
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) return null;
    rethrow;
  }
});

/// All translations for the current user's poet (one entry per language).
final creatorTranslationsProvider =
    FutureProvider.autoDispose<List<CreatorTranslation>>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) return const [];
  final service = ref.watch(creatorServiceProvider);
  try {
    return await service.getMyTranslations();
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) return const [];
    rethrow;
  }
});

/// Gallery images, optionally filtered by type. Pass null for all images.
final creatorImagesProvider =
    FutureProvider.autoDispose.family<List<CreatorImage>, String?>(
  (ref, type) async {
    final service = ref.watch(creatorServiceProvider);
    try {
      return await service.getMyImages(type: type);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const [];
      rethrow;
    }
  },
);

/// Books the user has uploaded.
final creatorBooksProvider =
    FutureProvider.autoDispose<List<CreatorBook>>((ref) async {
  final service = ref.watch(creatorServiceProvider);
  try {
    return await service.getMyBooks();
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) return const [];
    rethrow;
  }
});

/// Facts list (unordered — UI sorts by displayOrder).
final creatorFactsProvider =
    FutureProvider.autoDispose<List<CreatorFact>>((ref) async {
  final service = ref.watch(creatorServiceProvider);
  try {
    return await service.getMyFacts();
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) return const [];
    rethrow;
  }
});

/// Analytics dashboard data.
final creatorAnalyticsProvider =
    FutureProvider.autoDispose<CreatorAnalytics>((ref) async {
  final service = ref.watch(creatorServiceProvider);
  return service.getMyAnalytics();
});
