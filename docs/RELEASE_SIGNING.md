# Release Signing Configuration

This document contains all the information needed for release signing and Google Sign-in configuration.

## Release Keystore Information

| Property | Value |
|----------|-------|
| **Keystore File** | `android/keystore/release.keystore` |
| **Key Alias** | `poetry_app` |
| **Key Password** | `poetry_release_2024` |
| **Store Password** | `poetry_release_2024` |
| **Validity** | 10,000 days (~27 years) |
| **Algorithm** | RSA 2048-bit |

### Certificate Fingerprints

```
SHA-1:   36:CA:B2:60:A1:B4:6E:48:BA:C6:CE:4D:43:87:D3:F0:2C:9E:19:39
SHA-256: 1C:BF:5C:7C:E0:2F:42:9D:8E:B6:59:56:BA:B7:D9:27:04:B6:11:2F:F4:84:E7:ED:4C:5D:76:21:B5:71:55:C1
```

### SHA-1 (No Colons - for Firebase Console)
```
36cab260a1b46e48bac6ce4d4387d3f02c9e1939
```

---

## GitHub Secrets Required

Add these secrets in **GitHub Repo → Settings → Secrets and variables → Actions**:

| Secret Name | Value |
|-------------|-------|
| `RELEASE_KEYSTORE_BASE64` | Base64-encoded keystore (see below) |
| `KEY_ALIAS` | `poetry_app` |
| `KEY_PASSWORD` | `poetry_release_2024` |
| `STORE_PASSWORD` | `poetry_release_2024` |

### Base64-Encoded Keystore

```
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
```

---

## Firebase Console Setup

### Add SHA-1 Fingerprint

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **poetry-world-eaf6c**
3. Click **Project Settings** (gear icon) → **General**
4. Scroll to **Your apps** → Select **Android app** (`com.techhikes.poetry_app`)
5. Click **Add fingerprint**
6. Paste: `36:CA:B2:60:A1:B4:6E:48:BA:C6:CE:4D:43:87:D3:F0:2C:9E:19:39`
7. Click **Save**
8. Download the updated `google-services.json`
9. Update GitHub secret `GOOGLE_SERVICES_JSON` with new base64-encoded file:
   ```bash
   base64 -i android/app/google-services.json
   ```

### Current Fingerprints in Firebase

| Type | SHA-1 Fingerprint | Purpose |
|------|-------------------|---------|
| Debug | `95:B6:A7:2C:E7:40:36:75:B1:9B:7B:B6:EE:F6:AA:44:86:49:37:65` | Local development |
| Release | `36:CA:B2:60:A1:B4:6E:48:BA:C6:CE:4D:43:87:D3:F0:2C:9E:19:39` | Production builds |

---

## Local Development Setup

The `key.properties` file is created at `android/key.properties`:

```properties
storePassword=poetry_release_2024
keyPassword=poetry_release_2024
keyAlias=poetry_app
storeFile=../keystore/release.keystore
```

This file is gitignored and should not be committed.

---

## Build Commands

### Local Release Build
```bash
flutter build apk --release
```

### Install on Device/Emulator
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Get Fingerprint from Keystore
```bash
keytool -list -v -keystore android/keystore/release.keystore -alias poetry_app -storepass poetry_release_2024
```

---

## CI/CD Configuration

The workflow at `.github/workflows/firebase-app-distribution.yml` handles:
1. Decodes keystore from `RELEASE_KEYSTORE_BASE64` secret
2. Uses environment variables for signing credentials
3. Builds release APK with proper signing
4. Uploads to Firebase App Distribution

---

## Important Notes

1. **Backup the keystore!** If lost, you cannot update the app on Play Store.
2. **Keep passwords secure** - Consider using stronger passwords for production.
3. **Both fingerprints needed** - Debug for local dev, Release for production.
4. After adding SHA-1 to Firebase, re-download `google-services.json` and update the GitHub secret.

---

## Troubleshooting

### Google Sign-in crashes on release build
- Verify SHA-1 fingerprint is registered in Firebase Console
- Ensure `google-services.json` was downloaded AFTER adding the fingerprint
- Check that the APK is signed with the correct keystore

### Build fails with signing error
- Verify `key.properties` exists and has correct paths
- Check that keystore file exists at specified location
- Ensure passwords match

### CI/CD build fails
- Verify all GitHub secrets are set correctly
- Check that `RELEASE_KEYSTORE_BASE64` is properly base64-encoded
