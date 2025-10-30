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
import '../../widgets/stats_card.dart';
import '../../widgets/quick_action_card.dart';
import '../../widgets/posture_status_card.dart';
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
  void initState() {
    super.initState();
    // Initialize health monitoring
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().initialize();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            HapticFeedback.lightImpact();
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: isDarkMode 
              ? AppTheme.darkSurface 
              : AppTheme.lightSurface,
          indicatorColor: Theme.of(context).primaryColor.withOpacity(0.2),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
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
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final postureProvider = context.watch<PostureProvider>();
    final healthProvider = context.watch<HealthProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      color: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      child: SafeArea(
        child: Column(
          children: [
            // Minimal Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your wellness journey',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                      score: postureProvider.postureScore,
                      isMonitoring: postureProvider.isMonitoring,
                      onStartMonitoring: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CameraMonitoringScreen(),
                          ),
                        );
                      },
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 20),
                    
                    // Quick Stats
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Posture Score',
                            value: '${postureProvider.postureScore.toStringAsFixed(0)}%',
                            icon: Icons.trending_up,
                            color: AppTheme.primaryColor,
                            progress: postureProvider.postureScore / 100,
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            title: 'Water Intake',
                            value: '${healthProvider.waterIntake}ml',
                            icon: Icons.water_drop,
                            color: AppTheme.secondaryColor,
                            progress: healthProvider.waterProgress,
                          ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2, end: 0),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Exercises',
                            value: '${healthProvider.exercisesCompleted}',
                            icon: Icons.fitness_center,
                            color: AppTheme.successColor,
                            progress: healthProvider.exercisesCompleted / 5,
                          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            title: 'Breaks',
                            value: '${healthProvider.breaksTaken}',
                            icon: Icons.pause_circle,
                            color: AppTheme.warningColor,
                            progress: healthProvider.breaksProgress,
                          ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2, end: 0),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                    
                    const SizedBox(height: 12),
                    
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        QuickActionCard(
                          title: 'Start Monitoring',
                          icon: Icons.videocam,
                          color: AppTheme.primaryColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CameraMonitoringScreen(),
                              ),
                            );
                          },
                        ).animate().fadeIn(delay: 450.ms).scale(begin: const Offset(0.9, 0.9)),
                        
                        QuickActionCard(
                          title: 'Quick Stretch',
                          icon: Icons.self_improvement,
                          color: AppTheme.successColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ExercisesScreen(),
                              ),
                            );
                          },
                        ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.9, 0.9)),
                        
                        QuickActionCard(
                          title: 'Add Water',
                          icon: Icons.water_drop,
                          color: AppTheme.secondaryColor,
                          onTap: () {
                            _showWaterIntakeDialog(context);
                          },
                        ).animate().fadeIn(delay: 550.ms).scale(begin: const Offset(0.9, 0.9)),
                        
                        QuickActionCard(
                          title: 'Take Break',
                          icon: Icons.pause_circle,
                          color: AppTheme.warningColor,
                          onTap: () {
                            context.read<HealthProvider>().recordBreak();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Break recorded! Great job taking care of yourself.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Health Insights Preview
                    if (healthProvider.insights.isNotEmpty) ...[
                      Text(
                        'Today\'s Insights',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ).animate().fadeIn(delay: 650.ms),
                      
                      const SizedBox(height: 12),
                      
                      ...healthProvider.insights.take(2).map((insight) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: insight.getColor().withOpacity(0.1),
                              child: Text(
                                insight.icon,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            title: Text(
                              insight.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(insight.description),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const InsightsScreen(),
                                ),
                              );
                            },
                          ),
                        ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.2, end: 0);
                      }),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showWaterIntakeDialog(BuildContext context) {
    final amounts = [250, 500, 750, 1000];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.darkSurface
          : AppTheme.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Water Intake',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2,
                children: amounts.map((amount) {
                  return ElevatedButton(
                    onPressed: () {
                      context.read<HealthProvider>().addWaterIntake(amount);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added ${amount}ml to your water intake'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                    ),
                    child: Text(
                      '${amount}ml',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
