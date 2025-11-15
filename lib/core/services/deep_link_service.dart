import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

/// Deep link service for handling OAuth callbacks
class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  final Logger _logger = Logger();
  StreamSubscription<Uri>? _linkSubscription;

  /// Initialize deep link listener
  Future<void> init(Function(Uri) onLink) async {
    try {
      // Handle initial link if app was opened via deep link
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _logger.i('Initial deep link: $initialUri');
        onLink(initialUri);
      }

      // Listen for deep links while app is running
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (uri) {
          _logger.i('Deep link received: $uri');
          onLink(uri);
        },
        onError: (error) {
          _logger.e('Deep link error: $error');
        },
      );
    } catch (e) {
      _logger.e('Failed to initialize deep links: $e');
    }
  }

  /// Dispose the service
  void dispose() {
    _linkSubscription?.cancel();
  }
}

/// Provider for deep link service
final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  final service = DeepLinkService();
  ref.onDispose(() => service.dispose());
  return service;
});
