import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import '../models/creator_analytics_model.dart';
import '../models/creator_book_model.dart';
import '../models/creator_fact_model.dart';
import '../models/creator_image_model.dart';
import '../models/creator_poem_model.dart';
import '../models/creator_translation_model.dart';
import '../models/owned_poet_model.dart';

/// Single service that wraps every `/api/me/poet-profile` and
/// `/api/me/poet/*` endpoint. Constructed by [CreatorService.new] with a
/// configured Dio that already attaches Authorization headers via
/// [AuthInterceptor].
class CreatorService {
  CreatorService(this._dio);

  final Dio _dio;
  final Logger _log = Logger();

  static const _profileBase = '/api/me/poet-profile';
  static const _meBase = '/api/me/poet';
  static const _publicBase = '/api/poets';

  // ── Profile / Onboarding ───────────────────────────────────────────

  /// `POST /api/me/poet-profile` — create a brand-new poet (instant verified).
  Future<OwnedPoet> createPoetProfile({
    required String primaryLanguageCode,
    required String name,
    String? penName,
    String? shortBio,
    String? biography,
    String? slug,
  }) async {
    final res = await _dio.post(
      _profileBase,
      data: {
        'primaryLanguageCode': primaryLanguageCode,
        'name': name,
        if (penName != null) 'penName': penName,
        if (shortBio != null) 'shortBio': shortBio,
        if (biography != null) 'biography': biography,
        if (slug != null) 'slug': slug,
      },
    );
    return _unwrapPoet(res, 'createPoetProfile');
  }

  /// `POST /api/poets/{publicId}/claim` — claim an existing poet.
  Future<Map<String, dynamic>> claimPoet({
    required String publicId,
    required String proofUrl,
    String? note,
  }) async {
    final res = await _dio.post(
      '$_publicBase/$publicId/claim',
      data: {
        'proofUrl': proofUrl,
        if (note != null) 'note': note,
      },
    );
    final wrapped = ApiResponse<Map<String, dynamic>>.fromJson(
      res.data as Map<String, dynamic>,
      (j) => j as Map<String, dynamic>,
    );
    if (!wrapped.success) {
      throw Exception(wrapped.message);
    }
    return wrapped.data ?? const {};
  }

  /// `GET /api/me/poet-profile` — current user's owned poet (or 404 if none).
  Future<OwnedPoet> getMyPoetProfile({String lang = 'ur'}) async {
    final res = await _dio.get(_profileBase, queryParameters: {'lang': lang});
    return _unwrapPoet(res, 'getMyPoetProfile');
  }

  /// `PUT /api/me/poet-profile` — update primary-language profile fields.
  Future<OwnedPoet> updateMyPoetProfile(
    Map<String, dynamic> patch, {
    String lang = 'ur',
  }) async {
    final res = await _dio.put(
      _profileBase,
      queryParameters: {'lang': lang},
      data: patch,
    );
    return _unwrapPoet(res, 'updateMyPoetProfile');
  }

  // ── Poems ───────────────────────────────────────────────────────────

  Future<PaginatedResponse<CreatorPoem>> getMyPoems({
    int page = 0,
    int size = 20,
    String sortBy = 'date',
  }) async {
    final res = await _dio.get(
      '$_meBase/poems',
      queryParameters: {'page': page, 'size': size, 'sortBy': sortBy},
    );
    final api = ApiResponse<Map<String, dynamic>>.fromJson(
      res.data as Map<String, dynamic>,
      (j) => j as Map<String, dynamic>,
    );
    if (!api.success || api.data == null) {
      throw Exception(api.message);
    }
    return PaginatedResponse<CreatorPoem>.fromJson(
      api.data!,
      (j) => CreatorPoem.fromJson(j as Map<String, dynamic>? ?? {}),
    );
  }

