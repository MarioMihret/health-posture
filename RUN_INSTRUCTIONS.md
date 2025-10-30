# 🚀 Quick Start Guide - Posture Health Assistant

## ⚡ Quick Run (Windows)

Simply double-click `run_app.bat` or run:
```bash
cd C:\Users\mf\CascadeProjects\posture-health-assistant
run_app.bat
```

## 📱 Manual Setup & Run

### Step 1: Navigate to Project
```bash
cd C:\Users\mf\CascadeProjects\posture-health-assistant
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Check Connected Devices
```bash
flutter devices
```

### Step 4: Run the App
```bash
flutter run
```

## 🎯 First-Time Setup Checklist

- [ ] Flutter SDK installed (run `flutter doctor`)
- [ ] Android Studio or VS Code with Flutter extension
- [ ] Android emulator or physical device connected
- [ ] USB debugging enabled (for physical devices)

## 🔧 Common Issues & Solutions

### No Devices Found
1. **Android Emulator**: Open Android Studio > AVD Manager > Create/Start an emulator
2. **Physical Device**: Enable Developer Options > USB Debugging

### Build Fails
```bash
flutter clean
flutter pub get
flutter run
```

### Camera Not Working
- **Android**: App will request permission automatically
- **iOS**: Check Info.plist has camera permission
- **Emulator**: Some emulators don't support camera properly

## 📱 Testing on Different Platforms

### Android Device/Emulator
```bash
flutter run
```

### iOS Simulator (Mac only)
```bash
open -a Simulator
flutter run
```

### Web Browser (Preview only - camera features limited)
```bash
flutter run -d chrome
```

## 🎨 Key Features to Try

1. **First Launch**
   - Complete the onboarding flow
   - Grant camera permissions

2. **Dashboard**
   - View posture status card
   - Check health statistics
   - Try quick actions

3. **Posture Monitoring**
   - Tap "Start Monitoring"
   - Position yourself in front of camera
   - Watch real-time posture feedback

4. **Exercises**
   - Browse exercise library
   - Start a guided exercise
   - Track completion

5. **Health Tracking**
   - Add water intake (tap water icon)
   - Record breaks
   - View insights dashboard

6. **Settings**
   - Toggle dark/light theme
   - Configure notifications
   - Set daily goals

## 📊 Performance Tips

### Debug Mode (Default)
- Slower performance but with debugging tools
- Hot reload available (press 'r' in terminal)

### Release Mode (Faster)
```bash
flutter run --release
```

### Profile Mode (Performance Testing)
```bash
flutter run --profile
```

## 🏗️ Building for Distribution

### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (Mac only)
```bash
flutter build ios --release
```

## 📝 Development Commands

### Hot Reload
Press `r` in terminal while app is running

### Hot Restart  
Press `R` in terminal for full restart

### Quit App
Press `q` in terminal

### Take Screenshot
Press `s` in terminal

## 🆘 Need Help?

1. Check Flutter installation:
```bash
flutter doctor -v
```

2. View logs:
```bash
flutter logs
```

3. Clean rebuild:
```bash
flutter clean && flutter pub get && flutter run
```

## 🎉 Success Indicators

You'll know the app is running successfully when you see:
- ✅ Onboarding screens on first launch
- ✅ Dashboard with posture status card
- ✅ Bottom navigation with 4 tabs
- ✅ Smooth animations and transitions
- ✅ Camera preview when monitoring (if permissions granted)

## 💡 Pro Tips

- Use a physical device for best camera experience
- Dark mode looks great - try it in Settings
- The app works offline after initial setup
- Posture monitoring works best with good lighting
- Set up daily reminders for better habit formation

---

**Ready to improve your posture? Let's go! 🚀**

For detailed documentation, see [README.md](README.md)
