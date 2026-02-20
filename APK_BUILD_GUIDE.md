# 📱 QuickBite APK Build Guide

## Automatic APK Building with GitHub Actions

Your project is now configured to automatically build Android APKs using GitHub Actions!

---

## 🚀 How It Works

Every time you push code to GitHub, the workflow will:
1. ✅ Set up Flutter environment
2. ✅ Install dependencies
3. ✅ Build release APK
4. ✅ Upload APK as downloadable artifact
5. ✅ Create GitHub Release (when you push a version tag)

---

## 📦 Getting Your First APK

### Step 1: Push to GitHub

```powershell
# Make sure you're in the project directory
cd "C:\Users\Kaustub Lade\OneDrive\Desktop\kgl\projects\quickbite"

# Add the workflow file
git add .github/workflows/build-apk.yml

# Commit
git commit -m "Add GitHub Actions workflow for APK builds"

# Push to GitHub
git push origin main
```

If your default branch is `master` instead of `main`, use:
```powershell
git push origin master
```

### Step 2: Monitor the Build

1. Go to your GitHub repository: https://github.com/kaustub-lade/quickbite
2. Click the **"Actions"** tab at the top
3. You'll see "Build Android APK" workflow running
4. Wait 5-10 minutes for the build to complete

### Step 3: Download Your APK

Once the build is complete:
1. Click on the completed workflow run
2. Scroll down to **"Artifacts"** section
3. Download **"QuickBite-APK"**
4. Extract the ZIP file
5. You'll find `QuickBite-v1.0.0.apk`

---

## 🏷️ Creating Releases (Recommended)

For official releases with download links:

```powershell
# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0
```

This will:
- ✅ Build the APK
- ✅ Create a GitHub Release page
- ✅ Attach the APK file directly (no ZIP extraction needed)
- ✅ Add release notes with test credentials

Then anyone can download from: `https://github.com/kaustub-lade/quickbite/releases`

---

## 🔄 Manual Builds

You can also trigger builds manually:
1. Go to **Actions** tab on GitHub
2. Click **"Build Android APK"** workflow
3. Click **"Run workflow"** button
4. Select branch and click **"Run workflow"**

---

## 📝 Version Management

To update the version for new releases:

1. Edit `mobile/pubspec.yaml`:
   ```yaml
   version: 1.0.0+1  # Change to 1.1.0+2, 2.0.0+3, etc.
   ```

2. Commit and push:
   ```powershell
   git add mobile/pubspec.yaml
   git commit -m "Bump version to 1.1.0"
   git push origin main
   ```

3. Create release tag:
   ```powershell
   git tag v1.1.0
   git push origin v1.1.0
   ```

---

## 🎯 APK Details

**What Gets Built:**
- **File Name**: `QuickBite-v1.0.0.apk`
- **Build Mode**: Release (optimized, production-ready)
- **Size**: ~20-50 MB (typical Flutter app)
- **Supported**: Android 5.0+ (API 21+)

**Installation:**
1. Transfer APK to Android device
2. Enable "Install from Unknown Sources" in Settings
3. Tap APK file to install
4. Open QuickBite app

---

## 🔑 Test Credentials

Included in release notes automatically:
- **Customer**: kaustub@example.com / customer123
- **Admin**: admin@quickbite.com / admin123

---

## ⚙️ Workflow Configuration

**Triggers:**
- ✅ Push to `main` or `master` branch
- ✅ Push version tags (`v*`)
- ✅ Manual workflow dispatch

**Build Time**: 5-10 minutes

**Artifact Retention**: 30 days

---

## 🛠️ Troubleshooting

**Build Failed?**
1. Check the Actions tab logs for errors
2. Common issues:
   - Syntax errors in Dart code
   - Missing dependencies in pubspec.yaml
   - Android build configuration issues

**Can't find APK?**
- Make sure the build completed successfully (green checkmark)
- Look in the "Artifacts" section at the bottom of the workflow run page
- For tagged releases, check the "Releases" page

**Branch name mismatch?**
- The workflow is configured for `main` and `master`
- If you use a different branch, edit `.github/workflows/build-apk.yml` line 5

---

## 📱 Next Steps

1. **Push to GitHub** - Your first APK will build automatically
2. **Download APK** - Get it from Actions → Artifacts
3. **Test on Device** - Install and test the app
4. **Create Release** - Tag version for public downloads
5. **Share** - Send release link to testers/users

---

## 🎉 That's It!

Your QuickBite app now has:
✅ Automated APK builds
✅ Professional CI/CD pipeline
✅ Easy distribution via GitHub Releases
✅ Version tracking and release notes

Push your code and watch the magic happen! 🚀