  Future<CreatorPoem> composePoem({
    required String title,
    required String content,
    required String poetryType,
    String languageCode = 'ur',
    String script = 'ARABIC',
    String? categoryId,
    List<String> tagSlugs = const [],
    int? yearWritten,
    bool isPublic = true,
  }) async {
    final res = await _dio.post('$_meBase/poems', data: {
      'title': title,
      'content': content,
      'poetryType': poetryType,
      'languageCode': languageCode,
      'script': script,
      if (categoryId != null) 'categoryId': categoryId,
      if (tagSlugs.isNotEmpty) 'tagSlugs': tagSlugs,
      if (yearWritten != null) 'yearWritten': yearWritten,
      'isPublic': isPublic,
    });
    return _unwrapPoem(res);
  }

  Future<CreatorPoem> updatePoem(
    String publicId,
    Map<String, dynamic> patch,
  ) async {
    final res = await _dio.put('$_meBase/poems/$publicId', data: patch);
    return _unwrapPoem(res);
  }

  Future<void> deletePoem(String publicId) =>
      _dio.delete('$_meBase/poems/$publicId');

  // ── Images ──────────────────────────────────────────────────────────

  Future<List<CreatorImage>> getMyImages({String? type}) async {
    final res = await _dio.get(
      '$_meBase/images',
      queryParameters: type != null ? {'type': type} : null,
    );
    final api = ApiResponse<List<dynamic>>.fromJson(
      res.data as Map<String, dynamic>,
      (j) => j as List<dynamic>,
    );
    if (!api.success || api.data == null) return const [];
    return api.data!
        .map((e) => CreatorImage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CreatorImage> uploadImage({
    required String filePath,
    String imageType = 'GALLERY',
    bool isProfileImage = false,
    String? caption,
    String? altText,
    int? displayOrder,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath,
          filename: filePath.split('/').last),
      'imageType': imageType,
      'isProfileImage': isProfileImage,
      if (caption != null) 'caption': caption,
      if (altText != null) 'altText': altText,
      if (displayOrder != null) 'displayOrder': displayOrder,
    });
    final res = await _dio.post(
      '$_meBase/images/upload',
      data: form,
      options: Options(
        receiveTimeout: const Duration(minutes: 2),
        sendTimeout: const Duration(minutes: 2),
      ),
    );
    return _unwrapJson(res, CreatorImage.fromJson);
  }

  Future<CreatorImage> updateImage(
    String publicId,
    Map<String, dynamic> patch,
  ) async {
    final res = await _dio.put('$_meBase/images/$publicId', data: patch);
    return _unwrapJson(res, CreatorImage.fromJson);
  }

  Future<void> deleteImage(String publicId) =>
      _dio.delete('$_meBase/images/$publicId');

  // ── Facts ───────────────────────────────────────────────────────────

