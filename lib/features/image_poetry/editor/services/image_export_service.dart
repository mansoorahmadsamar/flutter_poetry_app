import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
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

  /// Save image to device gallery
  Future<bool> saveToGallery(File imageFile) async {
    try {
      _logger.i('Requesting storage permission...');

      // Request storage permission
      final hasPermission = await _requestStoragePermission();

      if (!hasPermission) {
        _logger.w('Storage permission denied');
        return false;
      }

      _logger.i('Saving to gallery: ${imageFile.path}');

      // Save to gallery
      final result = await ImageGallerySaver.saveFile(
        imageFile.path,
        name: 'Poetry_${DateTime.now().millisecondsSinceEpoch}',
      );

      final success = result != null && (result['isSuccess'] == true || result['filePath'] != null);

      if (success) {
        _logger.i('✅ Image saved to gallery successfully');
      } else {
        _logger.e('❌ Failed to save image to gallery: $result');
      }

      return success;
    } catch (e) {
      _logger.e('❌ Error saving to gallery: $e');
      return false;
    }
  }

  /// Request storage permission based on platform
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), use photos permission
      // For Android < 13, use storage permission
      final androidInfo = await _getAndroidVersion();

      if (androidInfo >= 33) {
        // Android 13+: Request photos permission
        final status = await Permission.photos.request();
        return status.isGranted;
      } else {
        // Android < 13: Request storage permission
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      // iOS: Request photos permission
      final status = await Permission.photos.request();
      return status.isGranted;
    }

    // For other platforms, assume permission granted
    return true;
  }

  /// Get Android SDK version
  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      try {
        // This is a simplified version - you might need platform channels for exact version
        return 33; // Assume Android 13+ for now (safer approach)
      } catch (e) {
        _logger.w('Could not determine Android version: $e');
        return 33;
      }
    }
    return 0;
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
