import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poet_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/services/poet_service.dart';

PoetModel fakePoet(int i) => PoetModel(
      publicId: 'poet-$i',
      name: 'Poet $i',
      shortBio: '-',
      birthYear: 1800 + i,
    );

/// Serves `/api/poets/search` from an in-memory list, [pageSize] per page,
/// and records every requested page. [pages] overrides the content of
/// specific page numbers (to simulate duplicates across pages).
class FakePoetSearchService extends PoetService {
  FakePoetSearchService(
    Ref ref, {
    required this.total,
    this.pageSize = 10,
    Map<int, List<PoetModel>>? pages,
  })  : _pages = pages ?? const {},
        super(Dio(), ref);

  final int total;
  final int pageSize;
  final Map<int, List<PoetModel>> _pages;
  final List<int> requestedPages = [];

  /// When set, responses for pages after the first wait for it, so a test
  /// can hold a "load more" in flight.
  Completer<void>? laterPagesGate;

  int get totalPages => (total / pageSize).ceil();

  @override
  Future<PaginatedResponse<PoetModel>> searchPoets({
    required String query,
    String lang = 'ur',
    int page = 0,
    int size = 10,
  }) async {
    requestedPages.add(page);
    if (page > 0) await laterPagesGate?.future;
    final start = page * pageSize;
    final content = _pages[page] ??
        [
          for (var i = start; i < total && i < start + pageSize; i++)
            fakePoet(i),
        ];
    return PaginatedResponse<PoetModel>(
      content: content,
      totalElements: total,
      totalPages: totalPages,
      last: page >= totalPages - 1,
      first: page == 0,
      size: pageSize,
      number: page,
    );
  }
}
