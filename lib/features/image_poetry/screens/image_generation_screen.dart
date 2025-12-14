import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/image_poetry/providers/image_template_providers.dart';
import 'package:flutter_poetry_app/features/image_poetry/providers/image_generation_providers.dart';

class ImageGenerationScreen extends ConsumerStatefulWidget {
  final String coupletId;
  final String? templateId;

  const ImageGenerationScreen({
    super.key,
    required this.coupletId,
    this.templateId,
  });

  @override
  ConsumerState<ImageGenerationScreen> createState() =>
      _ImageGenerationScreenState();
}

class _ImageGenerationScreenState extends ConsumerState<ImageGenerationScreen> {
  String _selectedLanguage = 'ur';
  bool _includePoetImage = true;
  bool _includeWatermark = true;

  @override
  Widget build(BuildContext context) {
    final templateAsync = widget.templateId != null
        ? ref.watch(templateProvider(widget.templateId!))
        : null;

    final generationState = ref.watch(imageGenerationActionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Image'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Template preview
            if (templateAsync != null)
              templateAsync.when(
                data: (template) => _buildTemplatePreview(template.backgroundImageUrl),
                loading: () => _buildLoadingPreview(),
                error: (_, __) => _buildErrorPreview(),
              )
            else
              _buildLoadingPreview(),

            SizedBox(height: AppSpacing.xl),

            // Language selection
            _buildLanguageSelector(),

            SizedBox(height: AppSpacing.lg),

            // Options
            _buildOptions(),

            SizedBox(height: AppSpacing.xl),

            // Generated image or generate button
            generationState.when(
              data: (generatedImage) {
                if (generatedImage == null) {
                  return _buildGenerateButton();
                } else {
                  return _buildGeneratedImage(generatedImage);
                }
              },
              loading: () => _buildGeneratingState(),
              error: (error, _) => _buildErrorState(error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatePreview(String imageUrl) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 64),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingPreview() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorPreview() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: const Center(
        child: Icon(Icons.error_outline, size: 64, color: Colors.grey),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          value: _selectedLanguage,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'ur', child: Text('Urdu')),
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'hi', child: Text('Hindi')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedLanguage = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Options',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: AppSpacing.sm),
        CheckboxListTile(
          title: const Text('Include Poet Image'),
          value: _includePoetImage,
          onChanged: (value) {
            setState(() => _includePoetImage = value ?? true);
          },
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('Include Watermark'),
          value: _includeWatermark,
          onChanged: (value) {
            setState(() => _includeWatermark = value ?? true);
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return ElevatedButton.icon(
      onPressed: _generateImage,
      icon: const Icon(Icons.auto_awesome),
      label: const Text('Generate Image'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildGeneratingState() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: AppSpacing.md),
          const Text(
            'Generating your image...',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'This may take a few seconds',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedImage(generatedImage) {
    return Column(
      children: [
        // Generated image preview
        Container(
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: CachedNetworkImage(
              imageUrl: generatedImage.imageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),

        SizedBox(height: AppSpacing.xl),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareImage(generatedImage.imageUrl),
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _downloadImage(generatedImage.imageUrl),
                icon: const Icon(Icons.download),
                label: const Text('Download'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: AppSpacing.md),

        // Generate another button
        TextButton.icon(
          onPressed: () {
            ref.read(imageGenerationActionProvider.notifier).reset();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Generate Another'),
        ),
      ],
    );
  }

  Widget _buildErrorState(Object error) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          SizedBox(height: AppSpacing.md),
          const Text(
            'Failed to generate image',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: _generateImage,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateImage() async {
    if (widget.templateId == null) return;

    try {
      await ref.read(imageGenerationActionProvider.notifier).generateWithTemplate(
            coupletId: widget.coupletId,
            templateId: widget.templateId!,
            languageCode: _selectedLanguage,
            includePoetImage: _includePoetImage,
            includeWatermark: _includeWatermark,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Error is already handled by the state
    }
  }

  Future<void> _shareImage(String imageUrl) async {
    try {
      await Share.share(
        'Check out this beautiful poetry image!\n\n$imageUrl',
        subject: 'Poetry Image',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    }
  }

  Future<void> _downloadImage(String imageUrl) async {
    // TODO: Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download functionality coming soon')),
    );
  }
}
