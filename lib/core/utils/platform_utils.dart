import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformUtils {
  /// Get the correct localhost URL based on platform
  static String getLocalhostUrl(int port) {
    if (kIsWeb) {
      return 'http://localhost:$port';
    } else if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to access host machine's localhost
      return 'http://10.0.2.2:$port';
    } else {
      // iOS simulator and real devices can use localhost
      return 'http://localhost:$port';
    }
  }

  /// Check if running on Android emulator
  static bool get isAndroidEmulator {
    if (!kIsWeb && Platform.isAndroid) {
      // This is a simple check, more sophisticated detection would be needed
      // for production use
      return true; // Assume emulator for dev
    }
    return false;
  }

  /// Check if running on iOS simulator
  static bool get isIOSSimulator {
    if (!kIsWeb && Platform.isIOS) {
      // targetPlatform check would be more accurate but this works for dev
      return true;
    }
    return false;
  }

  /// Get platform name
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
}
