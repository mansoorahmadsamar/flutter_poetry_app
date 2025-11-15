# Google Sign-In Configuration Issue & Solution

## Current Problem

The app successfully shows the Google account picker, but **fails to get the ID token** needed for backend authentication.

**Error in logs:**
```
✅ Google user signed in: keyobdev@gmail.com
❌ Failed to get ID token
```

## Root Cause

For native Google Sign-In to work with backend verification, the Flutter app needs to be configured with the **Web Client ID** (also called Server Client ID). This allows the Google Sign-In SDK to request an ID token that can be verified by your backend.

## Solution

### Step 1: Get Your Web Client ID from Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your project (or create one)
3. Navigate to: **APIs & Services** > **Credentials**
4. Find your **Web application** OAuth 2.0 Client ID
   - If you don't have one, click **+ CREATE CREDENTIALS** > **OAuth client ID** > **Web application**
5. Copy the **Client ID** (it should look like: `123456789-abc123def456.apps.googleusercontent.com`)

### Step 2: Get Your Android SHA-1 Fingerprint

For Android native sign-in to work, you also need an Android OAuth Client:

```bash
# Get debug keystore SHA-1
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

### Step 3: Create Android OAuth Client ID

1. In Google Cloud Console > **Credentials**
2. Click **+ CREATE CREDENTIALS** > **OAuth client ID**
3. Choose **Android**
4. Enter:
   - **Package name**: `com.techhikes.poetry_app`
   - **SHA-1 certificate fingerprint**: (paste from Step 2)
5. Click **Create**

### Step 4: Update Flutter App Configuration

Update `lib/core/config/app_config.dart`:

```dart
factory AppConfig.dev() {
  final baseUrl = PlatformUtils.getLocalhostUrl(8080);

  return AppConfig._(
    environment: AppEnvironment.dev,
    appName: 'Poetry DEV',
    baseApiUrl: baseUrl,
    apiTimeout: 30000,
    feedTTL: 300,
    poemTTL: 1800,
    enableLogging: true,
    enableAnalytics: false,
    googleOAuthRedirectUri: 'http://localhost:3000/auth/callback',
    googleWebClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com', // 👈 ADD THIS
  );
}
```

Replace `YOUR_WEB_CLIENT_ID.apps.googleusercontent.com` with your actual Web Client ID from Step 1.

### Step 5: Restart the App

```bash
# Hot restart won't work for this change, you need to rebuild
flutter run
```

## Why Do We Need Both Android and Web Client IDs?

- **Android Client ID**: Allows the Google Sign-In SDK to work on Android
- **Web Client ID**: Allows the SDK to generate ID tokens that your backend can verify

This is the standard Google Sign-In flow for mobile apps with backend verification.

## Verification

After adding the Web Client ID and restarting:

1. Tap "Sign in with Google"
2. Select your Google account
3. You should see these logs:
   ```
   ✅ Google user signed in: your-email@gmail.com
   🔑 Getting authentication details...
   ✅ Got ID token (length: XXX)
   📤 Sending ID token to backend...
   ✅ Authentication successful!
   ```

## Alternative: Use Environment Variables (Recommended for Production)

For production, don't hardcode the Web Client ID:

```dart
factory AppConfig.dev() {
  return AppConfig._(
    // ... other config
    googleWebClientId: const String.fromEnvironment(
      'GOOGLE_WEB_CLIENT_ID',
      defaultValue: '', // Empty for local development
    ),
  );
}
```

Then run with:
```bash
flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=your-client-id
```

## Troubleshooting

### "Sign in failed" error
- Verify the Android package name matches: `com.techhikes.poetry_app`
- Verify the SHA-1 fingerprint is correct
- Wait 5-10 minutes after creating OAuth clients (Google needs time to propagate)

### "Invalid client" error
- The Web Client ID is incorrect or doesn't belong to the same project
- Check that both Android and Web OAuth clients are in the same Google Cloud project

### Still not getting ID token
- Make sure you're using the **Web Client ID**, not the Android Client ID
- The Web Client ID should end with `.apps.googleusercontent.com`
- Try uninstalling and reinstalling the app

## Next Steps

Once you've added the Web Client ID and the sign-in works:

1. ✅ Google Sign-In will get the ID token
2. ✅ App will send it to your backend
3. ✅ Backend will verify and return JWT tokens
4. ✅ User will be logged in

**Need the exact Web Client ID?** Check your backend's `application.yaml` - it might already have the Web Client ID configured for web authentication.
