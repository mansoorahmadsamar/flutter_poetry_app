# GitHub Secrets Setup for Android Firebase App Distribution

## Step-by-Step Instructions

### 1. Go to Your GitHub Repository
- Navigate to: https://github.com/YOUR_USERNAME/YOUR_REPO_NAME
- Click **Settings** (top right)
- In the left sidebar, click **Secrets and variables** > **Actions**

### 2. Add the Following Secrets

Click **"New repository secret"** for each of these:

---

#### Secret 1: FIREBASE_ANDROID_APP_ID
**Name:** `FIREBASE_ANDROID_APP_ID`

**Value:**
```
1:381838704656:android:aaa0ddbf1692003ee88a95
```

**Description:** Your Firebase Android App ID

---

#### Secret 2: GOOGLE_SERVICES_JSON
**Name:** `GOOGLE_SERVICES_JSON`

**Value:** Copy the entire content from this file:
```
.github/GOOGLE_SERVICES_JSON.base64
```

**How to copy:**
1. Open the file `.github/GOOGLE_SERVICES_JSON.base64` in your editor
2. Select all and copy the entire base64 string
3. Paste into GitHub secret value field

**Description:** Base64 encoded google-services.json

---

#### Secret 3: FIREBASE_SERVICE_ACCOUNT
**Name:** `FIREBASE_SERVICE_ACCOUNT`

**Value:** Copy the entire content from this file:
```
.github/FIREBASE_SERVICE_ACCOUNT.base64
```

**How to copy:**
1. Open the file `.github/FIREBASE_SERVICE_ACCOUNT.base64` in your editor
2. Select all and copy the entire base64 string
3. Paste into GitHub secret value field

**Description:** Base64 encoded Firebase service account JSON

---

## Verification

After adding all 3 secrets, you should see:
- ✅ FIREBASE_ANDROID_APP_ID
- ✅ GOOGLE_SERVICES_JSON
- ✅ FIREBASE_SERVICE_ACCOUNT

## Next Steps

Once you've added these secrets to GitHub:
1. Create a tester group in Firebase Console
2. Test the workflow by pushing to the develop branch

## Security Note

⚠️ **IMPORTANT:**
- Never commit the actual service account JSON file to git
- Never share the base64 encoded files publicly
- The `.base64` files in `.github/` are for your reference only
- Add them to .gitignore to prevent accidental commits
