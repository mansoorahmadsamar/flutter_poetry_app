import 'dart:convert';
import 'dart:io';

/// Loads a JSON fixture from `test/fixtures/`. `flutter test` runs with the
/// package root as the working directory.
Map<String, dynamic> loadJsonFixture(String relativePath) {
  final file = File('test/fixtures/$relativePath');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}
