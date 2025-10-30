// Complete Camera Monitoring Screen for Web
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/posture_provider.dart';
import '../../models/posture_data.dart';
import '../../theme/app_theme.dart';
import 'dart:async';

class CameraMonitoringScreen extends StatefulWidget {
  const CameraMonitoringScreen({super.key});

  @override
  State<CameraMonitoringScreen> createState() => _CameraMonitoringScreenState();
}

class _CameraMonitoringScreenState extends State<CameraMonitoringScreen>
    with SingleTickerProviderStateMixin {
  bool _isMonitoringActive = false;
  int _goodPostureCount = 0;
  int _badPostureCount = 0;
  DateTime? _sessionStartTime;
  Timer? _simulationTimer;
  PostureStatus _currentStatus = PostureStatus.unknown;
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
  
  void _toggleMonitoring() {
    setState(() {
      _isMonitoringActive = !_isMonitoringActive;
      if (_isMonitoringActive) {
        _sessionStartTime = DateTime.now();
        _startSimulation();
      } else {
        _simulationTimer?.cancel();
      }
    });
  }
  
  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final random = DateTime.now().second % 3;
      setState(() {
        if (random == 0) {
          _currentStatus = PostureStatus.good;
          _goodPostureCount++;
        } else if (random == 1) {
          _currentStatus = PostureStatus.moderate;
        } else {
          _currentStatus = PostureStatus.bad;
          _badPostureCount++;
        }
      });
      context.read<PostureProvider>().updatePostureStatus(_currentStatus);
    });
  }
  
  String _getSessionDuration() {
    if (_sessionStartTime == null) return '00:00';
    final duration = DateTime.now().difference(_sessionStartTime!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final postureProvider = context.watch<PostureProvider>();
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDarkMode),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildMonitorDisplay(isDarkMode),
                    const SizedBox(height: 20),
                    _buildMetricsGrid(postureProvider, isDarkMode),
                    const SizedBox(height: 20),
                    _buildPostureFeedback(isDarkMode),
                    const SizedBox(height: 20),
                    _buildSessionStats(isDarkMode),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildControlPanel(isDarkMode),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Posture Monitor',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _isMonitoringActive ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isMonitoringActive ? 'Active Monitoring' : 'Inactive',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }
  
  Widget _buildMonitorDisplay(bool isDarkMode) {
    final color = _getStatusColor(_currentStatus);
    
    return Container(
      height: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDarkMode ? Colors.grey[900]! : Colors.white,
            isDarkMode ? const Color(0xFF1A1A1A) : Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              _getStatusIcon(_currentStatus),
              size: 48,
              color: color,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _getStatusText(_currentStatus),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getFeedbackMessage(_currentStatus),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.95, 0.95));
  }
  
  Widget _buildMetricsGrid(PostureProvider provider, bool isDarkMode) {
    final metrics = [
      {
        'label': 'Current Score',
        'value': '${provider.postureScore.toInt()}%',
        'icon': Icons.speed,
        'color': _getScoreColor(provider.postureScore),
      },
      {
        'label': 'Session Time',
        'value': _getSessionDuration(),
        'icon': Icons.timer_outlined,
        'color': Colors.blue,
      },
      {
        'label': 'Good Posture',
        'value': '$_goodPostureCount',
        'icon': Icons.thumb_up_outlined,
        'color': Colors.green,
      },
      {
        'label': 'Corrections',
        'value': '$_badPostureCount',
        'icon': Icons.warning_amber_outlined,
        'color': Colors.orange,
      },
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    metric['icon'] as IconData,
                    size: 18,
                    color: (metric['color'] as Color).withOpacity(0.7),
                  ),
                  Text(
                    metric['value'] as String,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              Text(
                metric['label'] as String,
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    ).animate().fadeIn(delay: 200.ms);
  }
  
  Widget _buildPostureFeedback(bool isDarkMode) {
    final color = _getStatusColor(_currentStatus);
    final icon = _getStatusIcon(_currentStatus);
    final message = _getDetailedFeedback(_currentStatus);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Real-time Feedback',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
  
  Widget _buildSessionStats(bool isDarkMode) {
    final accuracy = _goodPostureCount + _badPostureCount > 0
        ? (_goodPostureCount / (_goodPostureCount + _badPostureCount) * 100).toInt()
        : 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[850]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$accuracy%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _getScoreColor(accuracy.toDouble()),
                      ),
                    ),
                    Text(
                      'Accuracy',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${(_goodPostureCount + _badPostureCount)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      'Total Checks',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
  
  Widget _buildControlPanel(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _toggleMonitoring,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isMonitoringActive
              ? Colors.red.withOpacity(0.1)
              : AppTheme.primaryColor,
          foregroundColor: _isMonitoringActive
              ? Colors.red
              : Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: _isMonitoringActive
                ? BorderSide(color: Colors.red.withOpacity(0.3))
                : BorderSide.none,
          ),
          elevation: 0,
        ),
        child: Text(
          _isMonitoringActive ? 'Stop Monitoring' : 'Start Monitoring',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }
  
  // Helper methods
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
        return 'EXCELLENT POSTURE';
      case PostureStatus.moderate:
        return 'MODERATE POSTURE';
      case PostureStatus.bad:
        return 'POOR POSTURE';
      default:
        return 'ANALYZING...';
    }
  }
  
  IconData _getStatusIcon(PostureStatus status) {
    switch (status) {
      case PostureStatus.good:
        return Icons.check_circle_outline;
      case PostureStatus.moderate:
        return Icons.info_outline;
      case PostureStatus.bad:
        return Icons.warning_amber_rounded;
      default:
        return Icons.remove_red_eye_outlined;
    }
  }
  
  String _getFeedbackMessage(PostureStatus status) {
    switch (status) {
      case PostureStatus.good:
        return 'Keep up the great work!';
      case PostureStatus.moderate:
        return 'Minor adjustments needed';
      case PostureStatus.bad:
        return 'Please adjust your posture';
      default:
        return 'Monitoring your posture...';
    }
  }
  
  String _getDetailedFeedback(PostureStatus status) {
    switch (status) {
      case PostureStatus.good:
        return 'Your posture is excellent. Keep maintaining this position.';
      case PostureStatus.moderate:
        return 'Small adjustments needed. Check your shoulder alignment.';
      case PostureStatus.bad:
        return 'Time to sit up straight! Align your spine properly.';
      default:
        return 'Analyzing your posture patterns...';
    }
  }
  
  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
