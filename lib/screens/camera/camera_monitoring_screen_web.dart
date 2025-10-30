import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/posture_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/posture_data.dart';
import '../../theme/app_theme.dart';

// Web version of Camera Monitoring Screen
// Camera functionality is not available on web
class CameraMonitoringScreen extends StatefulWidget {
  const CameraMonitoringScreen({super.key});

  @override
  State<CameraMonitoringScreen> createState() => _CameraMonitoringScreenState();
}

class _CameraMonitoringScreenState extends State<CameraMonitoringScreen> {
  @override
  void initState() {
    super.initState();
    // Start simulated monitoring for web demo
    _startSimulatedMonitoring();
  }
  
  void _startSimulatedMonitoring() {
    final postureProvider = context.read<PostureProvider>();
    postureProvider.startMonitoring();
    
    // Simulate posture detection for demo
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        postureProvider.updatePostureStatus(PostureStatus.good);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final postureProvider = context.watch<PostureProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posture Monitoring'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [AppTheme.darkBackground, const Color(0xFF1E293B)]
                : [AppTheme.lightBackground, Colors.white],
          ),
        ),
        child: _buildWebView(postureProvider),
      ),
    );
  }
  
  Widget _buildWebView(PostureProvider postureProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Web platform notice
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.warningColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.web,
                    size: 48,
                    color: AppTheme.warningColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Web Demo Mode',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Camera-based posture monitoring is only available on mobile devices.\nDownload the mobile app for full functionality.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1, 1),
                ),
            
            const SizedBox(height: 32),
            
            // Simulated posture status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Simulated Posture Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: PostureData.getStatusColor(
                            postureProvider.currentPosture,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              PostureData.getStatusIcon(
                                postureProvider.currentPosture,
                              ),
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              postureProvider.currentPosture.name.toUpperCase(),
                              style: TextStyle(
                                color: PostureData.getStatusColor(
                                  postureProvider.currentPosture,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Score: ${postureProvider.postureScore.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
            
            const SizedBox(height: 32),
            
            // Demo controls
            ElevatedButton.icon(
              onPressed: () {
                // Simulate different posture states
                final states = [
                  PostureStatus.good,
                  PostureStatus.moderate,
                  PostureStatus.bad,
                ];
                final currentIndex = states.indexOf(postureProvider.currentPosture);
                final nextIndex = (currentIndex + 1) % states.length;
                postureProvider.updatePostureStatus(states[nextIndex]);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Simulate Posture Change'),
            ).animate().fadeIn(delay: 300.ms),
            
            const SizedBox(height: 16),
            
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Dashboard'),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }
}
