# Getting Started with Posture Health Assistant

Welcome to the Posture Health Assistant Flutter project! This guide will help you set up and run the app on your local machine.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (3.0.0 or higher)
   - Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
   - Add Flutter to your PATH

2. **Development Tools**
   - Android Studio or VS Code with Flutter extensions
   - Xcode (for iOS development on macOS)

3. **Device/Emulator**
   - Physical device with USB debugging enabled, OR
   - Android emulator (API level 21+), OR
   - iOS simulator (iOS 11+)

## Installation Steps

### 1. Clone the Repository
```bash
cd C:\Users\mf\CascadeProjects\posture-health-assistant
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Download Fonts
Download the Poppins font family from [Google Fonts](https://fonts.google.com/specimen/Poppins) and add these files to `assets/fonts/`:
- Poppins-Regular.ttf
- Poppins-Medium.ttf
- Poppins-SemiBold.ttf
- Poppins-Bold.ttf

### 4. Platform-Specific Setup

#### For Android:
No additional setup required. The app will request camera permissions at runtime.

#### For iOS:
1. Navigate to `ios/` directory
2. Run `pod install`
3. Open `ios/Runner/Info.plist` and ensure camera permission is added:
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required to monitor your posture</string>
```

### 5. Run the App

#### Check Connected Devices
```bash
flutter devices
```

#### Run on Connected Device
```bash
flutter run
```

#### Run with Specific Device
```bash
flutter run -d <device_id>
```

## Common Commands

### Clean Build
```bash
flutter clean
flutter pub get
flutter run
```

### Build APK (Android)
```bash
flutter build apk --release
```

### Build iOS
```bash
flutter build ios --release
```

### Run Tests
```bash
flutter test
```

### Analyze Code
```bash
flutter analyze
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── theme/                    # App theming
├── models/                   # Data models
├── providers/               # State management
├── services/                # Business logic
├── screens/                 # UI screens
└── widgets/                 # Reusable components
```

## Features to Test

1. **Onboarding Flow**
   - Launch app for first time
   - Navigate through onboarding screens

2. **Posture Monitoring**
   - Grant camera permission
   - Start posture monitoring
   - Test posture detection feedback

3. **Exercises**
   - Browse exercise library
   - Start an exercise session
   - Complete exercises

4. **Health Tracking**
   - Add water intake
   - Record breaks
   - View insights dashboard

5. **Settings**
   - Toggle dark/light mode
   - Configure notifications
   - Set daily goals

## Troubleshooting

### Flutter Doctor Issues
```bash
flutter doctor -v
```

### Clean Rebuild
```bash
flutter clean
rm -rf pubspec.lock
flutter pub get
flutter run
```

### iOS Pod Issues
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

### Android Build Issues
```bash
cd android
./gradlew clean
cd ..
flutter run
```

## Development Tips

1. **Hot Reload**: Press `r` in terminal while app is running
2. **Hot Restart**: Press `R` in terminal for full restart
3. **Debug Mode**: App runs in debug mode by default with `flutter run`
4. **Performance Mode**: Use `flutter run --profile` for performance testing

## Next Steps

1. Customize the app theme in `lib/theme/app_theme.dart`
2. Add more exercises in `lib/models/exercise.dart`
3. Enhance pose detection in `lib/services/pose_detection_service.dart`
4. Add new features by creating new screens and providers

## Support

If you encounter any issues:
1. Check the [README.md](README.md) for more information
2. Ensure all prerequisites are correctly installed
3. Run `flutter doctor` to diagnose issues
4. Check Flutter logs with `flutter logs`

Happy coding! 🚀