  Future<List<CreatorFact>> getMyFacts() async {
    final res = await _dio.get('$_meBase/facts');
    final api = ApiResponse<List<dynamic>>.fromJson(
      res.data as Map<String, dynamic>,
      (j) => j as List<dynamic>,
    );
    if (!api.success || api.data == null) return const [];
    return api.data!
        .map((e) => CreatorFact.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFact({
    required String fact,
    required String languageCode,
    int? displayOrder,
  }) async {
    await _dio.post('$_meBase/facts', data: {
      'fact': fact,
      'languageCode': languageCode,
      if (displayOrder != null) 'displayOrder': displayOrder,
    });
  }

  Future<void> deleteFact(String publicId) =>
      _dio.delete('$_meBase/facts/$publicId');

  // ── Books ───────────────────────────────────────────────────────────

  Future<List<CreatorBook>> getMyBooks() async {
    final res = await _dio.get('$_meBase/books');
    final api = ApiResponse<List<dynamic>>.fromJson(
      res.data as Map<String, dynamic>,
      (j) => j as List<dynamic>,
    );
    if (!api.success || api.data == null) return const [];
    return api.data!
        .map((e) => CreatorBook.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CreatorBook> createBook({
    required String title,
    int? yearPublished,
    String? description,
    String? publisher,
    String languageCode = 'ur',
    String? filePath,
    String? fileType, // 'PDF' or 'EPUB' if filePath set
  }) async {
    final formMap = <String, dynamic>{
      'title': title,
      if (yearPublished != null) 'yearPublished': yearPublished,
      if (description != null) 'description': description,
      if (publisher != null) 'publisher': publisher,
      'languageCode': languageCode,
    };
    if (filePath != null && fileType != null) {
      formMap['file'] =
          await MultipartFile.fromFile(filePath, filename: filePath.split('/').last);
      formMap['fileType'] = fileType;
    }
    final res = await _dio.post(
      '$_meBase/books',
      data: FormData.fromMap(formMap),
      options: Options(
        receiveTimeout: const Duration(minutes: 5),
        sendTimeout: const Duration(minutes: 5),
      ),
    );
    return _unwrapJson(res, CreatorBook.fromJson);
  }

  Future<CreatorBook> updateBook(
    String publicId,
    Map<String, dynamic> patch,
  ) async {
    final res = await _dio.put('$_meBase/books/$publicId', data: patch);
    return _unwrapJson(res, CreatorBook.fromJson);
  }

  Future<void> deleteBook(String publicId) =>
      _dio.delete('$_meBase/books/$publicId');

  Future<CreatorBook> uploadBookFile({
    required String publicId,
    required String filePath,
    required String kind, // 'pdf' | 'epub' | 'cover'
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath,
          filename: filePath.split('/').last),
    });
    final res = await _dio.post(
      '$_meBase/books/$publicId/upload-$kind',
      data: form,
      options: Options(
        receiveTimeout: const Duration(minutes: 5),
        sendTimeout: const Duration(minutes: 5),
      ),
    );
    return _unwrapJson(res, CreatorBook.fromJson);
  }

  // ── Translations ────────────────────────────────────────────────────

  Future<List<CreatorTranslation>> getMyTranslations() async {
    final res = await _dio.get('$_meBase/translations');
    final api = ApiResponse<List<dynamic>>.fromJson(
      res.data as Map<String, dynamic>,
      (j) => j as List<dynamic>,
    );
    if (!api.success || api.data == null) return const [];
    return api.data!
        .map((e) => CreatorTranslation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addTranslation({
    required String languageCode,
    required String name,
    String? penName,
    String? shortBio,
    String? biography,
  }) async {
    await _dio.post('$_meBase/translations', data: {
      'languageCode': languageCode,
      'name': name,
      if (penName != null) 'penName': penName,
      if (shortBio != null) 'shortBio': shortBio,
      if (biography != null) 'biography': biography,
    });
  }

  Future<void> updateTranslation(
    String languageCode,
    Map<String, dynamic> patch,
  ) async {
    await _dio.put('$_meBase/translations/$languageCode', data: patch);
  }

  // ── Analytics ───────────────────────────────────────────────────────

  Future<CreatorAnalytics> getMyAnalytics() async {
    final res = await _dio.get('$_meBase/analytics');
    return _unwrapJson(res, CreatorAnalytics.fromJson);
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  OwnedPoet _unwrapPoet(Response res, String op) {
    final api = ApiResponse<Map<String, dynamic>>.fromJson(
      res.data as Map<String, dynamic>,
      (j) => j as Map<String, dynamic>,
    );
    if (!api.success || api.data == null) {
      _log.w('⚠️  $op failed: ${api.message}');
      throw Exception(api.message);
    }
    return OwnedPoet.fromJson(api.data!);
  }

  CreatorPoem _unwrapPoem(Response res) {
    final api = ApiResponse<Map<String, dynamic>>.fromJson(
      res.data as Map<String, dynamic>,
      (j) => j as Map<String, dynamic>,
    );
    if (!api.success || api.data == null) {
      throw Exception(api.message);
    }
    return CreatorPoem.fromJson(api.data!);
  }

  T _unwrapJson<T>(Response res, T Function(Map<String, dynamic>) parser) {
    final api = ApiResponse<Map<String, dynamic>>.fromJson(
      res.data as Map<String, dynamic>,
      (j) => j as Map<String, dynamic>,
    );
    if (!api.success || api.data == null) {
      throw Exception(api.message);
    }
    return parser(api.data!);
  }
}
