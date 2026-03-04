import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import '../services/poet_service.dart';
import '../models/poet_model.dart';
import '../models/poet_profile_model.dart';
import '../models/poet_image_model.dart';
import '../models/poet_book_model.dart';
import '../models/poet_video_model.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';

// Re-export from core language_provider for backward compatibility
export 'package:flutter_poetry_app/core/providers/language_provider.dart'
    show selectedLanguageProvider;

final Logger _logger = Logger();

// ============= SERVICE PROVIDER =============
final poetServiceProvider = Provider<PoetService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PoetService(dioClient.dio);
});

// ============= SEARCH & FILTER STATE =============

class PoetFilterState {
  final String? gender;
  final String? era;
  final List<String> tags;
  final String sortBy;
  final String sortDir;

  PoetFilterState({
    this.gender,
    this.era,
    this.tags = const [],
    this.sortBy = 'name',
    this.sortDir = 'asc',
  });

  PoetFilterState copyWith({
    String? gender,
    String? era,
    List<String>? tags,
    String? sortBy,
    String? sortDir,
  }) {
    return PoetFilterState(
      gender: gender ?? this.gender,
      era: era ?? this.era,
      tags: tags ?? this.tags,
      sortBy: sortBy ?? this.sortBy,
      sortDir: sortDir ?? this.sortDir,
    );
  }

  void reset() {}
}

class PoetFilterNotifier extends StateNotifier<PoetFilterState> {
  PoetFilterNotifier() : super(PoetFilterState());

  void setGender(String? gender) {
    state = state.copyWith(gender: gender);
    _logger.i('🔍 Filter gender set to: $gender');
  }

  void setEra(String? era) {
    state = state.copyWith(era: era);
    _logger.i('🔍 Filter era set to: $era');
  }

