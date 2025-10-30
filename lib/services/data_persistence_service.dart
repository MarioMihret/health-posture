import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/exercise.dart';
import '../models/posture_data.dart';

class DataPersistenceService {
  static const String _keyExerciseHistory = 'exercise_history';
  static const String _keyPostureScores = 'posture_scores';
  static const String _keyWaterIntake = 'water_intake';
  static const String _keyDailyStreak = 'daily_streak';
  static const String _keyTotalExercises = 'total_exercises';
  static const String _keyLastExerciseDate = 'last_exercise_date';
  static const String _keyWeeklyGoal = 'weekly_goal';
  static const String _keyUserStats = 'user_stats';
  static const String _keyAchievements = 'achievements';
  static const String _keyPreferences = 'user_preferences';
  
  late SharedPreferences _prefs;
  
  // Singleton pattern
  static final DataPersistenceService _instance = DataPersistenceService._internal();
  factory DataPersistenceService() => _instance;
  DataPersistenceService._internal();
  
  // Initialize
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // ===== Exercise Data =====
  
  // Save completed exercise
  Future<void> saveCompletedExercise(Exercise exercise) async {
    final history = await getExerciseHistory();
    final exerciseData = {
      'id': exercise.id,
      'name': exercise.name,
      'category': exercise.category.index,
      'completedAt': DateTime.now().toIso8601String(),
      'duration': exercise.duration.inSeconds,
      'caloriesBurned': exercise.caloriesBurned,
    };
    
    history.add(exerciseData);
    await _prefs.setString(_keyExerciseHistory, jsonEncode(history));
    
    // Update total exercises count
    final totalExercises = await getTotalExercisesCompleted();
    await _prefs.setInt(_keyTotalExercises, totalExercises + 1);
    
    // Update last exercise date
    await _prefs.setString(_keyLastExerciseDate, DateTime.now().toIso8601String());
    
    // Check and update daily streak
    await _updateDailyStreak();
  }
  
  // Get exercise history
  Future<List<Map<String, dynamic>>> getExerciseHistory() async {
    final jsonString = _prefs.getString(_keyExerciseHistory);
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }
  
  // Get exercises completed today
  Future<int> getExercisesCompletedToday() async {
    final history = await getExerciseHistory();
    final today = DateTime.now();
    
    return history.where((exercise) {
      final completedAt = DateTime.parse(exercise['completedAt']);
      return completedAt.year == today.year &&
             completedAt.month == today.month &&
             completedAt.day == today.day;
    }).length;
  }
  
  // Get exercises completed this week
  Future<int> getExercisesCompletedThisWeek() async {
    final history = await getExerciseHistory();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    return history.where((exercise) {
      final completedAt = DateTime.parse(exercise['completedAt']);
      return completedAt.isAfter(weekStart) || 
             (completedAt.year == weekStart.year &&
              completedAt.month == weekStart.month &&
              completedAt.day == weekStart.day);
    }).length;
  }
  
  // Get total calories burned
  Future<int> getTotalCaloriesBurned() async {
    final history = await getExerciseHistory();
    return history.fold<int>(0, (sum, exercise) => sum + (exercise['caloriesBurned'] as int));
  }
  
  // ===== Posture Data =====
  
