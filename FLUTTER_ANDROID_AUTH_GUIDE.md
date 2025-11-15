# Flutter Android Google Sign-In Integration Guide

## Overview
This guide shows how to integrate native Google Sign-In for Android with your Poetry backend.

## Backend Setup ✅ (Already Done)
- ✅ New endpoint: `POST /api/auth/google/android`
- ✅ Google ID token verification service
- ✅ Android client ID configured
- ✅ Security config updated

---

## Flutter Setup

### 1. Add Dependencies to `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_sign_in: ^6.2.1
  http: ^1.2.0
  flutter_secure_storage: ^9.0.0
  provider: ^6.1.1 # For state management (optional)
```

Run: `flutter pub get`

---

### 2. Configure Android

#### Update `android/app/build.gradle`

```gradle
android {
    defaultConfig {
        // ... other config
        minSdkVersion 21  // Google Sign-In requires API 21+
    }
}
```

#### No need to add anything to `AndroidManifest.xml` for Google Sign-In!

---

### 3. Create Auth Service

Create `lib/services/auth_service.dart`:

```dart
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Backend URL - works on Android emulator without special IP!
  static const String baseUrl = 'http://10.0.2.2:8080'; // Emulator
  // static const String baseUrl = 'http://192.168.1.100:8080'; // Real device
  // static const String baseUrl = 'https://api.yourdomain.com'; // Production

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'openid',
    ],
    // No need to specify serverClientId - Android client handles everything
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Sign in with Google
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In...');

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('User cancelled the sign-in');
        return null;
      }

      print('Google user: ${googleUser.email}');

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get ID token');
      }

      print('Got ID token, sending to backend...');

      // Send ID token to backend
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/google/android'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'deviceType': 'android',
        }),
      );

      print('Backend response status: ${response.statusCode}');
      print('Backend response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] == true) {
          final tokens = data['data'];

          // Store tokens securely
          await _storage.write(
            key: 'access_token',
            value: tokens['accessToken'],
          );
          await _storage.write(
            key: 'refresh_token',
            value: tokens['refreshToken'],
          );

          print('Authentication successful!');
          return tokens;
        } else {
          throw Exception(data['message'] ?? 'Authentication failed');
        }
      } else {
        throw Exception('Backend returned ${response.statusCode}');
      }
    } catch (error) {
      print('Error during Google Sign-In: $error');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Get refresh token
      final refreshToken = await _storage.read(key: 'refresh_token');

      // Call backend logout
      if (refreshToken != null) {
        await http.post(
          Uri.parse('$baseUrl/api/auth/logout'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refreshToken}),
        );
      }

      // Sign out from Google
      await _googleSignIn.signOut();

      // Clear stored tokens
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');

      print('Signed out successfully');
    } catch (error) {
      print('Error during sign out: $error');
    }
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  /// Make authenticated API request
  Future<http.Response> authenticatedRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final token = await getAccessToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    switch (method.toUpperCase()) {
      case 'POST':
        return http.post(uri, headers: headers, body: jsonEncode(body));
      case 'PUT':
        return http.put(uri, headers: headers, body: jsonEncode(body));
      case 'DELETE':
        return http.delete(uri, headers: headers);
      default:
        return http.get(uri, headers: headers);
    }
  }
}
```

---

### 4. Create Login Screen

Create `lib/screens/login_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signInWithGoogle();

      if (result != null) {
        // Navigate to home screen
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your app logo
            const Icon(
              Icons.book,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Poetry World',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 60),

            // Google Sign-In Button
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _handleGoogleSignIn,
                    icon: Image.asset(
                      'assets/google_logo.png', // Add Google logo to assets
                      height: 24,
                      width: 24,
                    ),
                    label: const Text('Sign in with Google'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
```

---

### 5. Update main.dart

```dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart'; // Your home screen
import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poetry World',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Check if user is already logged in
    final isLoggedIn = await _authService.isLoggedIn();

    if (mounted) {
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
```

---

## Testing Steps

### 1. Start Backend
```bash
cd poetry-backend
./mvnw spring-boot:run
```

### 2. Run Flutter App on Emulator
```bash
cd your-flutter-app
flutter run
```

### 3. Test Sign-In Flow
1. App opens on Login Screen
2. Click "Sign in with Google"
3. Select Google account
4. **App sends ID token to backend** (works on emulator!)
5. Backend verifies token and returns JWT tokens
6. Tokens stored securely
7. Navigate to home screen

---

## Advantages of This Approach

✅ **Works on Android Emulator** - No IP address issues!
✅ **No redirects needed** - Native Google Sign-In handles everything
✅ **Better UX** - Integrated with Android's Google account
✅ **More secure** - Tokens never exposed in URLs
✅ **Production ready** - Same code works everywhere

---

## API Response Format

### Success Response
```json
{
  "success": true,
  "message": "Authentication successful",
  "data": {
    "accessToken": "eyJhbGciOiJIUzUxMiJ9...",
    "refreshToken": "eyJhbGciOiJIUzUxMiJ9...",
    "type": "Bearer",
    "publicId": "user_abc123",
    "username": "johndoe",
    "email": "john@example.com",
    "fullName": "John Doe",
    "profileImageUrl": "https://..."
  }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Invalid Google ID token",
  "data": null
}
```

---

## Troubleshooting

### Issue: "PlatformException(sign_in_failed)"
**Solution:** Make sure you're using the correct SHA-1 fingerprint in Google Cloud Console

### Issue: "idToken is null"
**Solution:** Make sure scopes include 'openid' and 'email'

### Issue: "401 Invalid Google ID token"
**Solution:** Verify the Android client ID matches in Google Cloud Console and application.yaml

### Issue: Backend can't be reached
**Solution:**
- Emulator: Use `http://10.0.2.2:8080`
- Real device: Use your computer's local IP (e.g., `http://192.168.1.100:8080`)
- Check firewall settings

---

## Next Steps

1. ✅ Backend configured (done!)
2. Add dependencies to Flutter app
3. Copy the `AuthService` code
4. Create login screen
5. Test on emulator
6. Test on real device
7. Deploy to production

**Need help with any step? Let me know!**
