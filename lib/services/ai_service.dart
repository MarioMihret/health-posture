import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:async';
import '../models/exercise.dart';
import '../models/posture_data.dart';
import '../models/health_data.dart';

class AIService {
  static const String _apiKey = 'AIzaSyBsBOcXBoUX0V9YMz8pB4sBGH5fIAZ9YX4'; // Replace with your API key
  GenerativeModel? _model;
  ChatSession? _chatSession;
  bool _isInitialized = false;
  String? _workingModel;
  
  // Model fallbacks - using correct model names for the current API
  static const List<String> _modelFallbacks = [
    'gemini-1.5-flash', // Most reliable free model
    'gemini-1.5-flash-latest', // Latest flash version
    'gemini-1.5-pro', // Pro model (might have quota)
    'gemini-1.5-pro-latest', // Latest pro version
    'gemini-pro', // Original Gemini Pro
    'gemini-1.0-pro', // Version 1.0
  ];
  
  // Singleton pattern
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();
  
  // Get working model with fallback
  Future<GenerativeModel?> _getWorkingModel() async {
    // Use cached working model if available
    if (_workingModel != null && _model != null) {
      return _model;
    }
    
    // Try each model in fallback order
    for (final modelName in _modelFallbacks) {
      try {
        print('Trying model: $modelName');
        final model = GenerativeModel(
          model: modelName,
          apiKey: _apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.7,
            maxOutputTokens: 1000,
          ),
        );
        
        // Test if model works
        try {
          final testResponse = await model.generateContent([Content.text('Hello')]);
          if (testResponse.text != null) {
            print('✅ Using Gemini model: $modelName');
            _workingModel = modelName;
            _model = model;
            return model;
          }
        } catch (testError) {
          print('Model $modelName test failed: $testError');
        }
      } catch (error) {
        print('Model $modelName not available: $error');
        continue;
      }
    }
    