  // Save posture score
  Future<void> savePostureScore(double score) async {
    final scores = await getPostureScores();
    final scoreData = {
      'score': score,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    scores.add(scoreData);
    await _prefs.setString(_keyPostureScores, jsonEncode(scores));
  }
  
  // Get posture scores
  Future<List<Map<String, dynamic>>> getPostureScores() async {
    final jsonString = _prefs.getString(_keyPostureScores);
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }
  
  // Get average posture score today
  Future<double> getAveragePostureScoreToday() async {
    final scores = await getPostureScores();
    final today = DateTime.now();
    
    final todayScores = scores.where((score) {
      final timestamp = DateTime.parse(score['timestamp']);
      return timestamp.year == today.year &&
             timestamp.month == today.month &&
             timestamp.day == today.day;
    }).toList();
    
    if (todayScores.isEmpty) return 0.0;
    
    final total = todayScores.fold<double>(
      0.0, 
      (sum, score) => sum + (score['score'] as double)
    );
    
    return total / todayScores.length;
  }
  
  // ===== Water Intake =====
  
  // Save water intake
  Future<void> saveWaterIntake(int amount) async {
    final today = DateTime.now();
    final key = '${_keyWaterIntake}_${today.year}_${today.month}_${today.day}';
    final current = _prefs.getInt(key) ?? 0;
    await _prefs.setInt(key, current + amount);
  }
  
  // Get today's water intake
  Future<int> getTodayWaterIntake() async {
    final today = DateTime.now();
    final key = '${_keyWaterIntake}_${today.year}_${today.month}_${today.day}';
    return _prefs.getInt(key) ?? 0;
  }
  
  // ===== Daily Streak =====
  
  // Update daily streak
  Future<void> _updateDailyStreak() async {
    final lastExerciseDateStr = _prefs.getString(_keyLastExerciseDate);
    final currentStreak = _prefs.getInt(_keyDailyStreak) ?? 0;
    
    if (lastExerciseDateStr == null) {
      await _prefs.setInt(_keyDailyStreak, 1);
      return;
    }
    
    final lastExerciseDate = DateTime.parse(lastExerciseDateStr);
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (lastExerciseDate.year == today.year &&
        lastExerciseDate.month == today.month &&
        lastExerciseDate.day == today.day) {
      // Already exercised today, maintain streak
      return;
    } else if (lastExerciseDate.year == yesterday.year &&
               lastExerciseDate.month == yesterday.month &&
               lastExerciseDate.day == yesterday.day) {
      // Exercised yesterday, increment streak
      await _prefs.setInt(_keyDailyStreak, currentStreak + 1);
    } else {
      // Streak broken, reset to 1
      await _prefs.setInt(_keyDailyStreak, 1);
    }
  }
  
  // Get daily streak
  Future<int> getDailyStreak() async {
    return _prefs.getInt(_keyDailyStreak) ?? 0;
  }
  
  // ===== Statistics =====
  
  // Get total exercises completed
  Future<int> getTotalExercisesCompleted() async {
    return _prefs.getInt(_keyTotalExercises) ?? 0;
  }
  
  // Save user statistics
  Future<void> saveUserStats(Map<String, dynamic> stats) async {
    await _prefs.setString(_keyUserStats, jsonEncode(stats));
  }
  
  // Get user statistics
  Future<Map<String, dynamic>?> getUserStats() async {
    final jsonString = _prefs.getString(_keyUserStats);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }
  
  // ===== Achievements =====
  
  // Unlock achievement
  Future<void> unlockAchievement(String achievementId) async {
    final achievements = await getUnlockedAchievements();
    if (!achievements.contains(achievementId)) {
      achievements.add(achievementId);
      await _prefs.setStringList(_keyAchievements, achievements);
    }
  }
  
  // Get unlocked achievements
  Future<List<String>> getUnlockedAchievements() async {
    return _prefs.getStringList(_keyAchievements) ?? [];
  }
  
  // Check for new achievements
  Future<List<String>> checkForNewAchievements() async {
    final newAchievements = <String>[];
    
    // Check streak achievements
    final streak = await getDailyStreak();
    if (streak >= 7 && !(await getUnlockedAchievements()).contains('streak_7')) {
      await unlockAchievement('streak_7');
      newAchievements.add('7-Day Streak!');
    }
    if (streak >= 30 && !(await getUnlockedAchievements()).contains('streak_30')) {
      await unlockAchievement('streak_30');
      newAchievements.add('30-Day Champion!');
    }
    
    // Check exercise count achievements
    final totalExercises = await getTotalExercisesCompleted();
    if (totalExercises >= 10 && !(await getUnlockedAchievements()).contains('exercises_10')) {
      await unlockAchievement('exercises_10');
      newAchievements.add('First 10 Exercises!');
    }
    if (totalExercises >= 50 && !(await getUnlockedAchievements()).contains('exercises_50')) {
      await unlockAchievement('exercises_50');
      newAchievements.add('50 Exercises Milestone!');
    }
    if (totalExercises >= 100 && !(await getUnlockedAchievements()).contains('exercises_100')) {
      await unlockAchievement('exercises_100');
      newAchievements.add('Century Club!');
    }
    
    // Check posture achievements
    final avgPosture = await getAveragePostureScoreToday();
    if (avgPosture >= 90 && !(await getUnlockedAchievements()).contains('perfect_posture')) {
      await unlockAchievement('perfect_posture');
      newAchievements.add('Perfect Posture!');
    }
    
    return newAchievements;
  }
  
  // ===== Goals =====
  
  // Set weekly exercise goal
  Future<void> setWeeklyExerciseGoal(int goal) async {
    await _prefs.setInt(_keyWeeklyGoal, goal);
  }
  
  // Get weekly exercise goal
  Future<int> getWeeklyExerciseGoal() async {
    return _prefs.getInt(_keyWeeklyGoal) ?? 20; // Default: 20 exercises per week
  }
  
  // Calculate weekly progress
  Future<double> getWeeklyProgress() async {
    final completed = await getExercisesCompletedThisWeek();
    final goal = await getWeeklyExerciseGoal();
    return (completed / goal).clamp(0.0, 1.0);
  }
  
  // ===== Clear Data =====
  
  // Clear all saved data (for testing or reset)
  Future<void> clearAllData() async {
    await _prefs.clear();
  }
  
  // Clear exercise history
  Future<void> clearExerciseHistory() async {
    await _prefs.remove(_keyExerciseHistory);
    await _prefs.remove(_keyTotalExercises);
    await _prefs.remove(_keyLastExerciseDate);
  }
  
  // Export all data as JSON
  Future<String> exportAllData() async {
    final data = {
      'exerciseHistory': await getExerciseHistory(),
      'postureScores': await getPostureScores(),
      'waterIntake': await getTodayWaterIntake(),
      'dailyStreak': await getDailyStreak(),
      'totalExercises': await getTotalExercisesCompleted(),
      'achievements': await getUnlockedAchievements(),
      'weeklyGoal': await getWeeklyExerciseGoal(),
      'userStats': await getUserStats(),
      'exportDate': DateTime.now().toIso8601String(),
    };
    
    return jsonEncode(data);
  }
  
  // Import data from JSON
  Future<void> importData(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      
      // Import exercise history
      if (data.containsKey('exerciseHistory')) {
        await _prefs.setString(_keyExerciseHistory, jsonEncode(data['exerciseHistory']));
      }
      
      // Import posture scores
      if (data.containsKey('postureScores')) {
        await _prefs.setString(_keyPostureScores, jsonEncode(data['postureScores']));
      }
      
      // Import other data
      if (data.containsKey('dailyStreak')) {
        await _prefs.setInt(_keyDailyStreak, data['dailyStreak']);
      }
      
      if (data.containsKey('totalExercises')) {
        await _prefs.setInt(_keyTotalExercises, data['totalExercises']);
      }
      
      if (data.containsKey('achievements')) {
        await _prefs.setStringList(_keyAchievements, List<String>.from(data['achievements']));
      }
      
      if (data.containsKey('weeklyGoal')) {
        await _prefs.setInt(_keyWeeklyGoal, data['weeklyGoal']);
      }
      
      if (data.containsKey('userStats')) {
        await _prefs.setString(_keyUserStats, jsonEncode(data['userStats']));
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }
}
