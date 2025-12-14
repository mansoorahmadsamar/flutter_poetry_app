import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/image_poetry/models/generated_image_model.dart';
import 'package:flutter_poetry_app/features/image_poetry/providers/image_collection_providers.dart';
import 'package:flutter_poetry_app/features/image_poetry/widgets/generated_image_card.dart';

class SavedImagesScreen extends ConsumerStatefulWidget {
  const SavedImagesScreen({super.key});

  @override
  ConsumerState<SavedImagesScreen> createState() => _SavedImagesScreenState();
}

class _SavedImagesScreenState extends ConsumerState<SavedImagesScreen> {
  final ScrollController _scrollController = ScrollController();

  String? _selectedCollection;
  bool _favoritesOnly = false;
  int _currentPage = 1;
  final int _pageSize = 20;
  List<GeneratedImageModel> _allImages = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMore && _hasMore) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final params = SavedImagesParams(
        collectionName: _selectedCollection,
        favoritesOnly: _favoritesOnly,
        page: _currentPage + 1,
        size: _pageSize,
      );

      final response = await ref.read(savedImagesProvider(params).future);

      setState(() {
        _allImages.addAll(response.content);
        _currentPage++;
        _hasMore = !response.last;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  void _resetAndRefresh() {
    setState(() {
      _currentPage = 1;
      _allImages = [];
      _hasMore = true;
    });
    ref.invalidate(savedImagesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final params = SavedImagesParams(
      collectionName: _selectedCollection,
      favoritesOnly: _favoritesOnly,
      page: _currentPage,
      size: _pageSize,
    );

    final imagesAsync = ref.watch(savedImagesProvider(params));
    final collectionsAsync = ref.watch(collectionNamesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Images'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetAndRefresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          _buildFilters(collectionsAsync),

          // Images grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _resetAndRefresh();
                await ref.read(savedImagesProvider(params).future);
              },
              child: imagesAsync.when(
                data: (paginatedResponse) {
                  if (_currentPage == 1) {
                    _allImages = paginatedResponse.content;
                    _hasMore = !paginatedResponse.last;
                  }

                  if (_allImages.isEmpty) {
                    return _buildEmptyState();
                  }

                  return GridView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(AppSpacing.md),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.6,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _allImages.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _allImages.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final image = _allImages[index];
                      return GeneratedImageCard(
                        image: image,
                        showFavoriteIndicator: _favoritesOnly,
                        onTap: () {
                          context.push(
                            '/image-poetry/image/${image.publicId}',
                          );
                        },
                        onLongPress: () {
                          _showImageOptions(image);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) => _buildErrorState(error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(AsyncValue<List<String>> collectionsAsync) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          // Collection dropdown
          collectionsAsync.when(
            data: (collections) {
              if (collections.isEmpty) {
                return const SizedBox.shrink();
              }

              return DropdownButtonFormField<String?>(
                value: _selectedCollection,
                hint: const Text('All Collections'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Collections'),
                  ),
                  ...collections.map(
                    (collection) => DropdownMenuItem(
                      value: collection,
                      child: Text(collection),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCollection = value;
                  });
                  _resetAndRefresh();
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          SizedBox(height: AppSpacing.sm),

          // Favorites toggle
          Row(
            children: [
              Checkbox(
                value: _favoritesOnly,
                onChanged: (value) {
                  setState(() {
                    _favoritesOnly = value ?? false;
                  });
                  _resetAndRefresh();
                },
              ),
              const Text('Favorites Only'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'No Saved Images',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              _selectedCollection != null
                  ? 'No images in this collection'
                  : _favoritesOnly
                      ? 'No favorite images yet'
                      : 'Start generating and saving poetry images',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Failed to Load Images',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: _resetAndRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageOptions(GeneratedImageModel image) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Toggle Favorite'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await ref
                      .read(collectionActionProvider.notifier)
                      .toggleFavorite(image.publicId);
                  _resetAndRefresh();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Favorite updated'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove from Collection',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmRemove(image);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(GeneratedImageModel image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Image'),
        content: const Text(
            'Are you sure you want to remove this image from your collection?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(collectionActionProvider.notifier)
                    .removeImage(image.publicId);
                _resetAndRefresh();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Image removed'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to remove: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
