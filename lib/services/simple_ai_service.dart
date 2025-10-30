import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/health_data.dart';

class SimpleAIService {
  static const String _apiKey = 'AIzaSyBsBOcXBoUX0V9YMz8pB4sBGH5fIAZ9YX4';
  String? _workingModel;
  
  // Singleton pattern
  static final SimpleAIService _instance = SimpleAIService._internal();
  factory SimpleAIService() => _instance;
  SimpleAIService._internal() {
    _findWorkingModel();
  }
  
  // Try to find a working model
  Future<void> _findWorkingModel() async {
    // List of models to try in order
    final modelsToTry = [
      'gemini-pro',
      'gemini-1.0-pro', 
      'gemini-1.5-flash',
      'gemini-1.5-pro',
      'text-bison-001',
      'chat-bison-001',
    ];
    
    for (final model in modelsToTry) {
      try {
        final testUrl = 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$_apiKey';
        final response = await http.post(
          Uri.parse(testUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [{'parts': [{'text': 'test'}]}],
            'generationConfig': {'temperature': 0.1, 'maxOutputTokens': 10}
          }),
        );
        
        if (response.statusCode == 200) {
          _workingModel = model;
          print('Found working model: $model');
          return;
        }
      } catch (e) {
        // Try next model
      }
    }
    print('No working models found. Using default.');
    _workingModel = 'gemini-pro'; // Default fallback
  }
  
  // Simple chat method using HTTP directly
  Future<String> sendMessage(String message) async {
    // Ensure we have a model
    if (_workingModel == null) {
      await _findWorkingModel();
    }
    
    final model = _workingModel ?? 'gemini-pro';
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$_apiKey';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': message}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            }
          ]
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return text ?? 'I couldn\'t generate a response. Please try again.';
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return 'I\'m having trouble connecting to the AI service. Please try again later.';
      }
    } catch (e) {
      print('Error calling AI: $e');
      return 'I encountered an error. Please try again.';
    }
  }
  
  // Simplified health insight generation
  Future<HealthInsight> generateHealthInsight({
    required double postureScore,
    required int exercisesCompleted,
    required int waterIntake,
  }) async {
    final prompt = '''
You are a health assistant. Based on these stats:
- Posture score: ${postureScore.toStringAsFixed(1)}%
- Exercises today: $exercisesCompleted
- Water intake: ${waterIntake}ml

Provide ONE brief health tip (max 15 words).
''';
    
    final response = await sendMessage(prompt);
    
    InsightType type = InsightType.info;
    if (postureScore >= 80 && exercisesCompleted >= 3) {
      type = InsightType.success;
    } else if (postureScore < 60 || exercisesCompleted == 0) {
      type = InsightType.warning;
    }
    
    return HealthInsight(
      title: 'Health Tip',
      description: response.length > 50 ? response.substring(0, 50) + '...' : response,
      type: type,
      icon: 'lightbulb',
    );
  }
  
  // Check if API key is configured
  bool get hasApiKey => _apiKey.isNotEmpty && _apiKey != 'YOUR_API_KEY';
}
