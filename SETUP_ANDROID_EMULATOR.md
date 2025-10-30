# 📱 Android Emulator Setup Guide

Since the Posture Health Assistant uses camera and AI features that require mobile platform support, you'll need to run it on an Android emulator or physical device.

## Quick Setup - Android Emulator

### Option 1: Using Android Studio (Recommended)

1. **Download Android Studio**
   - Go to: https://developer.android.com/studio
   - Download and install Android Studio

2. **Open Android Studio**
   - Launch Android Studio
   - Click "More Actions" → "AVD Manager" (or "Tools" → "AVD Manager" if you have a project open)

3. **Create Virtual Device**
   - Click "Create Virtual Device"
   - Select a device (e.g., Pixel 6)
   - Click "Next"
   - Select a system image (Recommended: API 33 or higher)
   - Click "Next" → "Finish"

4. **Start the Emulator**
   - In AVD Manager, click the green play button next to your device
   - Wait for the emulator to boot completely

5. **Run the Flutter App**
   ```bash
   cd C:\Users\mf\CascadeProjects\posture-health-assistant
   flutter run
   ```

### Option 2: Command Line Setup (If Android SDK is installed)

1. **List available emulators**
   ```bash
   flutter emulators
   ```

2. **Create a new emulator**
   ```bash
   flutter emulators --create
   ```

3. **Launch emulator**
   ```bash
   flutter emulators --launch <emulator_id>
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Troubleshooting

### "No devices found" Error
1. Ensure emulator is fully booted
2. Run `flutter devices` to check
3. Try `adb devices` to verify connection

### Build Errors
```bash
flutter clean
flutter pub get
flutter run
```

### Emulator Too Slow
- Allocate more RAM in AVD settings
- Enable hardware acceleration (HAXM/WHPX)
- Use x86/x86_64 images instead of ARM

## 📱 Using Physical Device (Alternative)

### Android Phone Setup
1. **Enable Developer Options**
   - Settings → About Phone
   - Tap "Build Number" 7 times

2. **Enable USB Debugging**
   - Settings → Developer Options
   - Toggle "USB Debugging" ON

3. **Connect via USB**
   - Connect phone to PC with USB cable
   - Allow USB debugging when prompted

4. **Run the app**
   ```bash
   flutter run
   ```

## 🚀 Quick Start Commands

Once emulator/device is connected:

```bash
# Navigate to project
cd C:\Users\mf\CascadeProjects\posture-health-assistant

# Get dependencies
flutter pub get

# Run the app
flutter run

# For better performance (after testing)
flutter run --release
```

## ✅ Success Indicators

The app is running successfully when you see:
- Onboarding screens appear on first launch
- Camera permission request (grant it!)
- Real-time posture monitoring working
- All navigation tabs functioning

## 📝 Notes

- **Camera on Emulator**: The emulator uses a simulated camera (shows a moving box pattern)
- **For Real Testing**: Use a physical device for actual posture detection
- **Performance**: Release mode (`flutter run --release`) runs much faster

## 🆘 Still Having Issues?

1. Check Flutter installation:
   ```bash
   flutter doctor
   ```

2. Update Flutter:
   ```bash
   flutter upgrade
   ```

3. Accept Android licenses:
   ```bash
   flutter doctor --android-licenses
   ```

---

**Ready to go!** Follow Option 1 for the easiest setup with Android Studio's visual interface.
