import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/image_poetry/providers/image_template_providers.dart';
import 'package:flutter_poetry_app/features/image_poetry/providers/image_generation_providers.dart';
import 'package:flutter_poetry_app/features/image_poetry/widgets/custom_background_picker.dart';

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

class _ImageGenerationScreenState extends ConsumerState<ImageGenerationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedLanguage = 'ur';
  bool _includePoetImage = true;
  bool _includeWatermark = true;
  String? _customBackgroundPath;
  Color _customTextColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.templateId != null ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Image'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard),
              text: 'Templates',
            ),
            Tab(
              icon: Icon(Icons.brush),
              text: 'Custom Background',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Templates Tab
          _buildTemplatesTab(),

          // Custom Background Tab
          _buildCustomBackgroundTab(),
        ],
      ),
    );
  }

  Widget _buildTemplatesTab() {
    final templateAsync = widget.templateId != null
        ? ref.watch(templateProvider(widget.templateId!))
        : null;

    final generationState = ref.watch(imageGenerationActionProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Template preview
          if (templateAsync != null)
            templateAsync.when(
              data: (template) =>
                  _buildTemplatePreview(template.backgroundImageUrl),
              loading: () => _buildLoadingPreview(),
              error: (_, __) => _buildErrorPreview(),
            )
          else
            _buildNoTemplateSelected(),

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
                return _buildGenerateButton(isTemplate: true);
              } else {
                return _buildGeneratedImage(generatedImage);
              }
            },
            loading: () => _buildGeneratingState(),
            error: (error, _) => _buildErrorState(error),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBackgroundTab() {
    final generationState = ref.watch(imageGenerationActionProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Custom background picker
          CustomBackgroundPicker(
            onImagePicked: (filePath) {
              setState(() => _customBackgroundPath = filePath);
            },
          ),

          SizedBox(height: AppSpacing.xl),

          // Text color picker
          if (_customBackgroundPath != null) ...[
            _buildTextColorPicker(),
            SizedBox(height: AppSpacing.lg),
          ],

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
                return _buildGenerateButton(isTemplate: false);
              } else {
                return _buildGeneratedImage(generatedImage);
              }
            },
            loading: () => _buildGeneratingState(),
            error: (error, _) => _buildErrorState(error),
          ),
        ],
      ),
    );
  }

  Widget _buildTextColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Text Color',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: _showColorPicker,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _customTextColor,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Text(
                  'Tap to change color',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick Text Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _customTextColor,
            onColorChanged: (color) {
              setState(() => _customTextColor = color);
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoTemplateSelected() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'No Template Selected',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Please select a template first',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
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
            color: Colors.black.withValues(alpha: 0.1),
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

  Widget _buildGenerateButton({required bool isTemplate}) {
    final canGenerate = isTemplate
        ? widget.templateId != null
        : _customBackgroundPath != null;

    return ElevatedButton.icon(
      onPressed: canGenerate ? () => _generateImage(isTemplate) : null,
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
                color: Colors.black.withValues(alpha: 0.2),
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
            onPressed: () => _generateImage(_tabController.index == 0),
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

  Future<void> _generateImage(bool isTemplate) async {
    try {
      if (isTemplate) {
        if (widget.templateId == null) return;

        await ref
            .read(imageGenerationActionProvider.notifier)
            .generateWithTemplate(
              coupletId: widget.coupletId,
              templateId: widget.templateId!,
              languageCode: _selectedLanguage,
              includePoetImage: _includePoetImage,
              includeWatermark: _includeWatermark,
            );
      } else {
        if (_customBackgroundPath == null) return;

        // First upload the custom background
        final uploadedUrl = await ref
            .read(imageGenerationActionProvider.notifier)
            .uploadBackground(_customBackgroundPath!);

        // Then generate with custom background
        final colorHex = '#${(_customTextColor.r * 255).toInt().toRadixString(16).padLeft(2, '0')}'
            '${(_customTextColor.g * 255).toInt().toRadixString(16).padLeft(2, '0')}'
            '${(_customTextColor.b * 255).toInt().toRadixString(16).padLeft(2, '0')}';

        await ref
            .read(imageGenerationActionProvider.notifier)
            .generateWithCustomBackground(
              coupletId: widget.coupletId,
              customBackgroundUrl: uploadedUrl,
              languageCode: _selectedLanguage,
              customTextColor: colorHex,
            );
      }

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
