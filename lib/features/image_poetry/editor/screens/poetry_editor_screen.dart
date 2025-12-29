import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/features/image_poetry/editor/providers/poetry_canvas_provider.dart';
import 'package:flutter_poetry_app/features/image_poetry/editor/widgets/interactive_poetry_canvas.dart';
import 'package:flutter_poetry_app/features/image_poetry/editor/widgets/text_styling_toolbar.dart';
import 'package:flutter_poetry_app/features/image_poetry/editor/services/image_export_service.dart';

class PoetryEditorScreen extends ConsumerStatefulWidget {
  final String? coupletId;
  final List<String>? initialVerses;

  const PoetryEditorScreen({
    super.key,
    this.coupletId,
    this.initialVerses,
  });

  @override
  ConsumerState<PoetryEditorScreen> createState() =>
      _PoetryEditorScreenState();
}

class _PoetryEditorScreenState extends ConsumerState<PoetryEditorScreen> {
  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Load initial verses if provided (from couplet flow)
    if (widget.initialVerses != null && widget.initialVerses!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadInitialVerses();
      });
    }
  }

  void _loadInitialVerses() {
    final controller = ref.read(poetryCanvasProvider.notifier);

    for (final verse in widget.initialVerses!) {
      controller.addTextLayer(verse, 'ur');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poetry Image Editor'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Export button
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _handleExport,
            tooltip: 'Export Image',
          ),
        ],
      ),
      body: Column(
        children: [
          // Interactive Canvas Area
          Expanded(
            child: InteractivePoetryCanvas(canvasKey: _canvasKey),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.text_fields,
                  label: 'Add Text',
                  onPressed: _showAddTextDialog,
                ),
                _ActionButton(
                  icon: Icons.image_outlined,
                  label: 'Background',
                  onPressed: _showBackgroundOptions,
                ),
                _ActionButton(
                  icon: Icons.palette,
                  label: 'Style',
                  onPressed: _showStylingToolbar,
                ),
                _ActionButton(
                  icon: Icons.layers_outlined,
                  label: 'Layers',
                  onPressed: _showLayersPanel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTextDialog() {
    final textController = TextEditingController();
    String selectedLanguage = 'ur';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Text Layer'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Language selection
                  Row(
                    children: [
                      const Text('Language:'),
                      SizedBox(width: AppSpacing.sm),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'ur', label: Text('Urdu')),
                          ButtonSegment(value: 'en', label: Text('English')),
                        ],
                        selected: {selectedLanguage},
                        onSelectionChanged: (Set<String> selection) {
                          setState(() {
                            selectedLanguage = selection.first;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Text input
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      labelText: 'Enter text',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    textDirection: selectedLanguage == 'ur'
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (textController.text.isNotEmpty) {
                      ref.read(poetryCanvasProvider.notifier).addTextLayer(
                            textController.text,
                            selectedLanguage,
                          );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBackgroundOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text('Solid Color'),
                onTap: () {
                  Navigator.pop(context);
                  _showColorPicker();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Choose Template'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToTemplateSelection();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Upload Custom Image'),
                onTap: () {
                  Navigator.pop(context);
                  _pickCustomImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showColorPicker() {
    // TODO: Implement solid color background
    // For now, just show a simple color picker or predefined colors
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Solid color background coming soon!'),
      ),
    );
  }

  Future<void> _navigateToTemplateSelection() async {
    // Navigate to template selection screen
    final result = await context.push('/template-selection');

    if (result != null && result is Map<String, dynamic>) {
      final templateUrl = result['templateUrl'] as String?;
      if (templateUrl != null) {
        ref.read(poetryCanvasProvider.notifier).setBackgroundFromUrl(templateUrl);
      }
    }
  }

  Future<void> _pickCustomImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        final file = File(image.path);
        ref.read(poetryCanvasProvider.notifier).setBackgroundFromFile(file);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Background image loaded!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showStylingToolbar() {
    final canvasState = ref.read(poetryCanvasProvider);

    if (canvasState.selectedLayerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a text layer first'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return TextStylingToolbar(layerId: canvasState.selectedLayerId!);
      },
    );
  }

  void _showLayersPanel() {
    final canvasState = ref.read(poetryCanvasProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Text Layers',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: AppSpacing.md),

              if (canvasState.textLayers.isEmpty)
                const Center(child: Text('No layers yet'))
              else
                ...canvasState.textLayers.map((layer) {
                  return ListTile(
                    leading: Icon(
                      Icons.text_fields,
                      color: layer.isSelected ? AppColors.primary : null,
                    ),
                    title: Text(
                      layer.text.length > 30
                          ? '${layer.text.substring(0, 30)}...'
                          : layer.text,
                    ),
                    subtitle: Text(layer.languageCode == 'ur' ? 'Urdu' : 'English'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        ref.read(poetryCanvasProvider.notifier).deleteTextLayer(layer.id);
                        Navigator.pop(context);
                      },
                    ),
                    onTap: () {
                      ref.read(poetryCanvasProvider.notifier).selectLayer(layer.id);
                      Navigator.pop(context);
                    },
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleExport() async {
    try {
      // Show loading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Exporting image...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      // Export to file
      final exportService = ImageExportService();
      final file = await exportService.exportToFile(
        canvasKey: _canvasKey,
        targetSize: const Size(1080, 1920),
        format: ImageFormat.png,
      );

      // Save to gallery
      final saved = await exportService.saveToGallery(file);

      if (!mounted) return;

      // Hide loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (saved) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 16),
                Expanded(
                  child: Text('Image saved to gallery successfully!'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Permission denied or save failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.warning, color: Colors.white),
                SizedBox(width: 16),
                Expanded(
                  child: Text('Could not save to gallery. Please check permissions.'),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () {
                // Open app settings
                // Note: This requires adding openAppSettings() from permission_handler
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Hide loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Text('Export failed: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
