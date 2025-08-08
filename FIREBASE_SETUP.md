# Firebase Credentials Setup

## Overview
This project uses Firebase Admin SDK for push notifications. For security reasons, the service account credentials are not included in the repository.

## Setup Instructions

### 1. Get Firebase Service Account Credentials

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project (`chatas-9469d`)
3. Go to **Project Settings** > **Service Accounts**
4. Click **Generate new private key**
5. Download the JSON file

### 2. Add Credentials to Your Local Project

#### Method 1: Assets Folder (Recommended for Development)
1. Create `assets` folder in project root if it doesn't exist
2. Copy the downloaded JSON file to `assets/firebase_credentials.json`
3. Add to `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/firebase_credentials.json
```

#### Method 2: Environment Variables (Recommended for Production)
Set the following environment variables:
- `FIREBASE_PROJECT_ID`
- `FIREBASE_PRIVATE_KEY`
- `FIREBASE_CLIENT_EMAIL`
- etc.

### 3. File Structure
```
project_root/
├── assets/
│   └── firebase_credentials.json  # ← Add this file (gitignored)
├── lib/
└── pubspec.yaml
```

### 4. Security Notes
- ✅ The credentials file is automatically gitignored
- ✅ Never commit credentials to version control
- ✅ Use environment variables in production
- ✅ Rotate keys regularly

### 5. Verification
Run the app and check console logs:
- ✅ `Firebase credentials loaded successfully`
- ❌ `Error loading Firebase credentials`

## Troubleshooting

### No Notifications Received
1. Check credentials are loaded properly
2. Verify FCM tokens are saved to Firestore
3. Check notification permissions
4. Check Firebase Console logs

### Error: "Service account credentials chưa được khởi tạo"
- Ensure `firebase_credentials.json` exists in `assets/` folder
- Check `pubspec.yaml` includes the assets path
- Run `flutter clean && flutter pub get`
