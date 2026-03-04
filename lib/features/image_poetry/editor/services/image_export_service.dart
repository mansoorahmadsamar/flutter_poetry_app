import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:logger/logger.dart';

enum ImageFormat { png, jpeg }

class ImageExportService {
  final Logger _logger = Logger();

  /// Export canvas to file
  Future<File> exportToFile({
    required GlobalKey canvasKey,
    required ui.Size targetSize,
    ImageFormat format = ImageFormat.png,
    int quality = 100,
  }) async {
    try {
      _logger.i('Starting image export...');

      // 1. Capture RepaintBoundary as image
      final boundary = canvasKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Canvas not found. Make sure the canvas is rendered.');
      }

      // Export at 3x resolution for crisp images
      final image = await boundary.toImage(pixelRatio: 3.0);
      _logger.d('Captured image: ${image.width}x${image.height}');

      // 2. Convert to bytes
      final byteData = await image.toByteData(
        format: format == ImageFormat.png
            ? ui.ImageByteFormat.png
            : ui.ImageByteFormat.rawRgba,
      );

      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      // 3. Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'poetry_$timestamp.${format.name}';
      final file = File('${tempDir.path}/$fileName');

      await file.writeAsBytes(byteData.buffer.asUint8List());
      _logger.i('✅ Image exported to: ${file.path}');

      return file;
    } catch (e) {
      _logger.e('❌ Error exporting image: $e');
      rethrow;
    }
  }

  /// Save image to device gallery using Gal package
  /// Gal handles permissions automatically
  Future<bool> saveToGallery(File imageFile) async {
    try {
      _logger.i('Saving to gallery: ${imageFile.path}');

      // Save to gallery using Gal (handles permissions automatically)
      await Gal.putImage(imageFile.path);

      _logger.i('✅ Image saved to gallery successfully');
      return true;
    } on GalException catch (e) {
      _logger.e('❌ Gal error saving to gallery: ${e.type}');

      // Handle specific error types
      if (e.type == GalExceptionType.accessDenied) {
        _logger.w('Gallery access denied by user');
      } else if (e.type == GalExceptionType.notEnoughSpace) {
        _logger.w('Not enough storage space');
      }

      return false;
    } catch (e) {
      _logger.e('❌ Unexpected error saving to gallery: $e');
      return false;
    }
  }

  /// Export and save in one step
  Future<File?> exportAndSave({
    required GlobalKey canvasKey,
    required ui.Size targetSize,
    ImageFormat format = ImageFormat.png,
    int quality = 100,
  }) async {
    try {
      // Export to file
      final file = await exportToFile(
        canvasKey: canvasKey,
        targetSize: targetSize,
        format: format,
        quality: quality,
      );

      // Save to gallery
      final saved = await saveToGallery(file);

      if (saved) {
        _logger.i('✅ Image exported and saved successfully');
        return file;
      } else {
        _logger.w('Image exported but not saved to gallery');
        return file;
      }
    } catch (e) {
      _logger.e('❌ Error in exportAndSave: $e');
      return null;
    }
  }
}
