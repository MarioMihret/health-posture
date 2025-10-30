# Posture Health Assistant 🧘‍♂️

An AI-powered Flutter mobile application that helps people who sit for long hours improve their posture and wellness. The app uses advanced pose detection AI to monitor posture in real-time through the device camera and provides personalized health insights.

## 🌟 Features

### AI-Powered Posture Detection
- **Real-time Monitoring**: Uses Google ML Kit Pose Detection to analyze posture through your device camera
- **Smart Alerts**: Automatic notifications when poor posture is detected
- **Posture Scoring**: Track your posture quality with a dynamic scoring system
- **Privacy-Focused**: Option to hide camera preview while still monitoring posture

### Exercise & Wellness
- **Personalized Exercises**: Curated stretch routines for different body parts
- **Interactive Timer**: Guided exercise sessions with step-by-step instructions
- **Exercise Tracking**: Monitor completed exercises and maintain streaks
- **Quick Exercises**: 2-minute routines for busy schedules

### Health Monitoring
- **Water Intake Tracking**: Stay hydrated with customizable water goals and reminders
- **Break Reminders**: Regular notifications to take breaks from sitting
- **Health Insights**: Daily analytics and personalized recommendations
- **Progress Charts**: Visualize your posture trends over time

### Modern UI/UX
- **Beautiful Design**: Clean, modern interface with smooth animations
- **Dark Mode**: Full dark mode support for comfortable viewing
- **Customizable**: Personalize goals, reminders, and monitoring settings
- **Responsive**: Adapts to different screen sizes and orientations

## 📱 Screenshots

The app features:
- Onboarding screens to guide new users
- Dashboard with quick stats and actions
- Camera monitoring screen with real-time feedback
- Exercise library with detailed instructions
- Insights dashboard with charts and analytics
- Comprehensive settings for personalization

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extension
- Android device/emulator (API level 21+) or iOS device/simulator (iOS 11+)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/posture-health-assistant.git
cd posture-health-assistant
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

### Platform-Specific Setup

#### Android
The app requires camera permissions. These are automatically requested when needed. Minimum SDK version is 21.

#### iOS
Add the following to your `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required to monitor your posture</string>
```

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── theme/                    # App theming and colors
├── models/                   # Data models
│   ├── posture_data.dart
│   ├── health_data.dart
│   └── exercise.dart
├── providers/               # State management (Provider)
│   ├── posture_provider.dart
│   ├── health_provider.dart
│   └── settings_provider.dart
├── services/                # Business logic and services
│   ├── pose_detection_service.dart
│   └── notification_service.dart
├── screens/                 # App screens
│   ├── onboarding/
│   ├── home/
│   ├── camera/
│   ├── exercises/
│   ├── insights/
│   └── settings/
└── widgets/                 # Reusable UI components
```

### Key Technologies
- **Flutter**: Cross-platform mobile framework
- **Provider**: State management solution
- **Google ML Kit**: Pose detection for posture analysis
- **Camera Plugin**: Real-time camera feed processing
- **FL Chart**: Beautiful data visualization
- **Local Notifications**: Reminders and alerts

## 🎯 Features in Detail

### Posture Detection Algorithm
The app analyzes key body landmarks to determine posture quality:
- **Shoulder Alignment**: Checks if shoulders are level
- **Neck Position**: Detects forward head posture
- **Back Angle**: Identifies slouching or hunching
- **Posture Score**: Combines metrics into a 0-100 score

### Exercise System
- **7 Categories**: Neck, Shoulder, Back, Eyes, Wrist, Legs, Full Body
- **3 Difficulty Levels**: Easy, Medium, Hard
- **Duration Tracking**: 1-3 minute exercises
- **Calorie Estimation**: Track calories burned
- **Progress Tracking**: Monitor completion and streaks

### Health Insights
- **Daily Stats**: Water intake, exercises, breaks, posture score
- **Trend Analysis**: Visualize improvements over time
- **Smart Recommendations**: AI-generated tips based on your data
- **Goal Setting**: Customize daily health targets

## 🔧 Configuration

### Settings Options
- **Appearance**: Light/Dark/System theme
- **Notifications**: Toggle alerts for posture, water, breaks, exercises
- **Monitoring**: Camera selection, preview visibility, check frequency
- **Goals**: Daily targets for water, breaks, and exercises
- **Sound & Haptics**: Audio and vibration feedback

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Google ML Kit for pose detection capabilities
- Flutter team for the amazing framework
- All contributors and users of this app

## 📞 Support

For issues, questions, or suggestions, please:
- Open an issue on GitHub
- Contact support through the app settings
- Check our documentation

## 🚦 Roadmap

- [ ] Cloud sync for data backup
- [ ] Social features for motivation
- [ ] More exercise animations
- [ ] Wearable device integration
- [ ] Desktop companion app
- [ ] AI-powered personalized recommendations
- [ ] Gamification features
- [ ] Multi-language support

---

**Stay Healthy, Sit Better! 🪑✨**