    print('❌ No Gemini models available. Check your API key.');
    return null;
  }
  
  // Initialize the AI service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final model = await _getWorkingModel();
      if (model == null) {
        throw Exception('No working Gemini models found');
      }
      
      // Initialize chat with system context
      final systemPrompt = '''
You are a professional health and posture assistant AI. Your role is to:
1. Provide expert advice on posture correction and ergonomics
2. Suggest appropriate exercises for specific posture issues
3. Give motivational support and encouragement
4. Analyze health patterns and provide insights
5. Answer health-related questions professionally

Always be:
- Supportive and encouraging
- Professional but friendly
- Evidence-based in recommendations
- Careful about medical advice (suggest consulting professionals for serious issues)
      ''';
      
      _chatSession = model.startChat(
        history: [
          Content.text(systemPrompt),
          Content.model([TextPart('I understand. I\'m ready to help you with your posture and health goals!')]),
        ],
      );
      
      _isInitialized = true;
      print('✅ AI Service initialized successfully with model: $_workingModel');
    } catch (e) {
      print('Failed to initialize AI service: $e');
      _isInitialized = false;
      throw Exception('AI service initialization failed: $e');
    }
  }
  
  // Get personalized exercise recommendations
  Future<List<String>> getExerciseRecommendations({
    required PostureStatus currentPosture,
    required List<Exercise> completedExercises,
    required double postureScore,
  }) async {
    if (!_isInitialized) await initialize();
    
    if (_chatSession == null) {
      print('Chat session not initialized, returning defaults');
      return ['Neck Rotation', 'Shoulder Rolls', 'Cat-Cow Stretch'];
    }
    
    try {
      final prompt = '''
Based on the following user data:
- Current posture status: ${currentPosture.name}
- Posture score: ${postureScore.toStringAsFixed(1)}%
- Recently completed exercises: ${completedExercises.take(3).map((e) => e.name).join(', ')}

Recommend 3 specific exercises that would help improve their posture. 
Format: Return only exercise names, one per line.
      ''';
      
      final response = await _chatSession!.sendMessage(Content.text(prompt));
      final recommendations = response.text?.split('\n')
          .where((line) => line.trim().isNotEmpty)
          .take(3)
          .toList() ?? [];
      
      return recommendations;
    } catch (e) {
      print('Error getting exercise recommendations: $e');
      return ['Neck Rotation', 'Shoulder Rolls', 'Cat-Cow Stretch'];
    }
  }
  
  // Generate personalized insights
  Future<HealthInsight> generatePersonalizedInsight({
    required double postureScore,
    required int exercisesCompleted,
    required int waterIntake,
    required int dailyStreak,
  }) async {
    if (!_isInitialized) await initialize();
    
    try {
      final prompt = '''
Generate a personalized health insight based on:
- Posture score: ${postureScore.toStringAsFixed(1)}%
- Exercises completed today: $exercisesCompleted
- Water intake: ${waterIntake}ml
- Daily streak: $dailyStreak days

Provide ONE specific, actionable insight.
Format: Title (max 5 words) | Description (max 20 words) | Type (success/warning/info)
      ''';
      
      final response = await _chatSession!.sendMessage(Content.text(prompt));
      final parts = response.text?.split('|') ?? [];
      
      if (parts.length >= 3) {
        final typeStr = parts[2].trim().toLowerCase();
        InsightType type = InsightType.info;
        if (typeStr.contains('success')) type = InsightType.success;
        if (typeStr.contains('warning')) type = InsightType.warning;
        
        return HealthInsight(
          title: parts[0].trim(),
          description: parts[1].trim(),
          type: type,
          icon: 'lightbulb',
        );
      }
      
      // Fallback insight
      return HealthInsight(
        title: 'Keep Going!',
        description: 'You\'re making great progress today',
        type: InsightType.success,
        icon: 'star',
      );
    } catch (e) {
      print('Error generating insight: $e');
      return HealthInsight(
        title: 'Stay Active',
        description: 'Remember to take regular breaks',
        type: InsightType.info,
        icon: 'info',
      );
    }
  }
  
  // Chat with AI assistant
  Future<String> sendMessage(String message) async {
    if (!_isInitialized) await initialize();
    
    if (_chatSession == null) {
      return 'AI service is not properly initialized. Please restart the app.';
    }
    
    try {
      final response = await _chatSession!.sendMessage(Content.text(message));
      return response.text ?? 'I\'m here to help! Could you please rephrase your question?';
    } catch (e) {
      print('Error sending message: $e');
      // Try reinitializing with a different model
      _isInitialized = false;
      _workingModel = null;
      try {
        await initialize();
        final response = await _chatSession!.sendMessage(Content.text(message));
        return response.text ?? 'I\'m here to help! Could you please rephrase your question?';
      } catch (retryError) {
        return 'I apologize, but I\'m having trouble processing your request. Please try again later.';
      }
    }
  }
  
  // Analyze posture trends and provide feedback
  Future<String> analyzePostureTrends(List<PostureData> history) async {
    if (!_isInitialized) await initialize();
    if (history.isEmpty) return 'No posture data available yet. Keep monitoring!';
    
    try {
      final recentData = history.take(20).toList();
      final avgScore = recentData.fold(0.0, (sum, data) => sum + data.score) / recentData.length;
      final goodPostureCount = recentData.where((d) => d.status == PostureStatus.good).length;
      
      final prompt = '''
Analyze posture trend:
- Average score: ${avgScore.toStringAsFixed(1)}%
- Good posture: ${(goodPostureCount / recentData.length * 100).toStringAsFixed(0)}% of time
- Data points: ${recentData.length}

Provide a brief, encouraging analysis (max 30 words).
      ''';
      
      final response = await _chatSession!.sendMessage(Content.text(prompt));
      return response.text ?? 'Your posture is improving! Keep up the good work.';
    } catch (e) {
      print('Error analyzing trends: $e');
      return 'Keep monitoring your posture for personalized insights!';
    }
  }
  
  // Get motivational quote based on context
  Future<String> getMotivationalQuote({
    required String context,
    required int streak,
  }) async {
    if (!_isInitialized) await initialize();
    
    try {
      final prompt = '''
Generate a short motivational quote for someone who:
- Context: $context
- Has maintained a $streak day streak

Make it specific to posture/health. Max 15 words.
      ''';
      
      final response = await _chatSession!.sendMessage(Content.text(prompt));
      return response.text ?? 'Every moment of good posture is an investment in your future health!';
    } catch (e) {
      print('Error getting quote: $e');
      return 'Stand tall, breathe deep, and conquer your day!';
    }
  }
  
  // Get exercise form tips
  Future<List<String>> getExerciseTips(Exercise exercise) async {
    if (!_isInitialized) await initialize();
    
    try {
      final prompt = '''
Provide 3 quick tips for performing "${exercise.name}" correctly.
Focus on form and safety. Each tip max 10 words.
Format: One tip per line.
      ''';
      
      final response = await _chatSession!.sendMessage(Content.text(prompt));
      final tips = response.text?.split('\n')
          .where((line) => line.trim().isNotEmpty)
          .take(3)
          .toList() ?? [];
      
      return tips.isNotEmpty ? tips : [
        'Keep your spine aligned',
        'Breathe steadily throughout',
        'Move slowly and controlled',
      ];
    } catch (e) {
      print('Error getting exercise tips: $e');
      return [
        'Focus on proper form',
        'Don\'t rush the movement',
        'Listen to your body',
      ];
    }
  }
  
  // Check if API key is configured
  bool get hasApiKey => _apiKey != 'YOUR_GEMINI_API_KEY' && _apiKey.isNotEmpty;
  
  // Get initialization status
  bool get isInitialized => _isInitialized;
}

// AI Chat Message Model
class AIChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  
  AIChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}
