import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/features/image_poetry/editor/providers/poetry_canvas_provider.dart';

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
    final canvasState = ref.watch(poetryCanvasProvider);

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
          // Canvas Area (placeholder for now)
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: Center(
                child: RepaintBoundary(
                  key: _canvasKey,
                  child: Container(
                    width: 360,
                    height: 640,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: canvasState.textLayers.isEmpty
                        ? _buildEmptyState()
                        : _buildCanvasPreview(canvasState),
                  ),
                ),
              ),
            ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.palette_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Tap "Add Text" to start creating',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasPreview(canvasState) {
    return Stack(
      children: [
        // Background image (if any)
        if (canvasState.backgroundImagePath != null)
          Positioned.fill(
            child: Image.network(
              canvasState.backgroundImagePath!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image),
                );
              },
            ),
          ),

        // Text layers preview (simple version)
        ...canvasState.textLayers.map((layer) {
          return Positioned(
            left: layer.position.dx,
            top: layer.position.dy,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: layer.backgroundColor ?? Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: layer.isSelected
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: Text(
                layer.text,
                style: TextStyle(
                  fontFamily: layer.languageCode == 'ur'
                      ? 'Jameel Noori Nastaleeq'
                      : null,
                  fontSize: layer.fontSize,
                  color: layer.textColor,
                  height: layer.lineHeight,
                ),
                textDirection: layer.languageCode == 'ur'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                textAlign: layer.textAlign,
              ),
            ),
          );
        }),
      ],
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
                  // TODO: Show color picker
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Choose Template'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to template selection
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Upload Custom Image'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Image picker
                },
              ),
            ],
          ),
        );
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
    // TODO: Implement export with ImageExportService
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon!'),
      ),
    );
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
