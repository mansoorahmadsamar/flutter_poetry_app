import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'firebase_options.dart';
import 'core/config/app_config.dart';
import 'core/design_system/app_theme.dart';
import 'core/storage/preferences_service.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Suppress verbose GPU/MESA logs
  developer.Timeline.startSync('AppInit');
  developer.Timeline.finishSync();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log('Firebase initialized successfully');
  } catch (e) {
    developer.log('Firebase initialization error: $e', error: e);
    // Continue app initialization even if Firebase fails
  }

  // Initialize app configuration
  initializeAppConfig();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Override PreferencesService with initialized instance
        preferencesServiceProvider.overrideWithValue(PreferencesService(prefs)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: appConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
