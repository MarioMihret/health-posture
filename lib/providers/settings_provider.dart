import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  
  // Theme settings
  ThemeMode _themeMode = ThemeMode.system;
  
  // Notification settings
  bool _postureAlerts = true;
  bool _waterReminders = true;
  bool _breakReminders = true;
  bool _exerciseReminders = true;
  
  // Alert frequencies (in minutes)
  int _postureCheckFrequency = 15;
  int _waterReminderFrequency = 60;
  int _breakReminderFrequency = 30;
  
  // Goals
  int _dailyWaterGoal = 2000; // ml
  int _dailyBreaksGoal = 8;
  int _dailyExerciseGoal = 5;
  
  // Camera settings
  bool _useFrontCamera = true;
  bool _showCameraPreview = true;
  
  // Sound settings
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  
  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get postureAlerts => _postureAlerts;
  bool get waterReminders => _waterReminders;
  bool get breakReminders => _breakReminders;
  bool get exerciseReminders => _exerciseReminders;
  int get postureCheckFrequency => _postureCheckFrequency;
  int get waterReminderFrequency => _waterReminderFrequency;
  int get breakReminderFrequency => _breakReminderFrequency;
  int get dailyWaterGoal => _dailyWaterGoal;
  int get dailyBreaksGoal => _dailyBreaksGoal;
  int get dailyExerciseGoal => _dailyExerciseGoal;
  bool get useFrontCamera => _useFrontCamera;
  bool get showCameraPreview => _showCameraPreview;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  
  SettingsProvider() {
    _loadSettings();
  }
  
  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Load theme
    final themeModeIndex = _prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    
    // Load notification settings
    _postureAlerts = _prefs.getBool('postureAlerts') ?? true;
    _waterReminders = _prefs.getBool('waterReminders') ?? true;
    _breakReminders = _prefs.getBool('breakReminders') ?? true;
    _exerciseReminders = _prefs.getBool('exerciseReminders') ?? true;
    
    // Load frequencies
    _postureCheckFrequency = _prefs.getInt('postureCheckFrequency') ?? 15;
    _waterReminderFrequency = _prefs.getInt('waterReminderFrequency') ?? 60;
    _breakReminderFrequency = _prefs.getInt('breakReminderFrequency') ?? 30;
    
    // Load goals
    _dailyWaterGoal = _prefs.getInt('dailyWaterGoal') ?? 2000;
    _dailyBreaksGoal = _prefs.getInt('dailyBreaksGoal') ?? 8;
    _dailyExerciseGoal = _prefs.getInt('dailyExerciseGoal') ?? 5;
    
    // Load camera settings
    _useFrontCamera = _prefs.getBool('useFrontCamera') ?? true;
    _showCameraPreview = _prefs.getBool('showCameraPreview') ?? true;
    
    // Load sound settings
    _soundEnabled = _prefs.getBool('soundEnabled') ?? true;
    _vibrationEnabled = _prefs.getBool('vibrationEnabled') ?? true;
    
    notifyListeners();
  }
  
  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }
  
  // Toggle theme between light and dark
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      // If system, toggle to light
      await setThemeMode(ThemeMode.light);
    }
  }
  
  // Toggle posture alerts
  Future<void> togglePostureAlerts(bool value) async {
    _postureAlerts = value;
    await _prefs.setBool('postureAlerts', value);
    notifyListeners();
  }
  
  // Toggle water reminders
  Future<void> toggleWaterReminders(bool value) async {
    _waterReminders = value;
    await _prefs.setBool('waterReminders', value);
    notifyListeners();
  }
  
  // Toggle break reminders
  Future<void> toggleBreakReminders(bool value) async {
    _breakReminders = value;
    await _prefs.setBool('breakReminders', value);
    notifyListeners();
  }
  
  // Toggle exercise reminders
  Future<void> toggleExerciseReminders(bool value) async {
    _exerciseReminders = value;
    await _prefs.setBool('exerciseReminders', value);
    notifyListeners();
  }
  
  // Set posture check frequency
  Future<void> setPostureCheckFrequency(int minutes) async {
    _postureCheckFrequency = minutes;
    await _prefs.setInt('postureCheckFrequency', minutes);
    notifyListeners();
  }
  
  // Set water reminder frequency
  Future<void> setWaterReminderFrequency(int minutes) async {
    _waterReminderFrequency = minutes;
    await _prefs.setInt('waterReminderFrequency', minutes);
    notifyListeners();
  }
  
  // Set break reminder frequency
  Future<void> setBreakReminderFrequency(int minutes) async {
    _breakReminderFrequency = minutes;
    await _prefs.setInt('breakReminderFrequency', minutes);
    notifyListeners();
  }
  
  // Set daily water goal
  Future<void> setDailyWaterGoal(int ml) async {
    _dailyWaterGoal = ml;
    await _prefs.setInt('dailyWaterGoal', ml);
    notifyListeners();
  }
  
  // Set daily breaks goal
  Future<void> setDailyBreaksGoal(int breaks) async {
    _dailyBreaksGoal = breaks;
    await _prefs.setInt('dailyBreaksGoal', breaks);
    notifyListeners();
  }
  
  // Set daily exercise goal
  Future<void> setDailyExerciseGoal(int exercises) async {
    _dailyExerciseGoal = exercises;
    await _prefs.setInt('dailyExerciseGoal', exercises);
    notifyListeners();
  }
  
  // Toggle camera
  Future<void> toggleCamera(bool useFront) async {
    _useFrontCamera = useFront;
    await _prefs.setBool('useFrontCamera', useFront);
    notifyListeners();
  }
  
  // Toggle camera preview
  Future<void> toggleCameraPreview(bool show) async {
    _showCameraPreview = show;
    await _prefs.setBool('showCameraPreview', show);
    notifyListeners();
  }
  
  // Toggle sound
  Future<void> toggleSound(bool enabled) async {
    _soundEnabled = enabled;
    await _prefs.setBool('soundEnabled', enabled);
    notifyListeners();
  }
  
  // Toggle vibration
  Future<void> toggleVibration(bool enabled) async {
    _vibrationEnabled = enabled;
    await _prefs.setBool('vibrationEnabled', enabled);
    notifyListeners();
  }
}
