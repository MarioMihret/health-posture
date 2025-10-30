import 'dart:math';
import '../models/health_data.dart';

class LocalAIService {
  // Singleton pattern
  static final LocalAIService _instance = LocalAIService._internal();
  factory LocalAIService() => _instance;
  LocalAIService._internal();
  
  final _random = Random();
  
  // Local response generation without API
  Future<String> sendMessage(String message) async {
    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final lowerMessage = message.toLowerCase();
    
    // Check for different types of queries and respond appropriately
    if (lowerMessage.contains('posture') || lowerMessage.contains('sitting')) {
      return _getPostureAdvice();
    } else if (lowerMessage.contains('exercise') || lowerMessage.contains('workout')) {
      return _getExerciseAdvice();
    } else if (lowerMessage.contains('pain') || lowerMessage.contains('hurt') || lowerMessage.contains('ache')) {
      return _getPainAdvice();
    } else if (lowerMessage.contains('water') || lowerMessage.contains('hydrat')) {
      return _getHydrationAdvice();
    } else if (lowerMessage.contains('break') || lowerMessage.contains('rest')) {
      return _getBreakAdvice();
    } else if (lowerMessage.contains('motivation') || lowerMessage.contains('motivate')) {
      return _getMotivationalQuote();
    } else if (lowerMessage.contains('tip') || lowerMessage.contains('advice')) {
      return _getGeneralTip();
    } else {
      return _getGeneralResponse();
    }
  }
  
  String _getPostureAdvice() {
    final tips = [
      "Great question! Here are key posture tips:\n\n• Keep your screen at eye level\n• Feet flat on the floor\n• Back against the chair\n• Shoulders relaxed, not hunched\n• Take a break every 30 minutes",
      "For better posture:\n\n• Align your ears over your shoulders\n• Keep shoulders over your hips\n• Adjust your chair height so knees are at 90°\n• Use a lumbar support cushion if needed",
      "Posture improvement starts with awareness:\n\n• Set hourly reminders to check posture\n• Do shoulder rolls every hour\n• Strengthen your core with planks\n• Consider a standing desk for part of the day",
    ];
    return tips[_random.nextInt(tips.length)];
  }
  
  String _getExerciseAdvice() {
    final exercises = [
      "Try these desk exercises:\n\n• Neck stretches (10 each side)\n• Shoulder shrugs (15 reps)\n• Seated spinal twists (10 each side)\n• Ankle circles (10 each direction)\n• Wrist stretches",
      "Quick exercise routine:\n\n• Wall push-ups (10 reps)\n• Desk dips (10 reps)\n• Seated leg raises (15 reps)\n• Standing calf raises (20 reps)\n• Deep breathing (5 breaths)",
      "Strengthen your posture muscles:\n\n• Cat-cow stretches\n• Bird-dog exercise\n• Bridge pose\n• Plank (30 seconds)\n• Superman exercise",
    ];
    return exercises[_random.nextInt(exercises.length)];
  }
  
  String _getPainAdvice() {
    return "If you're experiencing pain:\n\n• Take frequent breaks\n• Apply ice for acute pain, heat for stiffness\n• Gentle stretching may help\n• Check your workstation ergonomics\n\n⚠️ Consult a healthcare provider for persistent pain.";
  }
  
  String _getHydrationAdvice() {
    return "Hydration is key for health:\n\n• Aim for 8 glasses (2 liters) daily\n• Keep water at your desk\n• Drink before you feel thirsty\n• Add lemon for flavor\n• Set hourly water reminders";
  }
  
  String _getBreakAdvice() {
    return "Break recommendations:\n\n• 20-20-20 rule: Every 20 minutes, look at something 20 feet away for 20 seconds\n• Stand and stretch every hour\n• Take a 5-minute walk every 2 hours\n• Do deep breathing exercises";
  }
  
  String _getMotivationalQuote() {
    final quotes = [
      "💪 'Your posture today shapes your health tomorrow!'\n\nSmall improvements each day lead to big results. Keep going!",
      "🌟 'Stand tall, feel powerful!'\n\nGood posture isn't just about health—it boosts confidence and energy too.",
      "🎯 'Every stretch counts, every break matters!'\n\nYou're building healthy habits that will serve you for life.",
      "✨ 'Your body is your lifelong companion—treat it well!'\n\nKeep up the great work on your posture journey!",
    ];
    return quotes[_random.nextInt(quotes.length)];
  }
  
  String _getGeneralTip() {
    final tips = [
      "Quick tip: Roll your shoulders back and down. Feel the difference? That's your ideal shoulder position!",
      "Pro tip: Place a sticky note on your monitor saying 'Check posture!' as a visual reminder.",
      "Health tip: Good posture improves breathing, digestion, and even mood. It's a whole-body benefit!",
      "Workspace tip: Your elbows should be at 90° when typing. Adjust your chair and desk accordingly.",
    ];
    return tips[_random.nextInt(tips.length)];
  }
  
  String _getGeneralResponse() {
    return "I'm here to help with your posture and wellness journey! You can ask me about:\n\n• Posture improvement\n• Desk exercises\n• Pain management\n• Hydration reminders\n• Break schedules\n• Motivation\n\nWhat would you like to know?";
  }
  
  // Generate health insights
  Future<HealthInsight> generateHealthInsight({
    required double postureScore,
    required int exercisesCompleted,
    required int waterIntake,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    String title;
    String description;
    InsightType type;
    String icon;
    
    if (postureScore >= 80 && exercisesCompleted >= 3) {
      title = 'Excellent Progress!';
      description = 'Great posture and exercise routine. Keep it up!';
      type = InsightType.success;
      icon = 'celebration';
    } else if (postureScore < 60) {
      title = 'Posture Alert';
      description = 'Time to focus on your sitting position';
      type = InsightType.warning;
      icon = 'warning';
    } else if (exercisesCompleted == 0) {
      title = 'Get Moving';
      description = 'Try some quick desk exercises';
      type = InsightType.info;
      icon = 'fitness_center';
    } else if (waterIntake < 1000) {
      title = 'Stay Hydrated';
      description = 'Remember to drink water regularly';
      type = InsightType.info;
      icon = 'water_drop';
    } else {
      title = 'On Track';
      description = 'You\'re doing well! Maintain this routine';
      type = InsightType.success;
      icon = 'thumb_up';
    }
    
    return HealthInsight(
      title: title,
      description: description,
      type: type,
      icon: icon,
    );
  }
  
  // Check if we're ready (always true for local)
  bool get hasApiKey => true;
}
