# Flutter Installation Guide for Windows

## Prerequisites Check ✅

Your system has:
- ✅ Git: 2.51.0 (Required)
- ✅ Java: OpenJDK 17.0.14 (Required for Android)

## Method 1: Install Using winget (Recommended - Easiest)

### Step 1: Install Flutter
```powershell
# Open PowerShell as Administrator and run:
winget install --id=Google.Flutter -e
```

### Step 2: Add to PATH
After installation, add Flutter to your PATH:
1. Press `Windows + X` and select "System"
2. Click "Advanced system settings"
3. Click "Environment Variables"
4. Under "User variables", find "Path" and click "Edit"
5. Click "New" and add: `C:\Users\alpas\flutter\bin`
6. Click "OK" on all windows

### Step 3: Verify Installation
```bash
# Close and reopen terminal, then run:
flutter --version
flutter doctor
```

---

## Method 2: Manual Installation (More Control)

### Step 1: Download Flutter SDK
1. Go to: https://docs.flutter.dev/get-started/install/windows
2. Download the Flutter SDK zip file (latest stable)
3. Or use direct link: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip

### Step 2: Extract Flutter
```bash
# Extract to a location (NOT in Program Files)
# Recommended: C:\src\flutter
# Your user folder: C:\Users\alpas\flutter
```

Extract the zip file to: `C:\Users\alpas\flutter`

### Step 3: Add Flutter to PATH
1. Press `Windows + X` → System → Advanced system settings
2. Click "Environment Variables"
3. Under "User variables", select "Path" → "Edit"
4. Click "New" and add: `C:\Users\alpas\flutter\bin`
5. Click "OK" to save

### Step 4: Verify Installation
Open a NEW terminal (important - must restart terminal):
```bash
flutter --version
```

---

## Method 3: Quick Installation via Git

```bash
# Clone Flutter repository
cd C:\Users\alpas
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH (run in PowerShell as Admin)
$env:Path += ";C:\Users\alpas\flutter\bin"
[Environment]::SetEnvironmentVariable("Path", $env:Path, "User")

# Verify
flutter --version
```

---

## Post-Installation Setup

### Run Flutter Doctor
This checks for any missing dependencies:
```bash
flutter doctor
```

Expected output:
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x, on Microsoft Windows...)
[✓] Android toolchain - develop for Android devices
[!] Chrome - develop for the web (May need to install)
[✓] Visual Studio - develop Windows apps
[✓] Android Studio (version x.x)
[✓] VS Code (version x.x)
[✓] Connected device (x available)
[✓] Network resources
```

### Fix Common Issues

#### Issue 1: Android SDK Not Found
```bash
# Install Android SDK via Android Studio
# Or use Flutter's built-in Android SDK:
flutter config --android-sdk C:\Users\alpas\AppData\Local\Android\Sdk
```

#### Issue 2: Android Licenses
```bash
flutter doctor --android-licenses
# Accept all licenses by typing 'y'
```

#### Issue 3: Chrome Not Found
```bash
# Just install Google Chrome from:
# https://www.google.com/chrome/
```

---

## Quick Start for The Chain App

### 1. Navigate to Project
```bash
cd C:\Users\alpas\IdeaProjects\ticketz\mobile
```

### 2. Get Dependencies
```bash
flutter pub get
```

### 3. Check for Issues
```bash
flutter analyze
```

### 4. Run on Chrome (Easiest for Testing)
```bash
flutter run -d chrome
```

### 5. Run on Android Emulator
```bash
# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator_id>

# Run the app
flutter run
```

---

## Install Android Studio (For Android Development)

### Option 1: Download Installer
1. Go to: https://developer.android.com/studio
2. Download Android Studio
3. Run installer
4. Install with default settings
5. Open Android Studio
6. Go to: Tools → AVD Manager
7. Create a new Virtual Device (Pixel 6 recommended)

### Option 2: Use winget
```powershell
winget install --id=Google.AndroidStudio -e
```

---

## Verify Everything is Working

### Create Test App
```bash
# Create a test Flutter app
flutter create test_app
cd test_app
flutter run -d chrome
```

If a browser opens with a Flutter demo app, Flutter is working! 🎉

---

## Running The Chain App

Once Flutter is installed:

### 1. Ensure Backend is Running
```bash
cd C:\Users\alpas\IdeaProjects\ticketz
docker-compose ps
```

### 2. Install Dependencies
```bash
cd mobile
flutter pub get
```

### 3. Run on Chrome (Quick Test)
```bash
flutter run -d chrome
```

### 4. Test on Android
```bash
# Start emulator first
flutter emulators --launch Pixel_6_API_34

# Run app
flutter run
```

---

## Troubleshooting

### Problem: "flutter: command not found"
**Solution:**
- Restart your terminal
- Check PATH is set correctly
- Try absolute path: `C:\Users\alpas\flutter\bin\flutter.bat --version`

### Problem: Android licenses not accepted
**Solution:**
```bash
flutter doctor --android-licenses
```

### Problem: No devices found
**Solution:**
```bash
# For web
flutter run -d chrome

# For Android, start emulator first
flutter emulators
flutter emulators --launch <emulator_id>
```

### Problem: "Unable to locate Android SDK"
**Solution:**
```bash
# Point to your Android SDK
flutter config --android-sdk C:\Users\alpas\AppData\Local\Android\Sdk
```

---

## Quick Commands Reference

```bash
# Check Flutter version
flutter --version

# Check system requirements
flutter doctor

# Get dependencies
flutter pub get

# Run app
flutter run

# Run on specific device
flutter run -d chrome
flutter run -d <device_id>

# List devices
flutter devices

# List emulators
flutter emulators

# Clean project
flutter clean

# Analyze code
flutter analyze

# Build APK
flutter build apk
```

---

## Next Steps After Installation

1. ✅ Install Flutter
2. ✅ Run `flutter doctor`
3. ✅ Fix any issues
4. ✅ Navigate to mobile folder
5. ✅ Run `flutter pub get`
6. ✅ Run `flutter run -d chrome`
7. ✅ Test The Chain app!

---

## Alternative: Test Without Installing Flutter

If you want to skip Flutter for now, you can:

1. **Test Backend Only** - Use curl/Postman
2. **Deploy Backend** - Get it online
3. **Create Documentation** - Finish project docs

But installing Flutter is recommended to see your beautiful app in action! 🚀

---

## Support

If you encounter issues:
- Flutter Docs: https://docs.flutter.dev
- Flutter Discord: https://discord.gg/flutter
- Stack Overflow: Tag your question with `flutter`

Ready to see The Chain come to life! 💪
