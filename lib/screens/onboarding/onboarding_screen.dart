import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import '../home/home_screen.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Posture Health',
      description: 'Your AI-powered companion for better posture and wellness. Let\'s improve your health together!',
      icon: Icons.health_and_safety,
      color: AppTheme.primaryColor,
    ),
    OnboardingPage(
      title: 'AI Posture Detection',
      description: 'Using advanced AI and your camera, we\'ll monitor your posture in real-time and alert you when adjustments are needed.',
      icon: Icons.camera_alt,
      color: AppTheme.secondaryColor,
    ),
    OnboardingPage(
      title: 'Personalized Exercises',
      description: 'Get customized stretch routines and exercises designed to improve your posture and reduce strain.',
      icon: Icons.fitness_center,
      color: AppTheme.successColor,
    ),
    OnboardingPage(
      title: 'Health Insights',
      description: 'Track your progress with detailed analytics, water reminders, and daily health insights.',
      icon: Icons.insights,
      color: AppTheme.warningColor,
    ),
  ];
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }
  
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    const Color(0xFF1E293B),
                    const Color(0xFF0F172A),
                  ]
                : [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFE2E8F0),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),
              
              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPageContent(_pages[index], index);
                  },
                ),
              ),
              
              // Page indicators and navigation
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => _buildPageIndicator(index),
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                    
                    const SizedBox(height: 32),
                    
                    // Navigation buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        AnimatedOpacity(
                          opacity: _currentPage > 0 ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: IconButton(
                            onPressed: _currentPage > 0
                                ? () {
                                    _pageController.previousPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.arrow_back),
                            iconSize: 28,
                          ),
                        ),
                        
                        // Next/Get Started button
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: ElevatedButton(
                              onPressed: _currentPage == _pages.length - 1
                                  ? _completeOnboarding
                                  : () {
                                      _pageController.nextPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: _pages[_currentPage].color,
                              ),
                              child: Text(
                                _currentPage == _pages.length - 1
                                    ? 'Get Started'
                                    : 'Next',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ).animate().fadeIn(delay: 500.ms).slideY(
                              begin: 0.2,
                              end: 0,
                              duration: 400.ms,
                              curve: Curves.easeOutBack,
                            ),
                          ),
                        ),
                        
                        // Placeholder for symmetry
                        const SizedBox(width: 48),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPageContent(OnboardingPage page, int index) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon container
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: page.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                page.icon,
                size: 80,
                color: page.color,
              ),
            )
                .animate()
                .fadeIn(delay: (index * 100).ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ),
            
            const SizedBox(height: 48),
            
            // Title
            Text(
              page.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: (index * 100 + 200).ms)
                .slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              page.description,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: (index * 100 + 400).ms)
                .slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPageIndicator(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? _pages[_currentPage].color
            : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  
  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
