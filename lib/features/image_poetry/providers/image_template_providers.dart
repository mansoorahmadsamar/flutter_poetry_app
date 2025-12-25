import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/image_poetry/models/image_template_model.dart';
import 'package:flutter_poetry_app/features/image_poetry/services/image_template_service.dart';

// Service provider
final imageTemplateServiceProvider = Provider<ImageTemplateService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ImageTemplateService(dioClient.dio);
});

// Parameters class for template filtering
class TemplateParams {
  final String? category;
  final bool? isPremium;
  final int page;
  final int size;

  TemplateParams({
    this.category,
    this.isPremium,
    this.page = 0,
    this.size = 20,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateParams &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          isPremium == other.isPremium &&
          page == other.page &&
          size == other.size;

  @override
  int get hashCode =>
      category.hashCode ^ isPremium.hashCode ^ page.hashCode ^ size.hashCode;
}

// Templates provider with pagination
final templatesProvider = FutureProvider.family<
    PaginatedResponse<ImageTemplateModel>,
    TemplateParams>(
  (ref, params) async {
    final service = ref.watch(imageTemplateServiceProvider);
    return service.getTemplates(
      category: params.category,
      isPremium: params.isPremium,
      page: params.page,
      size: params.size,
    );
  },
);

// Single template provider
final templateProvider = FutureProvider.family<ImageTemplateModel, String>(
  (ref, publicId) async {
    final service = ref.watch(imageTemplateServiceProvider);
    return service.getTemplate(publicId);
  },
);

// Popular templates provider
final popularTemplatesProvider = FutureProvider<List<ImageTemplateModel>>(
  (ref) async {
    final service = ref.watch(imageTemplateServiceProvider);
    return service.getPopularTemplates(limit: 10);
  },
);

// State providers for filters
final selectedCategoryProvider = StateProvider<String?>((ref) => null);
final premiumFilterProvider = StateProvider<bool?>((ref) => null);
