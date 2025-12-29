import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/features/image_poetry/editor/providers/poetry_canvas_provider.dart';
import 'package:flutter_poetry_app/features/image_poetry/editor/models/text_layer_model.dart';

class TextStylingToolbar extends ConsumerStatefulWidget {
  final String layerId;

  const TextStylingToolbar({
    super.key,
    required this.layerId,
  });

  @override
  ConsumerState<TextStylingToolbar> createState() => _TextStylingToolbarState();
}

class _TextStylingToolbarState extends ConsumerState<TextStylingToolbar> {
  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(poetryCanvasProvider);
    final layer = canvasState.textLayers.firstWhere(
      (l) => l.id == widget.layerId,
    );

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Text Style',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: AppSpacing.md),

            // Font Size
            _buildFontSizeSection(layer),
            SizedBox(height: AppSpacing.lg),

            // Text Color
            _buildColorSection(
              'Text Color',
              layer.textColor,
              (color) => _updateTextColor(layer, color),
            ),
            SizedBox(height: AppSpacing.lg),

            // Text Alignment
            _buildTextAlignmentSection(layer),
            SizedBox(height: AppSpacing.lg),

            // Background Highlight
            _buildBackgroundSection(layer),
            SizedBox(height: AppSpacing.lg),

            // Text Stroke (Outline)
            _buildStrokeSection(layer),
            SizedBox(height: AppSpacing.lg),

            // Shadow
            _buildShadowSection(layer),
            SizedBox(height: AppSpacing.lg),

