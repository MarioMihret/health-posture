import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../camera/camera_monitoring_screen_export.dart';
import '../exercises/exercises_screen.dart';
import '../insights/insights_screen.dart';
import '../settings/settings_screen.dart';
import '../ai_coach/ai_coach_screen.dart';
import '../../providers/posture_provider.dart';
import '../../providers/health_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/posture_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _pages = [
    const DashboardPage(),
    const CameraMonitoringScreen(),
    const ExercisesScreen(),
    const InsightsScreen(),
  ];
  
  @override
  void initState() {
    super.initState();
    // Ensure providers are initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().ensureInitialized();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AICoachScreen()),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.psychology, color: Colors.white),
        tooltip: 'AI Coach',
      ).animate()
        .fadeIn(delay: 500.ms)
        .scale(begin: const Offset(0, 0), end: const Offset(1, 1)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        elevation: 0,
        backgroundColor: isDarkMode ? const Color(0xFF0A0A0A) : Colors.white,
        indicatorColor: AppTheme.primaryColor.withOpacity(0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.videocam_outlined),
            selectedIcon: Icon(Icons.videocam),
            label: 'Monitor',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Exercises',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
        ],
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  
  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
  
  String _getAvatarEmoji(HealthProvider provider) {
    // Dynamic avatar based on current state
    if (provider.exerciseStreak > 7) return '🌟';
    if (provider.exercisesCompleted >= 3) return '💪';
    if (provider.waterIntake >= 2000) return '💧';
    if (provider.exercisesCompleted > 0) return '😊';
    return '🧘';
  }
  
  String _getPersonalizedGreeting(HealthProvider provider) {
    // Personalized greeting based on progress
    if (provider.exerciseStreak > 7) {
      return 'Champion Mode! 🏆';
    } else if (provider.exercisesCompleted >= 3) {
      return 'Great Progress! 💪';
    } else if (provider.exercisesCompleted > 0) {
      return 'Keep Going! 🎯';
    } else if (DateTime.now().hour < 12) {
      return 'Start Strong Today';
    } else {
      return 'Time to Move';
    }
  }
  
  List<Color> _getCardGradientColors(double score, bool isDarkMode) {
    if (score >= 80) {
      return isDarkMode
        ? [const Color(0xFF065F46), const Color(0xFF047857)]
        : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)];
    } else if (score >= 50) {
      return isDarkMode
        ? [const Color(0xFF7C2D12), const Color(0xFF9A3412)]
        : [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)];
    } else {
      return isDarkMode
        ? [const Color(0xFF7F1D1D), const Color(0xFF991B1B)]
        : [const Color(0xFFFEE2E2), const Color(0xFFFECACA)];
    }
  }
  
  Color _getPostureColor(PostureStatus status) {
    switch (status) {
      case PostureStatus.good:
        return Colors.green;
      case PostureStatus.moderate:
        return Colors.orange;
      case PostureStatus.bad:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final postureProvider = context.watch<PostureProvider>();
    final healthProvider = context.watch<HealthProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Show loading indicator if data is not initialized
    if (!healthProvider.isInitialized) {
      return Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading your data...',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Header Section
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDarkMode
                      ? [const Color(0xFF0F0F0F), const Color(0xFF0A0A0A)]
                      : [Colors.white, const Color(0xFFFAFAFA)],
                  ),
                ),
                child: Column(
                  children: [
                    // Top Bar with Avatar and Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // User Avatar and Welcome
                        Row(
                          children: [
                            // Animated Avatar
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryColor.withOpacity(0.8),
                                    AppTheme.primaryColor,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _getAvatarEmoji(healthProvider),
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ).animate()
                              .scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.easeOutBack)
                              .fadeIn(duration: 400.ms),
                            
                            const SizedBox(width: 16),
                            
                            // Greeting Text
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Good ${_getTimeOfDay()}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    // Animated wave
                                    Text('👋', style: const TextStyle(fontSize: 14))
                                      .animate(onPlay: (controller) => controller.repeat())
                                      .rotate(begin: -0.1, end: 0.1, duration: 800.ms)
                                      .then(delay: 100.ms)
                                      .rotate(begin: 0.1, end: -0.1, duration: 800.ms),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getPersonalizedGreeting(healthProvider),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        // Action Buttons
                        Row(
                          children: [
                            // Notification Button
                            Container(
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.grey[900] : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      // Show notifications
                                    },
                                    icon: Icon(
                                      Icons.notifications_outlined,
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                                      size: 20,
                                    ),
                                  ),
                                  // Notification Dot
                                  if (healthProvider.exercisesCompleted == 0)
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ).animate(onPlay: (controller) => controller.repeat())
                                        .scale(
                                          begin: const Offset(1, 1),
                                          end: const Offset(1.2, 1.2),
                                          duration: 1000.ms,
                                        ).then()
                                        .scale(
                                          begin: const Offset(1.2, 1.2),
                                          end: const Offset(1, 1),
                                          duration: 1000.ms,
                                        ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Settings Button
                            _buildSettingsButton(context, isDarkMode),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Streak Banner
                    if (healthProvider.exerciseStreak > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.withOpacity(0.1),
                              Colors.deepOrange.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_fire_department, 
                              color: Colors.orange, 
                              size: 20
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${healthProvider.exerciseStreak} day streak!',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[700],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Keep it up!',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[600],
                              ),
                            ),
                          ],
                        ),
                      ).animate()
                        .fadeIn(delay: 300.ms)
                        .slideX(begin: -0.2, end: 0),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.1, end: 0),
              
              // Main Posture Card - Hero Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: _buildHeroPostureCard(postureProvider, isDarkMode),
              ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.95, 0.95)),
              
              // Today's Progress Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildProgressCards(healthProvider, isDarkMode),
                  ],
                ),
              ),
              
              // Quick Actions Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActions(context, isDarkMode),
                  ],
                ),
              ),
              
              // Health Tips Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: _buildHealthTip(isDarkMode),
              ).animate().fadeIn(delay: 500.ms),
              
              // Wellness Insights Section with Orange/Black Theme
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Wellness Insights',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                            letterSpacing: 0.3,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.orange.shade600, Colors.orange.shade800],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInsightCards(healthProvider, postureProvider, isDarkMode),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
              
              // Visual Achievement Gallery
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Journey',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildJourneyCards(healthProvider, isDarkMode),
                  ],
                ),
              ).animate().fadeIn(delay: 700.ms).scale(begin: const Offset(0.95, 0.95)),
              
              // Posture Trends Visualization
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: _buildTrendsSection(postureProvider, isDarkMode),
              ).animate().fadeIn(delay: 800.ms),
              
              // Motivational Quote Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                child: _buildMotivationalSection(healthProvider, isDarkMode),
              ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSettingsButton(BuildContext context, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        },
        icon: Icon(
          Icons.settings_outlined,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
          size: 20,
        ),
      ),
    );
  }
  
  Widget _buildHeroPostureCard(PostureProvider provider, bool isDarkMode) {
    final status = provider.currentPosture;
    final score = provider.postureScore;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getCardGradientColors(score, isDarkMode),
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _getPostureColor(status).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated Background Pattern
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getPostureColor(status).withOpacity(0.1),
              ),
            ).animate(onPlay: (controller) => controller.repeat())
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.2, 1.2),
                duration: 3000.ms,
              ).then()
              .scale(
                begin: const Offset(1.2, 1.2),
                end: const Offset(1, 1),
                duration: 3000.ms,
              ),
          ),
          
          // Main Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(
                            'Posture Status',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getStatusText(status),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    _buildScoreIndicator(score, isDarkMode),
                  ],
                ),
                const SizedBox(height: 20),
                _buildMonitorButton(provider.isMonitoring, isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildScoreIndicator(double score, bool isDarkMode) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 6,
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              score >= 80 ? Colors.green : score >= 50 ? Colors.orange : Colors.red,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${score.toInt()}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            Text(
              'Score',
              style: TextStyle(
                fontSize: 10,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildMonitorButton(bool isMonitoring, bool isDarkMode) {
    return ElevatedButton(
      onPressed: () {
        // Navigate to camera monitoring
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Text(
        isMonitoring ? 'Monitoring Active' : 'Start Monitoring',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildProgressCards(HealthProvider provider, bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _buildProgressCard(
            icon: Icons.water_drop_outlined,
            value: '${provider.waterIntake}',
            label: 'ml water',
            progress: provider.waterProgress,
            isDarkMode: isDarkMode,
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildProgressCard(
            icon: Icons.fitness_center,
            value: '${provider.exercisesCompleted}',
            label: 'exercises',
            progress: provider.exercisesCompleted / 5,
            isDarkMode: isDarkMode,
          ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.1, end: 0),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildProgressCard(
            icon: Icons.timer_outlined,
            value: '${provider.breaksTaken}',
            label: 'breaks',
            progress: provider.breaksProgress,
            isDarkMode: isDarkMode,
          ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
        ),
      ],
    );
  }
  
  Widget _buildProgressCard({
    required IconData icon,
    required String value,
    required String label,
    required double progress,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 3,
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActions(BuildContext context, bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context: context,
            icon: Icons.self_improvement,
            label: 'Stretch',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ExercisesScreen()),
            ),
            isDarkMode: isDarkMode,
          ).animate().fadeIn(delay: 350.ms).scale(begin: const Offset(0.9, 0.9)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            context: context,
            icon: Icons.water_drop,
            label: 'Add Water',
            onTap: () => _showWaterIntakeDialog(context),
            isDarkMode: isDarkMode,
          ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            context: context,
            icon: Icons.insights,
            label: 'View Stats',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InsightsScreen()),
            ),
            isDarkMode: isDarkMode,
          ).animate().fadeIn(delay: 450.ms).scale(begin: const Offset(0.9, 0.9)),
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getStatusColor(PostureStatus status) {
    switch (status) {
      case PostureStatus.good:
        return Colors.green;
      case PostureStatus.moderate:
        return Colors.orange;
      case PostureStatus.bad:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  String _getStatusText(PostureStatus status) {
    switch (status) {
      case PostureStatus.good:
        return 'Excellent';
      case PostureStatus.moderate:
        return 'Fair';
      case PostureStatus.bad:
        return 'Needs Attention';
      default:
        return 'Not Monitoring';
    }
  }
  
  void _showWaterIntakeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Water Intake'),
        content: const Text('Add 250ml to your daily water intake?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<HealthProvider>().addWaterIntake(250);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Water intake updated!')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHealthTip(bool isDarkMode) {
    final tips = [
      'Take a 5-minute break every hour to stretch',
      'Keep your screen at eye level to reduce neck strain',
      'Drink water regularly to stay hydrated',
      'Roll your shoulders back to relieve tension',
      'Adjust your chair height for proper posture',
    ];
    
    final randomTip = tips[DateTime.now().minute % tips.length];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip of the day',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  randomTip,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInsightCards(HealthProvider healthProvider, PostureProvider postureProvider, bool isDarkMode) {
    return Container(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Posture Score Card with Gradient
          Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.shade400,
                  Colors.deepOrange.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${postureProvider.postureScore.toInt()}%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Posture Score',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate()
            .fadeIn(delay: 100.ms)
            .slideX(begin: 0.2, end: 0),
          
          // Daily Goal Card - Black Theme
          Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                  ? [const Color(0xFF1A1A1A), const Color(0xFF2D2D2D)]
                  : [Colors.grey.shade800, Colors.black87],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.flag,
                      color: Colors.orange,
                      size: 28,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(healthProvider.exercisesCompleted / 5 * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Daily Goal',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate()
            .fadeIn(delay: 200.ms)
            .slideX(begin: 0.2, end: 0),
          
          // Wellness Tips Card
          Container(
            width: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.shade400,
                  Colors.purple.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.spa,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wellness',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Stay healthy',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate()
            .fadeIn(delay: 300.ms)
            .slideX(begin: 0.2, end: 0),
        ],
      ),
    );
  }
  
  Widget _buildJourneyCards(HealthProvider provider, bool isDarkMode) {
    final achievements = [
      {'icon': Icons.emoji_events, 'title': 'First Steps', 'desc': 'Started journey', 'color': Colors.amber},
      {'icon': Icons.local_fire_department, 'title': '${provider.exerciseStreak} Day Streak', 'desc': 'Keep going!', 'color': Colors.orange},
      {'icon': Icons.water_drop, 'title': '${provider.waterIntake}ml', 'desc': 'Hydration today', 'color': Colors.blue},
      {'icon': Icons.check_circle, 'title': '${provider.exercisesCompleted} Done', 'desc': 'Exercises today', 'color': Colors.green},
    ];
    
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return Container(
            width: 140,
            margin: EdgeInsets.only(right: index < achievements.length - 1 ? 12 : 0),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (achievement['color'] as Color).withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (achievement['color'] as Color).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (achievement['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      achievement['icon'] as IconData,
                      color: achievement['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement['title'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    achievement['desc'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ).animate()
            .fadeIn(delay: Duration(milliseconds: 100 * index))
            .scale(begin: const Offset(0.8, 0.8));
        },
      ),
    );
  }
  
  Widget _buildTrendsSection(PostureProvider provider, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
            ? [Colors.orange.shade900.withOpacity(0.2), Colors.black.withOpacity(0.3)]
            : [Colors.orange.shade50, Colors.orange.shade100],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orange.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Trend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              Icon(
                provider.postureScore > 70 ? Icons.trending_up : Icons.trending_down,
                color: provider.postureScore > 70 ? Colors.green : Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Mini bar chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final heights = [0.4, 0.6, 0.5, 0.7, 0.8, 0.6, 0.9];
              final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              return Column(
                children: [
                  Container(
                    width: 30,
                    height: 60 * heights[index],
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: index == 6
                          ? [Colors.orange, Colors.deepOrange]
                          : [Colors.grey.shade400, Colors.grey.shade600],
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ).animate()
                    .scaleY(
                      begin: 0,
                      end: 1,
                      delay: Duration(milliseconds: 50 * index),
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMotivationalSection(HealthProvider provider, bool isDarkMode) {
    final quotes = [
      {'quote': 'Your posture is the foundation of every movement', 'author': 'Health Expert'},
      {'quote': 'Stand tall, feel powerful', 'author': 'Motivation Daily'},
      {'quote': 'Good posture is a sign of confidence', 'author': 'Wellness Coach'},
    ];
    
    final randomQuote = quotes[DateTime.now().second % quotes.length];
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black87,
            Colors.orange.shade900,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.format_quote,
                  color: Colors.orange,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  randomQuote['quote']!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '— ${randomQuote['author']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange.shade300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
