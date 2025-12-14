import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/image_poetry/providers/image_collection_providers.dart';

class CollectionDialog extends ConsumerStatefulWidget {
  final String imageId;

  const CollectionDialog({
    super.key,
    required this.imageId,
  });

  @override
  ConsumerState<CollectionDialog> createState() => _CollectionDialogState();
}

class _CollectionDialogState extends ConsumerState<CollectionDialog> {
  String? _selectedCollection;
  bool _isFavorite = false;
  bool _isCreatingNew = false;
  bool _isSaving = false;
  final _newCollectionController = TextEditingController();

  @override
  void dispose() {
    _newCollectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collectionsAsync = ref.watch(collectionNamesProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Row(
              children: [
                const Icon(Icons.collections_bookmark, color: AppColors.primary),
                SizedBox(width: AppSpacing.sm),
                const Text(
                  'Save to Collection',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.lg),

            // Collection selector
            collectionsAsync.when(
              data: (collections) => _buildCollectionSelector(collections),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => Text(
                'Failed to load collections: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),

            SizedBox(height: AppSpacing.lg),

            // Favorite checkbox
            CheckboxListTile(
              value: _isFavorite,
              onChanged: (value) {
                setState(() => _isFavorite = value ?? false);
              },
              title: const Text('Mark as favorite'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),

            SizedBox(height: AppSpacing.lg),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionSelector(List<String> collections) {
    if (_isCreatingNew) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'New Collection Name',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _newCollectionController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter collection name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isCreatingNew = false;
                    _newCollectionController.clear();
                  });
                },
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Collection',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          value: _selectedCollection,
          hint: const Text('Select a collection'),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          items: [
            ...collections.map(
              (collection) => DropdownMenuItem(
                value: collection,
                child: Text(collection),
              ),
            ),
            const DropdownMenuItem(
              value: '__create_new__',
              child: Row(
                children: [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text('Create New Collection'),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            if (value == '__create_new__') {
              setState(() {
                _isCreatingNew = true;
                _selectedCollection = null;
              });
            } else {
              setState(() => _selectedCollection = value);
            }
          },
        ),
      ],
    );
  }

  Future<void> _saveImage() async {
    final collectionName = _isCreatingNew
        ? _newCollectionController.text.trim()
        : _selectedCollection ?? 'My Images';

    if (collectionName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a collection name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(collectionActionProvider.notifier).saveImage(
            imageId: widget.imageId,
            collectionName: collectionName,
            isFavorite: _isFavorite,
          );

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to "$collectionName"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
