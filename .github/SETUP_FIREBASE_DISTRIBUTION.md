# Firebase App Distribution Setup Guide

This guide will help you set up automated Firebase App Distribution for both Android and iOS using GitHub Actions.

## Prerequisites

1. Firebase project with App Distribution enabled
2. Android app registered in Firebase
3. iOS app registered in Firebase
4. GitHub repository with Actions enabled

## Step 1: Create Firebase Service Account

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** > **Service Accounts**
4. Click **Generate New Private Key**
5. Save the JSON file securely

## Step 2: Get Firebase App IDs

### Android App ID
1. In Firebase Console, go to **Project Settings**
2. Under "Your apps", find your Android app
3. Copy the **App ID** (format: `1:123456789:android:abcdef...`)

### iOS App ID
1. In Firebase Console, go to **Project Settings**
2. Under "Your apps", find your iOS app
3. Copy the **App ID** (format: `1:123456789:ios:abcdef...`)

## Step 3: Prepare Files for Base64 Encoding

### Android google-services.json
```bash
base64 -i android/app/google-services.json | pbcopy
```

### iOS GoogleService-Info.plist
```bash
base64 -i ios/Runner/GoogleService-Info.plist | pbcopy
```

### Firebase Service Account JSON
```bash
base64 -i path/to/firebase-service-account.json | pbcopy
```

## Step 4: iOS Code Signing Setup

### Export Certificate as P12
1. Open **Keychain Access** on Mac
2. Find your distribution certificate
3. Right-click > Export
4. Save as `.p12` with a password
5. Convert to base64:
```bash
base64 -i YourCertificate.p12 | pbcopy
```

### Export Provisioning Profile
1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Go to **Certificates, Identifiers & Profiles**
3. Create or download an **Ad Hoc** provisioning profile
4. Convert to base64:
```bash
base64 -i YourProfile.mobileprovision | pbcopy
```

### Update ExportOptions.plist
Edit `ios/ExportOptions.plist` and replace:
- `YOUR_TEAM_ID` with your Apple Team ID (found in Apple Developer account)
- `YOUR_BUNDLE_IDENTIFIER` with your app's bundle ID (e.g., `com.example.poetry`)
- `YOUR_PROVISIONING_PROFILE_NAME` with your provisioning profile name

## Step 5: Configure GitHub Secrets

Go to your GitHub repository > **Settings** > **Secrets and variables** > **Actions**

Add the following secrets:

### Required for Both Platforms
| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `FIREBASE_SERVICE_ACCOUNT` | Base64 encoded Firebase service account JSON | Step 3 |
| `FIREBASE_ANDROID_APP_ID` | Firebase Android App ID | Step 2 |
| `FIREBASE_IOS_APP_ID` | Firebase iOS App ID | Step 2 |

### Android Specific
| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `GOOGLE_SERVICES_JSON` | Base64 encoded google-services.json | Step 3 |

### iOS Specific
| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `GOOGLE_SERVICE_INFO_PLIST` | Base64 encoded GoogleService-Info.plist | Step 3 |
| `IOS_P12_BASE64` | Base64 encoded P12 certificate | Step 4 |
| `IOS_CERTIFICATE_PASSWORD` | Password for P12 certificate | Step 4 |
| `IOS_PROVISION_PROFILE_BASE64` | Base64 encoded provisioning profile | Step 4 |

## Step 6: Create Tester Groups in Firebase

1. Go to Firebase Console > **App Distribution**
2. Click on **Testers & Groups** tab
3. Create a group named **"testers"** (or modify the workflow to use a different group name)
4. Add tester emails to the group

## Step 7: Test the Workflow

### Trigger Automatically
Push to `develop` or `main` branch:
```bash
git push origin develop
```

### Trigger Manually
1. Go to GitHub repository > **Actions**
2. Select **Firebase App Distribution** workflow
3. Click **Run workflow**
4. Optionally add release notes
5. Click **Run workflow**

## Troubleshooting

### Common Issues

**Android build fails:**
- Verify `google-services.json` is correctly encoded
- Check Java version is compatible
- Ensure all dependencies are properly configured

**iOS build fails:**
- Verify provisioning profile matches bundle ID
- Check certificate is valid and not expired
- Ensure Team ID in ExportOptions.plist is correct
- Make sure the provisioning profile includes all required devices

**Firebase upload fails:**
- Verify Firebase service account has App Distribution Admin role
- Check App IDs are correct
- Ensure App Distribution is enabled in Firebase Console

### Useful Commands

View workflow logs:
```bash
gh run list --workflow=firebase-app-distribution.yml
gh run view <run-id> --log
```

Check secret names:
```bash
gh secret list
```

## Customization

### Change Trigger Branches
Edit `.github/workflows/firebase-app-distribution.yml`:
```yaml
on:
  push:
    branches:
      - your-branch-name
```

### Change Tester Groups
Edit the `groups` parameter in the workflow:
```yaml
groups: testers,qa-team,beta-users
```

### Build Different Variants
For Android, you can build different variants:
```yaml
- name: Build Android APK
  run: flutter build apk --release --flavor production
```

## Next Steps

1. Set up different workflows for staging/production
2. Add automated testing before distribution
3. Configure version numbering
4. Add Slack/Discord notifications on successful builds
5. Set up automated release notes from git commits

## Resources

- [Firebase App Distribution Documentation](https://firebase.google.com/docs/app-distribution)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