            // Opacity
            _buildOpacitySection(layer),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeSection(TextLayerModel layer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Font Size', style: TextStyle(fontWeight: FontWeight.w600)),
            Text(
              '${layer.fontSize.toInt()}',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: layer.fontSize,
          min: 12,
          max: 80,
          divisions: 68,
          activeColor: AppColors.primary,
          onChanged: (value) {
            final updatedLayer = layer.copyWith(fontSize: value);
            ref.read(poetryCanvasProvider.notifier).updateTextLayer(layer.id, updatedLayer);
          },
        ),
      ],
    );
  }

  Widget _buildColorSection(
    String title,
    Color currentColor,
    Function(Color) onColorChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () => _showColorPickerDialog(currentColor, onColorChanged),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: currentColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Text(
                'Tap to change',
                style: TextStyle(
                  color: currentColor.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextAlignmentSection(TextLayerModel layer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Text Alignment', style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAlignmentButton(
              layer,
              TextAlign.left,
              Icons.format_align_left,
              'Left',
            ),
            _buildAlignmentButton(
              layer,
              TextAlign.center,
              Icons.format_align_center,
              'Center',
            ),
            _buildAlignmentButton(
              layer,
              TextAlign.right,
              Icons.format_align_right,
              'Right',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlignmentButton(
    TextLayerModel layer,
    TextAlign alignment,
    IconData icon,
    String label,
  ) {
    final isSelected = layer.textAlign == alignment;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: ElevatedButton(
          onPressed: () {
            final updatedLayer = layer.copyWith(textAlign: alignment);
            ref.read(poetryCanvasProvider.notifier).updateTextLayer(layer.id, updatedLayer);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? AppColors.primary : Colors.grey.shade200,
            foregroundColor: isSelected ? Colors.white : Colors.black87,
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundSection(TextLayerModel layer) {
    final hasBackground = layer.backgroundColor != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Background Highlight', style: TextStyle(fontWeight: FontWeight.w600)),
            Switch(
              value: hasBackground,
              activeColor: AppColors.primary,
              onChanged: (value) {
                final updatedLayer = layer.copyWith(
                  backgroundColor: value ? Colors.black.withOpacity(0.5) : null,
                );
                ref.read(poetryCanvasProvider.notifier).updateTextLayer(layer.id, updatedLayer);
              },
            ),
          ],
        ),
        if (hasBackground) ...[
          SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: () => _showColorPickerDialog(
              layer.backgroundColor!,
              (color) {
                final updatedLayer = layer.copyWith(backgroundColor: color);
                ref.read(poetryCanvasProvider.notifier).updateTextLayer(layer.id, updatedLayer);
              },
            ),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: layer.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStrokeSection(TextLayerModel layer) {
    final hasStroke = layer.strokeColor != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Text Outline', style: TextStyle(fontWeight: FontWeight.w600)),
            Switch(
              value: hasStroke,
              activeColor: AppColors.primary,
              onChanged: (value) {
                final updatedLayer = layer.copyWith(
                  strokeColor: value ? Colors.white : null,
                  strokeWidth: value ? 2.0 : null,
                );
                ref.read(poetryCanvasProvider.notifier).updateTextLayer(layer.id, updatedLayer);
              },
            ),
          ],
        ),
        if (hasStroke) ...[
          SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: () => _showColorPickerDialog(
              layer.strokeColor!,
              (color) {
                final updatedLayer = layer.copyWith(strokeColor: color);
                ref.read(poetryCanvasProvider.notifier).updateTextLayer(layer.id, updatedLayer);
              },
            ),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: layer.strokeColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Stroke Width'),
              Text(
                '${layer.strokeWidth?.toInt() ?? 2}',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: layer.strokeWidth ?? 2.0,
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: AppColors.primary,
            onChanged: (value) {
              final updatedLayer = layer.copyWith(strokeWidth: value);
              ref.read(poetryCanvasProvider.notifier).updateTextLayer(layer.id, updatedLayer);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildShadowSection(TextLayerModel layer) {
    final hasShadow = layer.shadowColor != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Text Shadow', style: TextStyle(fontWeight: FontWeight.w600)),
            Switch(
              value: hasShadow,
              activeColor: AppColors.primary,
              onChanged: (value) {
                final updatedLayer = layer.copyWith(
                  shadowColor: value ? Colors.black.withOpacity(0.5) : null,
                  shadowOffset: value ? const Offset(2, 2) : null,
                  shadowBlur: value ? 4.0 : null,
                );
                ref.read(poetryCanvasProvider.notifier).updateTextLayer(layer.id, updatedLayer);
              },
            ),
          ],
        ),
        if (hasShadow) ...[
          SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: () => _showColorPickerDialog(
              layer.shadowColor!,
              (color) {
                final updatedLayer = layer.copyWith(shadowColor: color);
                ref.read(poetryCanvasProvider.notifier).updateTextLayer(layer.id, updatedLayer);
              },
            ),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: layer.shadowColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shadow Blur'),
              Text(
                '${layer.shadowBlur?.toInt() ?? 4}',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: layer.shadowBlur ?? 4.0,
            min: 0,
            max: 20,
            divisions: 20,
            activeColor: AppColors.primary,
            onChanged: (value) {
              final updatedLayer = layer.copyWith(shadowBlur: value);
              ref.read(poetryCanvasProvider.notifier).updateTextLayer(layer.id, updatedLayer);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildOpacitySection(TextLayerModel layer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Opacity', style: TextStyle(fontWeight: FontWeight.w600)),
            Text(
              '${(layer.opacity * 100).toInt()}%',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: layer.opacity,
          min: 0.1,
          max: 1.0,
          divisions: 9,
          activeColor: AppColors.primary,
          onChanged: (value) {
            final updatedLayer = layer.copyWith(opacity: value);
            ref.read(poetryCanvasProvider.notifier).updateTextLayer(layer.id, updatedLayer);
          },
        ),
      ],
    );
  }

  void _updateTextColor(TextLayerModel layer, Color color) {
    final updatedLayer = layer.copyWith(textColor: color);
    ref.read(poetryCanvasProvider.notifier).updateTextLayer(layer.id, updatedLayer);
  }

  void _showColorPickerDialog(Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (context) {
        Color pickerColor = currentColor;

        return AlertDialog(
          title: const Text('Pick a Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                pickerColor = color;
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onColorChanged(pickerColor);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}
