import 'package:flutter_poetry_app/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// One call that every test touching app code makes first: binding, no
/// runtime font fetching, and the (debug) [appConfig] global.
void setUpTestConfig() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  initializeAppConfig();
}
