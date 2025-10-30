import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'providers/posture_provider.dart';
import 'providers/health_provider.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';
// Conditionally import notification service
// import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services (skip for web)
  if (!kIsWeb) {
    // await NotificationService().initialize();
    
    // Lock orientation to portrait (mobile only)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  
  // Check if user has completed onboarding
  final prefs = await SharedPreferences.getInstance();
  final hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;
  
  runApp(PostureHealthApp(hasCompletedOnboarding: hasCompletedOnboarding));
}

class PostureHealthApp extends StatelessWidget {
  final bool hasCompletedOnboarding;
  
  const PostureHealthApp({
    super.key,
    required this.hasCompletedOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PostureProvider()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            title: 'Posture Health Assistant',
            debugShowCheckedModeBanner: false,
            themeMode: settingsProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: hasCompletedOnboarding 
                ? const HomeScreen()
                : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