  void toggleTag(String tag) {
    final tags = List<String>.from(state.tags);
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    state = state.copyWith(tags: tags);
    _logger.i('🔍 Tags updated: ${tags.join(", ")}');
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void setSortDir(String sortDir) {
    state = state.copyWith(sortDir: sortDir);
  }

  void reset() {
    state = PoetFilterState();
    _logger.i('🔄 Filters reset');
  }
}

final poetsFilterProvider =
    StateNotifierProvider<PoetFilterNotifier, PoetFilterState>((ref) {
  return PoetFilterNotifier();
});

// Search query state
final poetsSearchQueryProvider = StateProvider<String>((ref) => '');

// ============= POETS LIST PROVIDERS =============

/// Get all poets with pagination
final allPoetsProvider = FutureProvider.autoDispose.family<
    PaginatedResponse<PoetModel>,
    int>((ref, page) async {
  final service = ref.watch(poetServiceProvider);
  final lang = ref.watch(selectedLanguageProvider);

  try {
    final result = await service.getAllPoets(
      page: page,
      size: 10,
      lang: lang,
    );
    _logger.i('✅ All poets page $page loaded');
    return result;
  } catch (e) {
    _logger.e('❌ Error loading poets: $e');
    rethrow;
  }
});

/// Get featured poets
final featuredPoetsProvider = FutureProvider.autoDispose<
    PaginatedResponse<PoetModel>>((ref) async {
  final service = ref.watch(poetServiceProvider);
  final lang = ref.watch(selectedLanguageProvider);

  try {
    final result = await service.getFeaturedPoets(lang: lang);
    _logger.i('✅ Featured poets loaded');
    return result;
  } catch (e) {
    _logger.e('❌ Error loading featured poets: $e');
    rethrow;
  }
});

/// Get trending poets
final trendingPoetsProvider = FutureProvider.autoDispose<
    PaginatedResponse<PoetModel>>((ref) async {
  final service = ref.watch(poetServiceProvider);
  final lang = ref.watch(selectedLanguageProvider);

  try {
    final result = await service.getTrendingPoets(lang: lang);
    _logger.i('✅ Trending poets loaded');
    return result;
  } catch (e) {
    _logger.e('❌ Error loading trending poets: $e');
    rethrow;
  }
});

/// Get top poets by poem count
final topPoetsByPoemCountProvider = FutureProvider.autoDispose<
    PaginatedResponse<PoetModel>>((ref) async {
  final service = ref.watch(poetServiceProvider);
  final lang = ref.watch(selectedLanguageProvider);

  try {
    final result = await service.getTopPoetsByPoemCount(lang: lang);
    _logger.i('✅ Top poets by poem count loaded');
    return result;
  } catch (e) {
    _logger.e('❌ Error loading top poets: $e');
    rethrow;
  }
});

/// Get top poets by views
final topPoetsByViewsProvider = FutureProvider.autoDispose<
    PaginatedResponse<PoetModel>>((ref) async {
  final service = ref.watch(poetServiceProvider);
  final lang = ref.watch(selectedLanguageProvider);

  try {
    final result = await service.getTopPoetsByViews(lang: lang);
    _logger.i('✅ Top poets by views loaded');
    return result;
  } catch (e) {
    _logger.e('❌ Error loading top poets: $e');
    rethrow;
  }
});

/// Get poets by gender
final poetsByGenderProvider = FutureProvider.autoDispose.family<
    PaginatedResponse<PoetModel>,
    String>((ref, gender) async {
  final service = ref.watch(poetServiceProvider);
  final lang = ref.watch(selectedLanguageProvider);

  try {
    final result = await service.getPoetsByGender(
      gender: gender,
      lang: lang,
    );
    _logger.i('✅ Poets by gender ($gender) loaded');
    return result;
  } catch (e) {
    _logger.e('❌ Error loading poets by gender: $e');
    rethrow;
  }
});

/// Get poets by era
final poetsByEraProvider = FutureProvider.autoDispose.family<
    PaginatedResponse<PoetModel>,
    String>((ref, era) async {
  final service = ref.watch(poetServiceProvider);
  final lang = ref.watch(selectedLanguageProvider);

  try {
    final result = await service.getPoetsByEra(
      era: era,
      lang: lang,
    );
    _logger.i('✅ Poets by era ($era) loaded');
    return result;
  } catch (e) {
    _logger.e('❌ Error loading poets by era: $e');
    rethrow;
  }
});

/// Get poets by tag
final poetsByTagProvider = FutureProvider.autoDispose.family<
    PaginatedResponse<PoetModel>,
    String>((ref, tagSlug) async {
  final service = ref.watch(poetServiceProvider);
  final lang = ref.watch(selectedLanguageProvider);

  try {
    final result = await service.getPoetsByTag(
      tagSlug: tagSlug,
      lang: lang,
    );
    _logger.i('✅ Poets by tag ($tagSlug) loaded');
    return result;
  } catch (e) {
    _logger.e('❌ Error loading poets by tag: $e');
    rethrow;
  }
});

// ============= SEARCH PROVIDER =============

/// Search poets
final searchPoetsProvider = FutureProvider.autoDispose<
    PaginatedResponse<PoetModel>>((ref) async {
  final service = ref.watch(poetServiceProvider);
  final query = ref.watch(poetsSearchQueryProvider);
  final lang = ref.watch(selectedLanguageProvider);

  if (query.isEmpty) {
    throw Exception('Search query is empty');
  }

  try {
    final result = await service.searchPoets(
      query: query,
      lang: lang,
    );
    _logger.i('✅ Search results loaded for: $query');
    return result;
  } catch (e) {
    _logger.e('❌ Error searching poets: $e');
    rethrow;
  }
});

// ============= POET DETAIL PROVIDERS =============

/// Get complete poet profile
final poetDetailProvider = FutureProvider.autoDispose.family<
    PoetProfileModel,
    String>((ref, publicId) async {
  final service = ref.watch(poetServiceProvider);
  final lang = ref.watch(selectedLanguageProvider);

  try {
    final result = await service.getPoetProfile(
      publicId: publicId,
      lang: lang,
    );
    _logger.i('✅ Poet profile loaded: $publicId');
    return result;
  } catch (e) {
    _logger.e('❌ Error loading poet profile: $e');
    rethrow;
  }
});

/// Get poet gallery images
final poetGalleryProvider = FutureProvider.autoDispose.family<
    List<PoetImageModel>,
    String>((ref, publicId) async {
  final service = ref.watch(poetServiceProvider);

  try {
    final result = await service.getPoetGallery(publicId: publicId);
    _logger.i('✅ Poet gallery loaded: $publicId (${result.length} images)');
    return result;
  } catch (e) {
    _logger.e('❌ Error loading poet gallery: $e');
    rethrow;
  }
});

/// Get poet books
final poetBooksProvider = FutureProvider.autoDispose.family<
    List<PoetBookModel>,
    String>((ref, publicId) async {
  final service = ref.watch(poetServiceProvider);
  final lang = ref.watch(selectedLanguageProvider);

  try {
    final result = await service.getPoetBooks(
      publicId: publicId,
      lang: lang,
    );
    _logger.i('✅ Poet books loaded: $publicId (${result.length} books)');
    return result;
  } catch (e) {
    _logger.e('❌ Error loading poet books: $e');
    rethrow;
  }
});

/// Get poet videos
final poetVideosProvider = FutureProvider.autoDispose.family<
    List<PoetVideoModel>,
    String>((ref, publicId) async {
  final service = ref.watch(poetServiceProvider);

  try {
    final result = await service.getPoetVideos(publicId: publicId);
    _logger.i('✅ Poet videos loaded: $publicId (${result.length} videos)');
    return result;
  } catch (e) {
    _logger.e('❌ Error loading poet videos: $e');
    rethrow;
  }
});

/// Provider for poet facts
final poetFactsProvider = FutureProvider.autoDispose.family<
    List<String>,
    String>((ref, publicId) async {
  final service = ref.watch(poetServiceProvider);

  try {
    final result = await service.getPoetFacts(publicId: publicId);
    _logger.i('✅ Poet facts loaded: $publicId (${result.length} facts)');
    return result;
  } catch (e) {
    _logger.e('❌ Error loading poet facts: $e');
    rethrow;
  }
});
