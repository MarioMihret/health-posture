import 'package:flutter/material.dart';
enum InsightType {
  success,
  warning,
  info,
  error,
}

class HealthInsight {
  final String title;
  final String description;
  final InsightType type;
  final String icon;
  final DateTime timestamp;
  final String? actionText;
  final VoidCallback? action;
  
  HealthInsight({
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
    DateTime? timestamp,
    this.actionText,
    this.action,
  }) : timestamp = timestamp ?? DateTime.now();
  
  // Get insight color
  Color getColor() {
    switch (type) {
      case InsightType.success:
        return const Color(0xFF10B981);
      case InsightType.warning:
        return const Color(0xFFF59E0B);
      case InsightType.info:
        return const Color(0xFF3B82F6);
      case InsightType.error:
        return const Color(0xFFEF4444);
    }
  }
  
  // Get insight icon color
  Color getIconColor() {
    return getColor().withOpacity(0.8);
  }
}

class DailyHealthStats {
  final DateTime date;
  final int waterIntake;
  final int exercisesCompleted;
  final int breaksTaken;
  final double postureScore;
  final Duration totalSittingTime;
  final Duration goodPostureTime;
  final int stepCount;
  
  DailyHealthStats({
    required this.date,
    required this.waterIntake,
    required this.exercisesCompleted,
    required this.breaksTaken,
    required this.postureScore,
    required this.totalSittingTime,
    required this.goodPostureTime,
    this.stepCount = 0,
  });
  
  // Calculate overall health score for the day
  double get overallScore {
    double score = 0;
    
    // Water intake (25%)
    final waterScore = (waterIntake / 2000).clamp(0.0, 1.0) * 25;
    score += waterScore;
    
    // Exercises (25%)
    final exerciseScore = (exercisesCompleted / 5).clamp(0.0, 1.0) * 25;
    score += exerciseScore;
    
    // Breaks (20%)
    final breaksScore = (breaksTaken / 8).clamp(0.0, 1.0) * 20;
    score += breaksScore;
    
    // Posture (30%)
    score += (postureScore / 100) * 30;
    
    return score.clamp(0.0, 100.0);
  }
  
  // Get posture percentage
  double get posturePercentage {
    if (totalSittingTime.inSeconds == 0) return 100.0;
    return (goodPostureTime.inSeconds / totalSittingTime.inSeconds) * 100;
  }
}

class WaterIntakeRecord {
  final DateTime timestamp;
  final int amount; // in ml
  final String? note;
  
  WaterIntakeRecord({
    required this.timestamp,
    required this.amount,
    this.note,
  });
}
