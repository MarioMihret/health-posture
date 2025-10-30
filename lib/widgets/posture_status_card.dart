import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../models/posture_data.dart';
import '../theme/app_theme.dart';

class PostureStatusCard extends StatelessWidget {
  final PostureStatus status;
  final double score;
  final bool isMonitoring;
  final VoidCallback onStartMonitoring;
  
  const PostureStatusCard({
    super.key,
    required this.status,
    required this.score,
    required this.isMonitoring,
    required this.onStartMonitoring,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final statusColor = PostureData.getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isMonitoring
              ? [
                  statusColor.withOpacity(0.8),
                  statusColor.withOpacity(0.6),
                ]
              : [
                  AppTheme.primaryColor.withOpacity(0.8),
                  AppTheme.secondaryColor.withOpacity(0.8),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isMonitoring
                ? statusColor.withOpacity(0.3)
                : AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
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
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        PostureData.getStatusIcon(status),
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isMonitoring
                            ? status.name.toUpperCase()
                            : 'NOT MONITORING',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              CircularPercentIndicator(
                radius: 45.0,
                lineWidth: 8.0,
                animation: true,
                percent: score / 100,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${score.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'score',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isMonitoring
                  ? PostureData.getStatusMessage(status)
                  : 'Start monitoring to track your posture',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                onStartMonitoring();
              },
              icon: Icon(
                isMonitoring ? Icons.visibility : Icons.videocam,
                size: 20,
              ),
              label: Text(
                isMonitoring ? 'View Monitoring' : 'Start Monitoring',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: isMonitoring ? statusColor : AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (isMonitoring) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ).animate(
                  onPlay: (controller) => controller.repeat(),
                ).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.5, 1.5),
                  duration: 1.seconds,
                ).then().scale(
                  begin: const Offset(1.5, 1.5),
                  end: const Offset(1, 1),
                  duration: 1.seconds,
                ),
                const SizedBox(width: 8),
                Text(
                  'Actively Monitoring',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
