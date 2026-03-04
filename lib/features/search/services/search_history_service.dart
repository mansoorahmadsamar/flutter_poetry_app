import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing search history in local storage
///
/// Features:
/// - Stores last 10 searches
/// - Most recent searches at the top
/// - Duplicate-aware (removes duplicates)
/// - Persistent across app sessions
class SearchHistoryService {
  static const String _historyKey = 'global_search_history';
  static const int _maxHistoryItems = 10;
  final Logger _logger = Logger();

  /// Load search history from SharedPreferences
  ///
  /// Returns: List of recent search queries (most recent first)
  Future<List<String>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_historyKey) ?? [];
      _logger.i('📚 Loaded ${history.length} search history items');
      return history;
    } catch (e) {
      _logger.e('❌ Error loading search history: $e');
      return [];
    }
  }

  /// Add a search query to history
  ///
  /// - Adds to the top of the list
  /// - Removes duplicates (moves to top if exists)
  /// - Maintains max 10 items
  /// - Ignores queries < 2 characters
  ///
  /// Parameters:
  /// - [query]: Search query to save
  Future<void> addSearch(String query) async {
    final trimmedQuery = query.trim();

    // Ignore short queries
    if (trimmedQuery.isEmpty || trimmedQuery.length < 2) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final history = List<String>.from(prefs.getStringList(_historyKey) ?? []);

      // Remove if exists (to move to top)
      history.remove(trimmedQuery);

      // Add to top
      history.insert(0, trimmedQuery);

      // Trim to max size
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      // Save
      await prefs.setStringList(_historyKey, history);
      _logger.i('💾 Saved search: "$trimmedQuery" (total: ${history.length})');
    } catch (e) {
      _logger.e('❌ Error saving search history: $e');
    }
  }

  /// Remove a specific search query from history
  ///
  /// Parameters:
  /// - [query]: Query to remove
  Future<void> removeSearch(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = List<String>.from(prefs.getStringList(_historyKey) ?? []);

      final removed = history.remove(query);
      if (removed) {
        await prefs.setStringList(_historyKey, history);
        _logger.i('🗑️ Removed search: "$query"');
      }
    } catch (e) {
      _logger.e('❌ Error removing search: $e');
    }
  }

  /// Clear all search history
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      _logger.i('🧹 Cleared all search history');
    } catch (e) {
      _logger.e('❌ Error clearing search history: $e');
    }
  }

  /// Check if history contains a query
  ///
  /// Parameters:
  /// - [query]: Query to check
  ///
  /// Returns: true if query exists in history
  Future<bool> contains(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_historyKey) ?? [];
      return history.contains(query.trim());
    } catch (e) {
      _logger.e('❌ Error checking search history: $e');
      return false;
    }
  }

  /// Get history size
  ///
  /// Returns: Number of items in history
  Future<int> getHistorySize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_historyKey) ?? [];
      return history.length;
    } catch (e) {
      _logger.e('❌ Error getting history size: $e');
      return 0;
    }
  }
}
