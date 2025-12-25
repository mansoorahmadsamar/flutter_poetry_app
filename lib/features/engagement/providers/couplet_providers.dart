import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/couplet_model.dart';
import 'package:flutter_poetry_app/features/engagement/services/couplet_service.dart';

// Service provider
final coupletServiceProvider = Provider<CoupletService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CoupletService(dioClient.dio);
});

// Couplets for a poem provider
final coupletsProvider = FutureProvider.family<List<CoupletModel>, String>(
  (ref, poemPublicId) async {
    final service = ref.watch(coupletServiceProvider);
    final lang = ref.watch(selectedLanguageProvider);
    return service.getCoupletsByPoem(poemPublicId, lang: lang);
  },
);

// Single couplet provider
final coupletProvider = FutureProvider.family<CoupletDetailResponse, String>(
  (ref, coupletPublicId) async {
    final service = ref.watch(coupletServiceProvider);
    return service.getCouplet(coupletPublicId);
  },
);

// Bookmarked couplets parameters
class BookmarkedCoupletsParams {
  final int page;
  final int size;
  final String? search;
  final String? poetryType;
  final String sortBy;
  final String sortDir;

  BookmarkedCoupletsParams({
    this.page = 0,
    this.size = 20,
    this.search,
    this.poetryType,
    this.sortBy = 'createdAt',
    this.sortDir = 'desc',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkedCoupletsParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          size == other.size &&
          search == other.search &&
          poetryType == other.poetryType &&
          sortBy == other.sortBy &&
          sortDir == other.sortDir;

  @override
  int get hashCode =>
      page.hashCode ^
      size.hashCode ^
      search.hashCode ^
      poetryType.hashCode ^
      sortBy.hashCode ^
      sortDir.hashCode;
}

// Bookmarked couplets provider (for collections)
final bookmarkedCoupletsProvider = FutureProvider.family<
    PaginatedResponse<BookmarkedCoupletResponse>,
    BookmarkedCoupletsParams>(
  (ref, params) async {
    final service = ref.watch(coupletServiceProvider);
    return service.getMyBookmarkedCouplets(
      page: params.page,
      size: params.size,
      search: params.search,
      poetryType: params.poetryType,
      sortBy: params.sortBy,
      sortDir: params.sortDir,
    );
  },
);

// Couplet action provider for like/bookmark actions
final coupletActionProvider =
    StateNotifierProvider<CoupletActionNotifier, AsyncValue<void>>(
  (ref) => CoupletActionNotifier(ref),
);

class CoupletActionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  CoupletActionNotifier(this.ref) : super(const AsyncValue.data(null));

  /// Toggle like on a couplet
  Future<CoupletDetailResponse> toggleLike(String coupletPublicId) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(coupletServiceProvider);
      final enrichedCouplet = await service.toggleLike(coupletPublicId);

      state = const AsyncValue.data(null);

      // Invalidate providers to refresh with server data
      ref.invalidate(coupletsProvider);
      ref.invalidate(coupletProvider(coupletPublicId));

      return enrichedCouplet;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Toggle bookmark on a couplet
  Future<CoupletDetailResponse> toggleBookmark(String coupletPublicId) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(coupletServiceProvider);
      final enrichedCouplet = await service.toggleBookmark(coupletPublicId);

      state = const AsyncValue.data(null);

      // Invalidate providers to refresh with server data
      ref.invalidate(coupletsProvider);
      ref.invalidate(coupletProvider(coupletPublicId));
      ref.invalidate(bookmarkedCoupletsProvider);

      return enrichedCouplet;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
