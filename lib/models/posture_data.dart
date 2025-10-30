import 'package:flutter/material.dart';

enum PostureStatus {
  good,
  moderate,
  bad,
  unknown,
}

class PostureData {
  final DateTime timestamp;
  final PostureStatus status;
  final double score;
  final Map<String, double>? keypoints; // Optional pose keypoints
  final String? feedback;
  
  PostureData({
    required this.timestamp,
    required this.status,
    required this.score,
    this.keypoints,
    this.feedback,
  });
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString().split('.').last,
      'score': score,
      'keypoints': keypoints,
      'feedback': feedback,
    };
  }
  
  // Create from JSON
  factory PostureData.fromJson(Map<String, dynamic> json) {
    return PostureData(
      timestamp: DateTime.parse(json['timestamp']),
      status: PostureStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      score: json['score'].toDouble(),
      keypoints: json['keypoints'] != null
          ? Map<String, double>.from(json['keypoints'])
          : null,
      feedback: json['feedback'],
    );
  }
  
  // Get status color
  static getStatusColor(PostureStatus status) {
    switch (status) {
      case PostureStatus.good:
        return const Color(0xFF10B981);
      case PostureStatus.moderate:
        return const Color(0xFFF59E0B);
      case PostureStatus.bad:
        return const Color(0xFFEF4444);
      case PostureStatus.unknown:
        return const Color(0xFF6B7280);
    }
  }
  
  // Get status message
  static String getStatusMessage(PostureStatus status) {
    switch (status) {
      case PostureStatus.good:
        return 'Great posture! Keep it up!';
      case PostureStatus.moderate:
        return 'Posture could be improved';
      case PostureStatus.bad:
        return 'Poor posture detected - please adjust';
      case PostureStatus.unknown:
        return 'Unable to detect posture';
    }
  }
  
  // Get status icon
  static String getStatusIcon(PostureStatus status) {
    switch (status) {
      case PostureStatus.good:
        return '😊';
      case PostureStatus.moderate:
        return '😐';
      case PostureStatus.bad:
        return '😟';
      case PostureStatus.unknown:
        return '❓';
    }
  }
}
