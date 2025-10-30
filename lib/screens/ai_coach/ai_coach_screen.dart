import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/local_ai_service.dart';
import '../../providers/health_provider.dart';
import '../../providers/posture_provider.dart';
import '../../theme/app_theme.dart';

// Simple chat message model
class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  
  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  final LocalAIService _aiService = LocalAIService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isAIReady = true; // Simplified - always ready

  @override
  void initState() {
    super.initState();
    _initializeAI();
    _addWelcomeMessage();
  }

  Future<void> _initializeAI() async {
    if (!_aiService.hasApiKey) {
      _showApiKeyDialog();
      setState(() {
        _isAIReady = false;
      });
    }
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          message: "Hi! I'm your posture health assistant. I can help you with:\n• Posture improvement tips\n• Desk exercise recommendations\n• Pain management advice\n• Hydration reminders\n• Motivation and encouragement\n\nHow can I help you today?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _showApiKeyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('AI Setup Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('To use the AI coach, you need to add your Google Gemini API key.'),
            const SizedBox(height: 16),
            const Text('Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('1. Get a free API key from:'),
            const SelectableText(
              'https://makersuite.google.com/app/apikey',
              style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
            ),
            const SizedBox(height: 8),
            const Text('2. Add it to lib/services/ai_service.dart'),
            const SizedBox(height: 8),
            const Text('3. Restart the app'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || !_isAIReady) return;

    setState(() {
      _messages.add(
        ChatMessage(
          message: message,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _messageController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await _aiService.sendMessage(message);
      setState(() {
        _messages.add(
          ChatMessage(
            message: response,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Failed to get response. Please try again.');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _getQuickSuggestion(String type) async {
    final healthProvider = context.read<HealthProvider>();
    final postureProvider = context.read<PostureProvider>();

    setState(() {
      _isLoading = true;
    });

    try {
      String prompt = '';
      
      switch (type) {
        case 'exercise':
          prompt = "Recommend 3 specific exercises for someone with ${postureProvider.postureScore.toStringAsFixed(0)}% posture score. Keep it brief.";
          break;
          
        case 'analysis':
          prompt = "Analyze: Posture score ${postureProvider.postureScore.toStringAsFixed(0)}%, ${healthProvider.exercisesCompleted} exercises today. Give brief feedback.";
          break;
          
        case 'motivation':
          prompt = "Give a short motivational quote for someone on a ${healthProvider.exerciseStreak} day exercise streak.";
          break;
          
        case 'tips':
          prompt = "Give me 3 quick tips to improve my posture right now while working at my desk.";
          break;
          
        case 'hydration':
          prompt = "Give me advice about staying hydrated and why it's important for posture health.";
          break;
      }

      final response = await _aiService.sendMessage(prompt);
      
      setState(() {
        _messages.add(
          ChatMessage(
            message: response,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add(
          ChatMessage(
            message: "I'm having trouble connecting. Please check your internet connection and try again.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.8),
                    AppTheme.primaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AI Assistant',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isAIReady ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isAIReady ? 'Ready to help' : 'Connecting...',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDarkMode ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_outlined),
            onPressed: () {
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
            },
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick action chips with gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDarkMode
                  ? [const Color(0xFF0A0A0A), const Color(0xFF0A0A0A).withOpacity(0)]
                  : [const Color(0xFFFAFAFA), const Color(0xFFFAFAFA).withOpacity(0)],
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  _buildEnhancedChip('💪', 'Exercises', 'exercise', isDarkMode),
                  const SizedBox(width: 10),
                  _buildEnhancedChip('📊', 'Analysis', 'analysis', isDarkMode),
                  const SizedBox(width: 10),
                  _buildEnhancedChip('✨', 'Motivation', 'motivation', isDarkMode),
                  const SizedBox(width: 10),
                  _buildEnhancedChip('💡', 'Tips', 'tips', isDarkMode),
                  const SizedBox(width: 10),
                  _buildEnhancedChip('💧', 'Hydration', 'hydration', isDarkMode),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
          
          // Chat messages or empty state
          Expanded(
            child: _messages.length <= 1 && !_isLoading
              ? _buildEmptyState(isDarkMode)
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isLoading) {
                      return _buildTypingIndicator(isDarkMode);
                    }
                    return _buildMessage(_messages[index], isDarkMode);
                  },
                ),
          ),
          
          // Input field
          _buildInputField(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Welcome illustration
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.primaryColor.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology,
              size: 60,
              color: AppTheme.primaryColor,
            ),
          ).animate()
            .scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.easeOut)
            .fadeIn(duration: 500.ms),
          
          const SizedBox(height: 20),
          
          // Welcome text
          Text(
            'Hello! I\'m Your Health Assistant',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 8),
          
          Text(
            'Ask me anything about posture, exercises, or health',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white60 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
          
          const SizedBox(height: 32),
          
          // Suggested questions
          Text(
            'Try asking:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ).animate().fadeIn(delay: 400.ms),
          
          const SizedBox(height: 16),
          
          ..._getSuggestedQuestions().map((question) => 
            _buildSuggestedQuestion(question, isDarkMode)
          ).toList(),
        ],
      ),
    );
  }
  
  List<String> _getSuggestedQuestions() {
    return [
      'How can I improve my posture while working?',
      'What exercises help with back pain?',
      'How often should I take breaks?',
      'Why is hydration important for posture?',
      'Can you create a daily exercise routine for me?',
    ];
  }
  
  Widget _buildSuggestedQuestion(String question, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _messageController.text = question;
            _sendMessage();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode 
                ? const Color(0xFF2A2A2A)
                : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode 
                  ? Colors.grey[700]!.withOpacity(0.5)
                  : Colors.grey[300]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 18,
                  color: AppTheme.primaryColor.withOpacity(0.7),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: isDarkMode ? Colors.white30 : Colors.black26,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(delay: Duration(milliseconds: 500 + _getSuggestedQuestions().indexOf(question) * 100))
      .slideX(begin: -0.1, end: 0);
  }

  Widget _buildEnhancedChip(String emoji, String label, String type, bool isDarkMode) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isAIReady ? () => _getQuickSuggestion(type) : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.1),
                AppTheme.primaryColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .scale(begin: const Offset(0.9, 0.9), duration: 300.ms, curve: Curves.easeOut)
      .fadeIn(duration: 300.ms);
  }
  
  Widget _buildMessage(ChatMessage message, bool isDarkMode) {
    final isUser = message.isUser;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isUser ? 50 : 8,
          right: isUser ? 8 : 50,
          top: 4,
          bottom: 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.psychology,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isUser
                    ? AppTheme.primaryColor
                    : isDarkMode 
                      ? const Color(0xFF2A2A2A)
                      : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: isUser 
                      ? const Radius.circular(20) 
                      : const Radius.circular(4),
                    bottomRight: isUser 
                      ? const Radius.circular(4) 
                      : const Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.message,
                      style: TextStyle(
                        color: isUser 
                          ? Colors.white 
                          : isDarkMode 
                            ? Colors.white 
                            : const Color(0xFF1A1A1A),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: isUser 
                          ? Colors.white70 
                          : isDarkMode 
                            ? Colors.grey[600] 
                            : Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isUser) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.3, end: 0, duration: 300.ms);
  }
  
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildTypingIndicator(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(left: 8, right: 50, top: 4, bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.psychology,
              size: 20,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ).animate(
                    onPlay: (controller) => controller.repeat(),
                    delay: Duration(milliseconds: i * 200),
                  ).scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.2, 1.2),
                    duration: 600.ms,
                    curve: Curves.easeInOut,
                  ).then()
                   .scale(
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(0.8, 0.8),
                    duration: 600.ms,
                    curve: Curves.easeInOut,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.add_circle_outline,
                color: AppTheme.primaryColor,
                size: 28,
              ),
            ),
            // Input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  enabled: _isAIReady,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: _isAIReady 
                      ? 'Ask about posture, exercises, health tips...' 
                      : 'Initializing assistant...',
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    suffixIcon: _messageController.text.isNotEmpty 
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: 20,
                            color: Colors.grey[500],
                          ),
                          onPressed: () {
                            setState(() {
                              _messageController.clear();
                            });
                          },
                        )
                      : null,
                  ),
                  onChanged: (value) {
                    setState(() {}); // To update clear button visibility
                  },
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: _messageController.text.isNotEmpty && _isAIReady && !_isLoading
                  ? AppTheme.primaryColor
                  : Colors.grey[400],
                borderRadius: BorderRadius.circular(50),
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: _messageController.text.isNotEmpty && _isAIReady && !_isLoading
                    ? _sendMessage
                    : null,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      _isLoading ? Icons.stop : Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
