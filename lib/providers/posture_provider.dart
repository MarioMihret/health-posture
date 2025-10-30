import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/posture_data.dart';
import '../services/data_persistence_service.dart';

class PostureProvider extends ChangeNotifier {
  PostureStatus _currentPosture = PostureStatus.unknown;
  List<PostureData> _postureHistory = [];
  bool _isMonitoring = false;
  int _goodPostureDuration = 0;
  int _badPostureDuration = 0;
  DateTime? _lastCheckTime;
  double _postureScore = 100.0;
  
  // Data persistence
  final DataPersistenceService _persistenceService = DataPersistenceService();
  
  PostureProvider() {
    _initializeData();
  }
  
  // Initialize and load saved data
  Future<void> _initializeData() async {
    await _persistenceService.init();
    _postureScore = await _persistenceService.getAveragePostureScoreToday();
    if (_postureScore == 0.0) _postureScore = 100.0; // Default if no data
    notifyListeners();
  }
  
  // Getters
  PostureStatus get currentPosture => _currentPosture;
  List<PostureData> get postureHistory => _postureHistory;
  bool get isMonitoring => _isMonitoring;
  int get goodPostureDuration => _goodPostureDuration;
  int get badPostureDuration => _badPostureDuration;
  double get postureScore => _postureScore;
  
  // Calculate today's posture percentage
  double get todayGoodPosturePercentage {
    final total = _goodPostureDuration + _badPostureDuration;
    if (total == 0) return 100.0;
    return (_goodPostureDuration / total) * 100;
  }
  
  // Start monitoring posture
  void startMonitoring() {
    _isMonitoring = true;
    _lastCheckTime = DateTime.now();
    notifyListeners();
  }
  
  // Stop monitoring posture
  void stopMonitoring() {
    _isMonitoring = false;
    notifyListeners();
  }
  
  // Update current posture status
  void updatePostureStatus(PostureStatus status) {
    final now = DateTime.now();
    
    // Update duration counters
    if (_lastCheckTime != null) {
      final duration = now.difference(_lastCheckTime!).inSeconds;
      if (_currentPosture == PostureStatus.good) {
        _goodPostureDuration += duration;
      } else if (_currentPosture == PostureStatus.bad) {
        _badPostureDuration += duration;
      }
    }
    
    _currentPosture = status;
    _lastCheckTime = now;
    
    // Add to history
    _postureHistory.add(PostureData(
      timestamp: now,
      status: status,
      score: _calculatePostureScore(status),
    ));
    
    // Keep only last 100 entries
    if (_postureHistory.length > 100) {
      _postureHistory = _postureHistory.sublist(_postureHistory.length - 100);
    }
    
    // Update overall posture score
    _updatePostureScore();
    
    notifyListeners();
  }
  
  // Calculate posture score based on status
  double _calculatePostureScore(PostureStatus status) {
    switch (status) {
      case PostureStatus.good:
        return 100.0;
      case PostureStatus.moderate:
        return 60.0;
      case PostureStatus.bad:
        return 20.0;
      case PostureStatus.unknown:
        return 50.0;
    }
  }
  
  // Update overall posture score
  void _updatePostureScore() async {
    if (_postureHistory.isEmpty) {
      _postureScore = 100.0;
      return;
    }
    
    // Calculate weighted average of recent posture scores
    final recentHistory = _postureHistory.reversed.take(20).toList();
    double totalScore = 0;
    double totalWeight = 0;
    
    for (int i = 0; i < recentHistory.length; i++) {
      final weight = 1.0 - (i * 0.04); // More recent entries have higher weight
      totalScore += recentHistory[i].score * weight;
      totalWeight += weight;
    }
    
    _postureScore = totalWeight > 0 ? totalScore / totalWeight : 100.0;
    
    // Save posture score to persistence
    await _persistenceService.savePostureScore(_postureScore);
  }
  
  // Reset daily statistics
  void resetDailyStats() {
    _goodPostureDuration = 0;
    _badPostureDuration = 0;
    _postureHistory.clear();
    _postureScore = 100.0;
    notifyListeners();
  }
}
