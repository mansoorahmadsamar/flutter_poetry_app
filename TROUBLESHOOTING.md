# Troubleshooting Guide

## "Could not launch Google Sign In" Error

This error occurs when the app cannot open the OAuth URL in a browser. Here are the most common causes and solutions:

### 1. Backend Not Running

**Problem**: Your Poetry backend server is not running on port 8080.

**Solution**:
```bash
# Start your Spring Boot backend
cd /path/to/poetry-backend
./mvnw spring-boot:run
# or
./gradlew bootRun
```

**Verify backend is running**:
```bash
curl http://localhost:8080/oauth2/authorization/google
```

You should see a redirect to Google's OAuth page.

### 2. Wrong API URL for Platform

**Problem**: The app is using the wrong localhost URL for your platform.

**Current Configuration**:
- **Android Emulator**: Uses `http://10.0.2.2:8080` (10.0.2.2 is Android emulator's alias for host machine)
- **iOS Simulator**: Uses `http://localhost:8080`
- **Real Device**: Cannot access localhost (need to use your computer's IP or deploy backend)

**Check what URL the app is using**:
Look at the "Debug Info" panel on the login screen. It shows:
- Platform (Android/iOS)
- API URL being used

**For Real Device Testing**:
If you're testing on a real device (not emulator/simulator), you need to:

1. Find your computer's local IP address:
   ```bash
   # macOS/Linux
   ifconfig | grep "inet "

   # Windows
   ipconfig
   ```

2. Update the config to use your IP:
   ```dart
   // lib/core/config/app_config.dart
   baseApiUrl: 'http://192.168.1.X:8080',  // Replace X with your IP
   ```

3. Update backend to allow this IP:
   ```properties
   # application.properties
   server.address=0.0.0.0
   ```

### 3. URL Launcher Permissions

**Problem**: The app doesn't have permission to launch external URLs.

**Android Solution**:
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<queries>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="http" />
    </intent>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="https" />
    </intent>
</queries>
```

**iOS Solution**:
iOS should work by default, but if not, add to `ios/Runner/Info.plist`:
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>http</string>
    <string>https</string>
</array>
```

### 4. Backend OAuth Configuration Issue

**Problem**: Backend's OAuth redirect configuration is incorrect.

**Check backend configuration**:
```properties
# application.properties or application.yml
spring.security.oauth2.client.registration.google.client-id=YOUR_CLIENT_ID
spring.security.oauth2.client.registration.google.client-secret=YOUR_CLIENT_SECRET
spring.security.oauth2.client.registration.google.redirect-uri={baseUrl}/login/oauth2/code/google
```

**Verify Google OAuth credentials**:
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Check your OAuth 2.0 Client ID
3. Verify authorized redirect URIs include: `http://localhost:8080/login/oauth2/code/google`

### 5. Check Logs

**View Flutter logs**:
```bash
flutter logs
```

Look for lines like:
```
I/flutter: Attempting to launch OAuth URL: http://10.0.2.2:8080/oauth2/authorization/google
I/flutter: Can launch URL: true/false
I/flutter: URL launched successfully: true/false
```

**View Backend logs**:
Check your Spring Boot console for:
- OAuth endpoint being hit
- Any errors or exceptions
- Google API responses

## Testing Without OAuth (Development)

If you want to test the app flow without OAuth setup, you can simulate tokens:

1. Comment out the OAuth redirect in backend
2. Manually create test tokens
3. Use the deep link directly:

```bash
# Test deep link with fake tokens
adb shell am start -W -a android.intent.action.VIEW \
  -d "poetry://app/auth/callback?access_token=test123&refresh_token=refresh123" \
  com.example.flutter_poetry_app
```

## Quick Checklist

Before clicking "Continue with Google", verify:

- [ ] Backend is running (`curl http://localhost:8080/`)
- [ ] Google OAuth credentials are configured in backend
- [ ] Correct API URL for your platform (check Debug Info panel)
- [ ] If using real device, backend is accessible on network
- [ ] Check Flutter logs for URL being launched
- [ ] Check backend logs for incoming requests

## Common Error Messages

### "Could not launch Google Sign In"
- Backend not running or not accessible
- Wrong API URL for platform

### "Could not launch URL: SocketException"
- Network connectivity issue
- Backend not reachable from device/emulator

### "Could not launch URL: Connection refused"
- Backend not running on specified port
- Firewall blocking connection

### "Error 400: redirect_uri_mismatch"
- Backend redirect URI doesn't match Google OAuth settings
- Go to Google Cloud Console and add correct redirect URI

### Deep link not working after OAuth
- Intent filter not configured correctly in AndroidManifest.xml
- URL scheme not registered in iOS Info.plist
- Backend not redirecting to `poetry://app/auth/callback`

## Still Having Issues?

1. **Hot restart** the app (not hot reload):
   ```bash
   # Press 'R' in terminal where flutter run is active
   # Or
   flutter run
   ```

2. **Clear app data** (Android):
   ```bash
   adb shell pm clear com.example.flutter_poetry_app
   ```

3. **Check the actual URL** being generated:
   The Debug Info panel shows the API URL. The OAuth URL should be:
   `{API_URL}/oauth2/authorization/google`

4. **Test backend directly** in browser:
   Open: `http://localhost:8080/oauth2/authorization/google`
   Should redirect to Google OAuth page

5. **Enable verbose logging**:
   ```dart
   // lib/main.dart
   Logger.level = Level.verbose;
   ```

## Need More Help?

Check these files for current configuration:
- `lib/core/config/app_config.dart` - API URLs
- `lib/core/utils/platform_utils.dart` - Platform detection
- `android/app/src/main/AndroidManifest.xml` - Deep links
- `ios/Runner/Info.plist` - Deep links
- Backend `application.properties` - OAuth config
