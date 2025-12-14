import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';

class CustomBackgroundPicker extends StatefulWidget {
  final Function(String filePath) onImagePicked;

  const CustomBackgroundPicker({
    super.key,
    required this.onImagePicked,
  });

  @override
  State<CustomBackgroundPicker> createState() => _CustomBackgroundPickerState();
}

class _CustomBackgroundPickerState extends State<CustomBackgroundPicker> {
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isLoading = true);

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
          _isLoading = false;
        });
        widget.onImagePicked(image.path);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearSelection() {
    setState(() => _selectedImagePath = null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image preview or placeholder
        if (_selectedImagePath != null)
          _buildImagePreview()
        else
          _buildPlaceholder(),

        SizedBox(height: AppSpacing.lg),

        // Action buttons
        if (_selectedImagePath == null) ...[
          // Upload from gallery
          OutlinedButton.icon(
            onPressed: _isLoading ? null : () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Upload from Gallery'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              side: BorderSide(color: AppColors.primary),
            ),
          ),

          SizedBox(height: AppSpacing.md),

          // Take photo
          OutlinedButton.icon(
            onPressed: _isLoading ? null : () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              side: BorderSide(color: AppColors.primary),
            ),
          ),
        ] else ...[
          // Change image button
          OutlinedButton.icon(
            onPressed: _clearSelection,
            icon: const Icon(Icons.refresh),
            label: const Text('Change Background'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
          ),
        ],

        // Loading indicator
        if (_isLoading) ...[
          SizedBox(height: AppSpacing.md),
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ],
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Image.file(
              File(_selectedImagePath!),
              fit: BoxFit.cover,
            ),
          ),

          // Success overlay
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Selected',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'No background selected',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Choose from gallery or take a photo',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
