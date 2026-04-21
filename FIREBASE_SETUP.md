# Firebase Setup Instructions

## ⚠️ Important: Firebase Configuration Files

This project uses Firebase for authentication and backend services. The following files are **NOT** included in the repository for security reasons:

### Required Files (You must add these):

1. **`android/app/google-services.json`**
   - Download from Firebase Console → Project Settings → Your Android App
   - Place in `android/app/` directory

2. **`ios/Runner/GoogleService-Info.plist`** (if using iOS)
   - Download from Firebase Console → Project Settings → Your iOS App
   - Place in `ios/Runner/` directory

3. **`lib/firebase_options.dart`**
   - Generate using FlutterFire CLI:
   ```bash
   flutterfire configure
   ```

4. **`android/key.properties`**
   - Copy `android/key.properties.example` to `android/key.properties`
   - Fill in your actual keystore credentials
   - **NEVER commit this file to Git**

## Setup Steps

1. Create a Firebase project at https://console.firebase.google.com
2. Add Android/iOS apps to your Firebase project
3. Download the configuration files
4. Run `flutterfire configure` to generate firebase_options.dart
5. Create your signing key and update key.properties

## Security Note

These files contain sensitive API keys and credentials. Keep them secure and never commit them to version control.
