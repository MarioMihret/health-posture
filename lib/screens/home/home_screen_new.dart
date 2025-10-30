import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../camera/camera_monitoring_screen_export.dart';
import '../exercises/exercises_screen.dart';
import '../insights/insights_screen.dart';
import '../settings/settings_screen.dart';
import '../../providers/posture_provider.dart';
import '../../providers/health_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';

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
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
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

  @override
  Widget build(BuildContext context) {
    final postureProvider = context.watch<PostureProvider>();
    final healthProvider = context.watch<HealthProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Minimal Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good ${_getTimeOfDay()}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your wellness today',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    _buildSettingsButton(context, isDarkMode),
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
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: _buildHealthTip(isDarkMode),
              ).animate().fadeIn(delay: 500.ms),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0xFF1E293B), const Color(0xFF334155)]
              : [Colors.white, const Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
  
  Widget _buildHealthTip(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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
                  'Take a 5-minute break every hour to stretch and move around.',
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
        return 'Good Posture';
      case PostureStatus.moderate:
        return 'Needs Attention';
      case PostureStatus.bad:
        return 'Poor Posture';
      default:
        return 'Not Monitoring';
    }
  }
  
  void _showWaterIntakeDialog(BuildContext context) {
    final healthProvider = context.read<HealthProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Water Intake'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select amount:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [250, 500, 750, 1000].map((amount) {
                return ElevatedButton(
                  onPressed: () {
                    healthProvider.addWater(amount);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${amount}ml of water'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text('${amount}ml'),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// Import statements for PostureStatus
import '../../models/posture_data.dart';
