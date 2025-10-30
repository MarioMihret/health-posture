import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'providers/posture_provider.dart';
import 'providers/health_provider.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Skip notification service for web
  if (!kIsWeb) {
    // Notification service would be initialized here for mobile
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
