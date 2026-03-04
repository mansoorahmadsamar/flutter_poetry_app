# Production Deployment Checklist

## ✅ Completed Steps

### Backend Integration
- [x] Updated production API base URL to `https://134.199.243.167/api`
- [x] Configured SSL certificate handling for self-signed certificate
- [x] Added Firebase Web Client ID for production
- [x] Verified production API is accessible and healthy

### Configuration Files Modified
1. ✅ [lib/core/config/app_config.dart](lib/core/config/app_config.dart)
   - Updated `baseApiUrl` for production
   - Added `googleWebClientId` for Firebase auth

2. ✅ [lib/core/network/dio_client.dart](lib/core/network/dio_client.dart)
   - Added SSL certificate handling for `134.199.243.167`
   - Configured `badCertificateCallback` for self-signed cert

## 🧪 Testing Required

### 1. Build & Run Tests
```bash
# Test in development mode (uses localhost)
flutter run

# Test in release mode (uses production server)
flutter run --release
```

### 2. Feature Testing
Test these features in release mode:

#### Authentication
- [ ] Google Sign-In
- [ ] User registration
- [ ] Login/Logout
- [ ] Token refresh

#### Search & Discovery
- [ ] Couplet search
- [ ] Autocomplete suggestions
- [ ] Trending searches
- [ ] Filter by poet
- [ ] Sort options (relevance, likes, trending)

#### User Engagement
- [ ] Bookmark couplets
- [ ] Bookmark poets
- [ ] Like couplets
- [ ] View user profile
- [ ] Update profile

#### Content Browsing
- [ ] Browse poems by poet
- [ ] View poet profiles
- [ ] Category filtering
- [ ] Language preferences

### 3. API Connectivity Tests
```bash
# Health check
curl -k https://134.199.243.167/api/health

# Test public endpoints
curl -k https://134.199.243.167/api/poems?page=0&size=5

# Test search
curl -k "https://134.199.243.167/api/search/couplets?q=محبت&lang=ur"
```

### 4. Platform-Specific Testing

#### Android
```bash
# Build APK
flutter build apk --release

# Install and test
flutter install
```

#### iOS
```bash
# Build iOS
flutter build ios --release

# Test on simulator
flutter run --release -d "iPhone 15 Pro"
```

## 🔧 Environment Configuration

### Current Setup
| Environment | API Base URL | Build Mode | Logging |
|------------|--------------|------------|---------|
| Development | `https://134.199.243.167` | Debug | ✅ Enabled |
| Production | `https://134.199.243.167` | Release | ❌ Disabled |
| Staging | `https://stage-api.poetry.app` | Profile | ✅ Enabled |

**Note:** Service paths include `/api/` prefix, so full URLs are like `https://134.199.243.167/api/poems`

### How It Works
All environments use the production server, but with different configurations:
- `flutter run` → Development mode (with logging for debugging)
- `flutter run --release` → Production mode (optimized, no logging)
- `flutter run --profile` → Staging mode (different server)

## 🚨 Known Issues & Solutions

### Issue: SSL Certificate Error on Real Devices
**Status:** ✅ Fixed
**Solution:** Added `badCertificateCallback` in DioClient to accept self-signed cert

### Issue: Firebase Authentication
**Status:** ⚠️ Needs Testing
**Action Required:**
1. Verify Firebase is configured correctly
2. Test Google Sign-In flow
3. Verify backend accepts Firebase tokens

### Issue: CORS (Web Platform)
**Status:** ℹ️ Info
**Note:** Backend CORS should already be configured. If issues arise, check nginx config.

## 📱 Build for Distribution

### Android (APK)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android (App Bundle for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (Archive for App Store)
```bash
flutter build ios --release
# Then open Xcode and archive for distribution
```

## 🔐 Security Checklist

- [ ] Firebase credentials are not exposed in code
- [ ] API keys are properly configured
- [ ] SSL certificate validation is working (or properly bypassed for testing)
- [ ] User tokens are securely stored (SecureStorage)
- [ ] No sensitive data in logs (production has logging disabled)

## 📊 Monitoring

### Backend Health
```bash
# Check backend status
curl -k https://134.199.243.167/actuator/health

# View backend logs
ssh -i ~/.ssh/id_ed25519 root@134.199.243.167
docker logs -f poetry-backend
```

### App Analytics
- [ ] Firebase Analytics configured
- [ ] Crash reporting enabled
- [ ] User engagement metrics tracking

## 🚀 Next Steps

1. **Test Release Build**
   - Build release APK/IPA
   - Install on real devices
   - Test all features end-to-end

2. **Firebase Setup Verification**
   - Verify `google-services.json` is up to date
   - Verify `GoogleService-Info.plist` is up to date
   - Test authentication flow

3. **Backend Verification**
   - Ensure all required endpoints are working
   - Verify database has test data
   - Check Elasticsearch indices are populated

4. **Performance Testing**
   - Test with slow network
   - Test with airplane mode toggle
   - Verify retry logic works

5. **Future Production Migration**
   When you get a proper domain:
   - [ ] Update `baseApiUrl` to domain (e.g., `https://api.poetry.app`)
   - [ ] Install valid SSL certificate on server
   - [ ] Remove `badCertificateCallback` from DioClient
   - [ ] Update Firebase OAuth redirect URIs

## 📚 Documentation References

- [PRODUCTION_INTEGRATION_SUMMARY.md](PRODUCTION_INTEGRATION_SUMMARY.md) - Technical changes made
- [PRODUCTION_USAGE_GUIDE.md](PRODUCTION_USAGE_GUIDE.md) - Backend API documentation
- Backend API Docs - Complete endpoint reference

## ✅ Final Sign-Off

Before releasing to users:
- [ ] All tests pass
- [ ] Authentication works
- [ ] Search & discovery work
- [ ] User engagement features work
- [ ] App doesn't crash on startup
- [ ] Network errors are handled gracefully
- [ ] Performance is acceptable
- [ ] Firebase Analytics tracking works

---

**Last Updated:** 2026-01-14
**Status:** Ready for Testing
**Next Action:** Build release version and test
