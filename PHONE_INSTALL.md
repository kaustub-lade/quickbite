# 📱 Install QuickBite on Your Phone

## Prerequisites
- Android phone with USB cable
- Windows PC with Flutter installed ✅
- 5 minutes of setup time

## Step 1: Enable Developer Mode

### For Samsung:
1. Go to **Settings** → **About phone** → **Software information**
2. Tap **Build number** 7 times rapidly
3. Enter your PIN/password
4. You'll see: *"Developer mode has been enabled"*

### For Xiaomi/Redmi/POCO:
1. Go to **Settings** → **About phone**
2. Tap **MIUI Version** 7 times rapidly
3. Enter your password
4. You'll see: *"You are now a developer!"*

### For OnePlus:
1. Go to **Settings** → **About device**
2. Tap **Build number** 7 times
3. Enter your password
4. Developer options enabled!

### For Realme/Oppo:
1. Go to **Settings** → **About phone** → **Version**
2. Tap **Build number** 7 times
3. Enter your password

### For Vivo:
1. Go to **Settings** → **About phone**
2. Tap **Software version** 7 times

## Step 2: Enable USB Debugging

1. Go back to **Settings**
2. Find **Developer Options** (might be under System or Additional Settings)
3. Turn ON **USB Debugging**
4. Tap **OK** on the warning popup

**Optional but recommended:**
- Turn ON **Install via USB** (allows installing apps)
- Turn ON **USB debugging (Security settings)** (if available)

## Step 3: Connect Your Phone

1. **Connect USB cable** from phone to PC
2. On phone, you'll see **"USB charging this device"** notification
3. Tap it and select:
   - **File Transfer** (MTP) or
   - **PTP** or
   - **Transfer files**
4. A popup appears: **"Allow USB debugging?"**
   - ✅ Check **"Always allow from this computer"**
   - Tap **OK** or **Allow**

## Step 4: Verify Connection

Open PowerShell in your project and run:
```bash
cd mobile
flutter devices
```

**Expected output:**
```
Found 4 connected devices:
  SM-G991B (mobile) • R5CR1234567 • android-arm64 • Android 14 (API 34)  ← Your phone!
  Windows (desktop) • windows • windows-x64 • Microsoft Windows
  Chrome (web)      • chrome  • web-javascript • Google Chrome
  Edge (web)        • edge    • web-javascript • Microsoft Edge
```

## Step 5: Install App on Phone

### Option A: Automatic Install (Recommended)
```bash
# Make sure you're in the mobile folder
cd mobile

# This will build and install on your phone automatically
flutter run
```

Flutter will:
1. Build the APK (takes 2-3 minutes first time)
2. Install it on your phone
3. Launch the app automatically
4. Enable hot reload (press 'r' to refresh)

### Option B: Build APK File
```bash
# Build release APK
flutter build apk --release

# APK location:
# mobile/build/app/outputs/flutter-apk/app-release.apk

# Transfer APK to phone and install manually
```

## Step 6: Run the App

Once installed:
1. **Backend must be running:** Open Terminal 1 and run `npm run dev`
2. **Update API URL:** Your phone can't use `localhost`

### Fix API Connection for Phone

Edit `mobile/lib/services/api_service.dart`:

**Find your PC's IP address:**
```bash
ipconfig
# Look for "IPv4 Address" under your WiFi/Ethernet adapter
# Example: 192.168.1.5
```

**Update API URL:**
```dart
// Change from:
final String baseUrl = 'http://10.0.2.2:3000';

// To your PC's IP:
final String baseUrl = 'http://192.168.1.5:3000';  // Use YOUR IP!
```

**Important:** Your phone and PC must be on the **same WiFi network**!

### Allow Firewall Access

When you first connect, Windows might ask:
- **"Allow Node.js to communicate on networks?"**
- ✅ Check **Private networks**
- Click **Allow access**

## Troubleshooting

### Phone not detected?
1. Try a different USB cable (some cables are charge-only)
2. Try different USB ports on PC
3. Restart both phone and PC
4. Make sure USB debugging is ON
5. Try these ADB commands:
   ```bash
   adb devices
   adb kill-server
   adb start-server
   adb devices
   ```

### "Device unauthorized" message?
- Disconnect and reconnect USB
- Check phone for "Allow USB debugging?" popup
- Tap "Always allow" and OK

### Build fails?
```bash
cd mobile
flutter clean
flutter pub get
flutter run
```

### App installed but can't connect to API?
1. Check backend is running: `npm run dev`
2. Check your PC's IP: `ipconfig`
3. Update `api_service.dart` with correct IP
4. Both devices on same WiFi
5. Check Windows Firewall allows Node.js
6. Test in browser: `http://YOUR_IP:3000/api/db-test`

### App crashes on phone?
- Check backend logs for errors
- Run: `flutter run` to see error messages
- Check internet permission in AndroidManifest.xml (already added ✅)

## Hot Reload on Phone

While app is running:
1. Make code changes in VS Code
2. In terminal, press **'r'** → Changes appear on phone instantly!
3. Press **'R'** → Full restart
4. Press **'q'** → Quit

## Performance Tips

- First install takes 2-3 minutes (building APK)
- Subsequent runs using hot reload are instant
- Release build is smaller and faster:
  ```bash
  flutter build apk --release
  ```

## What You'll Test

✅ Full mobile experience:
- Touch gestures (swipe, tap, scroll)
- Real device performance
- Network requests to backend
- Shopping cart flow
- Search functionality
- All animations and transitions

📱 Your phone will have the complete QuickBite app just like Zomato/Swiggy!

---

**Ready?** Connect your phone and type: `flutter devices`

If you see your phone listed, run: `flutter run` 🚀
