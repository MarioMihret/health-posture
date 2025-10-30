import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/health_data.dart';
import '../models/exercise.dart';
import '../services/data_persistence_service.dart';
import '../services/ai_service.dart';

class HealthProvider extends ChangeNotifier {
  // Water tracking
  int _waterIntake = 0;
  int _waterGoal = 2000; // ml
  DateTime? _lastWaterReminder;
  Timer? _waterReminderTimer;
  
  // Data persistence
  final DataPersistenceService _persistenceService = DataPersistenceService();
  bool _isInitialized = false;
  
  // Exercise tracking
  int _exercisesCompleted = 0;
  int _exerciseStreak = 0;
  List<Exercise> _completedExercises = [];
  DateTime? _lastExerciseTime;
  
  // Break reminders
  int _breaksTaken = 0;
  int _breaksGoal = 8;
  DateTime? _lastBreakTime;
  Timer? _breakReminderTimer;
  
  // Health insights
  List<HealthInsight> _insights = [];
  double _overallHealthScore = 75.0;
  
  // Getters
  int get waterIntake => _waterIntake;
  int get waterGoal => _waterGoal;
  double get waterProgress => _waterIntake / _waterGoal;
  int get exercisesCompleted => _exercisesCompleted;
  int get exerciseStreak => _exerciseStreak;
  List<Exercise> get completedExercises => _completedExercises;
  int get breaksTaken => _breaksTaken;
  int get breaksGoal => _breaksGoal;
  double get breaksProgress => _breaksTaken / _breaksGoal;
  List<HealthInsight> get insights => _insights;
  double get overallHealthScore => _overallHealthScore;
  bool get isInitialized => _isInitialized;
  
  // Constructor
  HealthProvider() {
    _initializeData();
  }
  
  // Initialize health monitoring and load saved data
  Future<void> _initializeData() async {
    if (_isInitialized) return;
    
    await _persistenceService.init();
    await _loadSavedData();
    _startWaterReminder();
    _startBreakReminder();
    _generateDailyInsights();
    
    _isInitialized = true;
    notifyListeners();
  }
  
