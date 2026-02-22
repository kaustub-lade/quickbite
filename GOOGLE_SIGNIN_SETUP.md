# Google Sign-In & Location Setup Guide

## Overview

This guide covers the setup required for Google OAuth authentication and GPS location features in the QuickBite mobile app.

## Google Sign-In Configuration

### Prerequisites

1. Google Cloud Console account
2. Android Studio (for getting SHA-1 fingerprint)
3. Xcode (for iOS development)

### Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Select a project" → "New Project"
3. Enter project name: "QuickBite"
4. Click "Create"

### Step 2: Enable Google Sign-In API

1. Navigate to "APIs & Services" → "Library"
2. Search for "Google Sign-In"
3. Click "Google Sign-In API" → "Enable"

### Step 3: Configure OAuth Consent Screen

1. Navigate to "APIs & Services" → "OAuth consent screen"
2. Choose "External" user type
3. Fill in required fields:
   - **App name**: QuickBite
   - **User support email**: Your email
   - **Developer contact**: Your email
4. Add scopes: `email`, `profile`
5. Save and continue

### Step 4: Create Android OAuth Client

#### Get SHA-1 Fingerprint (Development)

```bash
# Windows
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

# macOS/Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Copy the **SHA-1** fingerprint from the output.

#### Create OAuth Client

1. Navigate to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "OAuth 2.0 Client ID"
3. Application type: **Android**
4. Fill in:
   - **Name**: QuickBite Android
   - **Package name**: `com.quickbite.app` (from `mobile/android/app/build.gradle`)
   - **SHA-1 certificate fingerprint**: Paste the fingerprint from above
5. Click "Create"
6. **Copy the Client ID** (you'll need this)

#### Configure Android App

No additional configuration needed! The `google_sign_in` package automatically uses package name + SHA-1 for Android authentication.

### Step 5: Create iOS OAuth Client

1. Navigate to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "OAuth 2.0 Client ID"
3. Application type: **iOS**
4. Fill in:
   - **Name**: QuickBite iOS
   - **Bundle ID**: `com.quickbite.app` (from `mobile/ios/Runner.xcodeproj`)
5. Click "Create"
6. **Copy the Client ID** (format: `XXXXXXXX-XXXXXXXX.apps.googleusercontent.com`)

#### Configure iOS App

1. Open `mobile/ios/Runner/Info.plist`
2. Add the following **before** `</dict></plist>`:

```xml
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<!-- Replace with your iOS Client ID (reversed) -->
				<string>com.googleusercontent.apps.XXXXXXXX-XXXXXXXX</string>
			</array>
		</dict>
	</array>
	<key>GIDClientID</key>
	<string>XXXXXXXX-XXXXXXXX.apps.googleusercontent.com</string>
```

3. Replace `XXXXXXXX-XXXXXXXX` with your actual iOS Client ID

### Step 6: Test Google Sign-In

1. Run the app: `flutter run`
2. Navigate to login screen
3. Click "Continue with Google"
4. Select Google account
5. Verify successful login and redirect to HomeScreen

## Location Permissions Configuration

### Android Configuration

Location permissions are already configured in `mobile/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS Configuration

Location permission descriptions are already configured in `mobile/ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby restaurants and provide accurate delivery estimates</string>
```

### Testing Location Permissions

1. Run the app
2. On first launch at HomeScreen, permission dialog should appear
3. Grant "While using app" permission
4. Location will be automatically sent to backend

## Troubleshooting

### Google Sign-In Issues

**Problem**: "Sign-in failed" or "Invalid client"

**Solution**:
- Verify SHA-1 fingerprint matches your debug keystore
- Check package name in `android/app/build.gradle` matches OAuth client
- Ensure Android OAuth client is created for correct SHA-1

**Problem**: iOS "No IDToken" error

**Solution**:
- Verify `Info.plist` has correct reversed iOS Client ID
- Check `GIDClientID` matches your iOS OAuth Client ID
- Run `flutter clean` and rebuild

### Location Permission Issues

**Problem**: Permission dialog doesn't appear

**Solution**:
- Check `AndroidManifest.xml` has location permissions
- Verify `Info.plist` has `NSLocationWhenInUseUsageDescription`
- Try uninstalling and reinstalling the app

**Problem**: "Location services disabled"

**Solution**:
- Enable GPS in device settings
- Call `LocationService.openLocationSettings()` to prompt user

## Production Setup

### Android Production OAuth Client

1. Generate **release keystore**:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Get SHA-1 for release keystore:

```bash
keytool -list -v -keystore ~/upload-keystore.jks -alias upload
```

3. Create new Android OAuth Client with **release SHA-1**
4. Configure signing in `android/app/build.gradle`

### iOS Production Setup

1. Create App ID in Apple Developer Portal
2. Enable "Sign in with Apple" capability (optional but recommended)
3. Configure provisioning profile
4. Update `Info.plist` with production iOS Client ID

## Environment Variables

No environment variables required for Google Sign-In or Location (OAuth credentials are configured per platform manifest files).

## Backend API Endpoints

- **Google Sign-In**: `POST /api/auth/google`
- **Update Location**: `PATCH /api/auth/location`

## Security Notes

- OAuth Client IDs are **not secrets** - they can be embedded in the app
- SHA-1 fingerprints validate the app's authenticity
- Backend validates all authentication tokens
- Location data is only sent for authenticated users

## References

- [Google Sign-In Flutter Documentation](https://pub.dev/packages/google_sign_in)
- [Geolocator Flutter Documentation](https://pub.dev/packages/geolocator)
- [Google Cloud Console](https://console.cloud.google.com/)
