import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // Notification channels
  static const String postureChannelId = 'posture_alerts';
  static const String waterChannelId = 'water_reminders';
  static const String breakChannelId = 'break_reminders';
  static const String exerciseChannelId = 'exercise_reminders';
  
  Future<void> initialize() async {
    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // Initialize
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Create notification channels
    await _createNotificationChannels();
  }
  
  Future<void> _createNotificationChannels() async {
    final androidPlugin = AndroidFlutterLocalNotificationsPlugin();
    
    // Posture alerts channel
    const postureChannel = AndroidNotificationChannel(
      postureChannelId,
      'Posture Alerts',
      description: 'Notifications about your posture',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    
    // Water reminders channel
    const waterChannel = AndroidNotificationChannel(
      waterChannelId,
      'Water Reminders',
      description: 'Reminders to drink water',
      importance: Importance.defaultImportance,
      playSound: true,
    );
    
    // Break reminders channel
    const breakChannel = AndroidNotificationChannel(
      breakChannelId,
      'Break Reminders',
      description: 'Reminders to take breaks',
      importance: Importance.defaultImportance,
      playSound: true,
    );
    
    // Exercise reminders channel
    const exerciseChannel = AndroidNotificationChannel(
      exerciseChannelId,
      'Exercise Reminders',
      description: 'Reminders to do exercises',
      importance: Importance.defaultImportance,
      playSound: true,
    );
    
    await androidPlugin?.createNotificationChannel(postureChannel);
    await androidPlugin?.createNotificationChannel(waterChannel);
    await androidPlugin?.createNotificationChannel(breakChannel);
    await androidPlugin?.createNotificationChannel(exerciseChannel);
  }
  
  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle navigation based on payload
    final payload = response.payload;
    if (payload != null) {
      // Navigate to appropriate screen based on payload
      debugPrint('Notification tapped with payload: $payload');
    }
  }
  
  // Show posture alert
  Future<void> showPostureAlert({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      postureChannelId,
      'Posture Alerts',
      channelDescription: 'Notifications about your posture',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFEF4444),
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }
  
  // Show water reminder
  Future<void> showWaterReminder() async {
    const androidDetails = AndroidNotificationDetails(
      waterChannelId,
      'Water Reminders',
      channelDescription: 'Reminders to drink water',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF22D3EE),
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '💧 Time to Hydrate!',
      'Remember to drink water to stay healthy and focused.',
      details,
      payload: 'water_reminder',
    );
  }
  
  // Show break reminder
  Future<void> showBreakReminder() async {
    const androidDetails = AndroidNotificationDetails(
      breakChannelId,
      'Break Reminders',
      channelDescription: 'Reminders to take breaks',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF10B981),
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '⏸️ Time for a Break!',
      'Stand up, stretch, and give your body a rest.',
      details,
      payload: 'break_reminder',
    );
  }
  
  // Show exercise reminder
  Future<void> showExerciseReminder({
    required String exerciseName,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      exerciseChannelId,
      'Exercise Reminders',
      channelDescription: 'Reminders to do exercises',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF8B5CF6),
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '🏃 Exercise Time!',
      'Try the $exerciseName exercise to stay active.',
      details,
      payload: 'exercise_reminder',
    );
  }
  
  // Schedule periodic water reminder
  Future<void> scheduleWaterReminder(int intervalMinutes) async {
    // Cancel existing water reminders
    await cancelWaterReminders();
    
    // Schedule new reminder
    const androidDetails = AndroidNotificationDetails(
      waterChannelId,
      'Water Reminders',
      channelDescription: 'Reminders to drink water',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // Schedule periodic notification
    await _notifications.periodicallyShow(
      1,
      '💧 Hydration Reminder',
      'Time to drink some water!',
      RepeatInterval.hourly,
      details,
      payload: 'water_reminder',
    );
  }
  
  // Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
  
  // Cancel water reminders
  Future<void> cancelWaterReminders() async {
    await _notifications.cancel(1);
  }
  
  // Cancel break reminders  
  Future<void> cancelBreakReminders() async {
    await _notifications.cancel(2);
  }
  
  // Request permissions
  Future<bool> requestPermissions() async {
    final androidPlugin = AndroidFlutterLocalNotificationsPlugin();
    final iosPlugin = IOSFlutterLocalNotificationsPlugin();
    
    // Request Android permissions
    final androidGranted = await androidPlugin?.requestNotificationsPermission() ?? false;
    
    // Request iOS permissions
    final iosGranted = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    ) ?? false;
    
    return androidGranted || iosGranted;
  }
}