  // Public method to ensure initialization
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await _initializeData();
    }
  }
  
  // Load saved data from persistence
  Future<void> _loadSavedData() async {
    // Load water intake
    _waterIntake = await _persistenceService.getTodayWaterIntake();
    
    // Load exercise data
    _exercisesCompleted = await _persistenceService.getExercisesCompletedToday();
    _exerciseStreak = await _persistenceService.getDailyStreak();
    
    // Load total exercises for achievements check
    final totalExercises = await _persistenceService.getTotalExercisesCompleted();
    if (totalExercises > 0) {
      _checkAndShowAchievements();
    }
    
    notifyListeners();
  }
  
  // Add water intake
  Future<void> addWaterIntake(int amount) async {
    _waterIntake += amount;
    if (_waterIntake > _waterGoal) {
      _waterIntake = _waterGoal;
    }
    
    // Save to persistence
    await _persistenceService.saveWaterIntake(amount);
    
    _updateHealthScore();
    notifyListeners();
  }
  
  // Set water goal
  void setWaterGoal(int goal) {
    _waterGoal = goal;
    notifyListeners();
  }
  
  // Mark exercise as completed
  Future<void> completeExercise(Exercise exercise) async {
    _exercisesCompleted++;
    _completedExercises.add(exercise);
    _lastExerciseTime = DateTime.now();
    
    // Save to persistence
    await _persistenceService.saveCompletedExercise(exercise);
    
    // Update streak from persistence (it handles the logic)
    _exerciseStreak = await _persistenceService.getDailyStreak();
    
    // Check for new achievements
    await _checkAndShowAchievements();
    
    _updateHealthScore();
    notifyListeners();
  }
  
  // Check and show new achievements
  Future<void> _checkAndShowAchievements() async {
    final newAchievements = await _persistenceService.checkForNewAchievements();
    for (final achievement in newAchievements) {
      _addInsight(
        HealthInsight(
          title: 'Achievement Unlocked!',
          description: achievement,
          type: InsightType.success,
          icon: 'trophy',
        ),
      );
    }
  }
  
  // Add insight to the list
  void _addInsight(HealthInsight insight) {
    _insights.insert(0, insight);
    // Keep only the latest 10 insights
    if (_insights.length > 10) {
      _insights.removeLast();
    }
    notifyListeners();
  }
  
  // Record break taken
  void recordBreak() {
    _breaksTaken++;
    _lastBreakTime = DateTime.now();
    _updateHealthScore();
    notifyListeners();
  }
  
  // Start water reminder timer
  void _startWaterReminder() {
    _waterReminderTimer?.cancel();
    _waterReminderTimer = Timer.periodic(
      const Duration(hours: 1),
      (timer) {
        _lastWaterReminder = DateTime.now();
        // Trigger notification through notification service
        notifyListeners();
      },
    );
  }
  
  // Start break reminder timer
  void _startBreakReminder() {
    _breakReminderTimer?.cancel();
    _breakReminderTimer = Timer.periodic(
      const Duration(minutes: 30),
      (timer) {
        _lastBreakTime = DateTime.now();
        // Trigger notification through notification service
        notifyListeners();
      },
    );
  }
  
  // Generate daily health insights
  void _generateDailyInsights() {
    _insights.clear();
    
    // Water intake insight
    if (_waterIntake < _waterGoal * 0.5) {
      _insights.add(HealthInsight(
        title: 'Hydration Alert',
        description: 'You\'ve only consumed ${_waterIntake}ml of water today. Stay hydrated!',
        type: InsightType.warning,
        icon: 'water_drop',
      ));
    } else if (_waterIntake >= _waterGoal) {
      _insights.add(HealthInsight(
        title: 'Hydration Goal Met!',
        description: 'Great job! You\'ve reached your daily water intake goal.',
        type: InsightType.success,
        icon: 'water_drop',
      ));
    }
    
    // Exercise insight
    if (_exercisesCompleted == 0) {
      _insights.add(HealthInsight(
        title: 'Time to Stretch',
        description: 'You haven\'t done any exercises today. Try a quick stretch!',
        type: InsightType.warning,
        icon: 'run',
      ));
    } else if (_exercisesCompleted >= 5) {
      _insights.add(HealthInsight(
        title: 'Exercise Champion!',
        description: 'You\'ve completed $_exercisesCompleted exercises today. Keep it up!',
        type: InsightType.success,
        icon: 'target',
      ));
    }
    
    // Break insight
    if (_breaksTaken < _breaksGoal * 0.5) {
      _insights.add(HealthInsight(
        title: 'Take More Breaks',
        description: 'Regular breaks improve productivity and reduce strain.',
        type: InsightType.info,
        icon: 'pause',
      ));
    }
    
    // Streak insight
    if (_exerciseStreak >= 7) {
      _insights.add(HealthInsight(
        title: 'Weekly Streak!',
        description: 'You\'ve exercised for $_exerciseStreak days in a row!',
        type: InsightType.success,
        icon: 'fire',
      ));
    }
  }
  
  // Update overall health score
  void _updateHealthScore() {
    double score = 0;
    
    // Water component (30%)
    score += (waterProgress.clamp(0.0, 1.0) * 30);
    
    // Exercise component (30%)
    final exerciseScore = (_exercisesCompleted / 5).clamp(0.0, 1.0);
    score += (exerciseScore * 30);
    
    // Breaks component (20%)
    score += (breaksProgress.clamp(0.0, 1.0) * 20);
    
    // Streak bonus (20%)
    final streakScore = (_exerciseStreak / 7).clamp(0.0, 1.0);
    score += (streakScore * 20);
    
    _overallHealthScore = score.clamp(0.0, 100.0);
  }
  
  // Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  // Reset daily stats
  void resetDailyStats() {
    _waterIntake = 0;
    _exercisesCompleted = 0;
    _breaksTaken = 0;
    _completedExercises.clear();
    _generateDailyInsights();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _waterReminderTimer?.cancel();
    _breakReminderTimer?.cancel();
    super.dispose();
  }
}
