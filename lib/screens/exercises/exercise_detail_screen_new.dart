import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../models/exercise.dart';
import '../../providers/health_provider.dart';
import '../../theme/app_theme.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;
  
  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _exerciseTimer;
  int _currentStep = 0;
  int _remainingSeconds = 0;
  bool _isExercising = false;
  bool _isCompleted = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _remainingSeconds = widget.exercise.duration.inSeconds;
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _exerciseTimer?.cancel();
    super.dispose();
  }
  
  void _startExercise() {
    setState(() {
      _isExercising = true;
      _currentStep = 0;
    });
    
    _animationController.repeat();
    
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          
          // Move to next step based on progress
          final stepDuration = widget.exercise.duration.inSeconds ~/
              widget.exercise.instructions.length;
          final newStep = (widget.exercise.duration.inSeconds - _remainingSeconds) ~/
              stepDuration;
          if (newStep != _currentStep &&
              newStep < widget.exercise.instructions.length) {
            _currentStep = newStep;
            HapticFeedback.lightImpact();
          }
        } else {
          _completeExercise();
        }
      });
    });
  }
  
  void _pauseExercise() {
    setState(() {
      _isExercising = false;
    });
    _exerciseTimer?.cancel();
    _animationController.stop();
  }
  
  void _completeExercise() {
    _exerciseTimer?.cancel();
    _animationController.stop();
    
    setState(() {
      _isExercising = false;
      _isCompleted = true;
    });
    
    // Mark exercise as completed
    context.read<HealthProvider>().completeExercise(widget.exercise);
    
    HapticFeedback.heavyImpact();
    
    // Show completion dialog
    _showCompletionDialog();
  }
  
  void _resetExercise() {
    setState(() {
      _remainingSeconds = widget.exercise.duration.inSeconds;
      _currentStep = 0;
      _isExercising = false;
      _isCompleted = false;
    });
    _animationController.reset();
  }
  
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF10B981),
                    size: 36,
                  ),
                ).animate().scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 400.ms,
                  curve: Curves.easeOut,
                ),
                const SizedBox(height: 20),
                Text(
                  'Great Job!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'ve completed ${widget.exercise.name}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.exercise.caloriesBurned} calories burned',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFBBF24),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _resetExercise();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Repeat',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                          foregroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Finish',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final progress = 1 - (_remainingSeconds / widget.exercise.duration.inSeconds);
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Minimal Header
            _buildHeader(isDarkMode),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise Visual
                    _buildExerciseVisual(isDarkMode),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Stats
                    _buildQuickStats(isDarkMode),
                    
                    const SizedBox(height: 24),
                    
                    // Instructions Section
                    _buildInstructionsSection(isDarkMode),
                    
                    const SizedBox(height: 20),
                    
                    // Benefits Section
                    if (widget.exercise.benefits.isNotEmpty) ...[
                      _buildBenefitsSection(isDarkMode),
                      const SizedBox(height: 20),
                    ],
                    
                    // Timer Section (when exercising)
                    if (_isExercising || _isCompleted) ...[
                      _buildTimerSection(isDarkMode, progress),
                      const SizedBox(height: 20),
                    ],
                    
                    const SizedBox(height: 80), // Space for button
                  ],
                ),
              ),
            ),
            
            // Bottom Action Button
            _buildBottomAction(isDarkMode),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.exercise.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.exercise.category.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }
  
  Widget _buildExerciseVisual(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDarkMode ? Colors.grey[900]! : Colors.white),
                (isDarkMode ? Colors.grey[850]! : Colors.grey[50]!),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circles
                if (_isExercising) ...[
                  Container(
                    width: 120 + (_animationController.value * 20),
                    height: 120 + (_animationController.value * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor.withOpacity(0.05),
                    ),
                  ),
                  Container(
                    width: 100 + (_animationController.value * 15),
                    height: 100 + (_animationController.value * 15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor.withOpacity(0.08),
                    ),
                  ),
                ],
                
                // Main icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Exercise.getCategoryIcon(widget.exercise.category),
                    size: 36,
                    color: AppTheme.primaryColor,
                  ),
                ),
                
                // Step indicator
                if (_isExercising)
                  Positioned(
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Step ${_currentStep + 1} of ${widget.exercise.instructions.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.95, 0.95));
  }
  
  Widget _buildQuickStats(bool isDarkMode) {
    return Row(
      children: [
        _buildStatChip(
          Icons.timer_outlined,
          '${widget.exercise.duration.inMinutes} min',
          isDarkMode,
        ),
        const SizedBox(width: 12),
        _buildStatChip(
          Icons.local_fire_department_outlined,
          '${widget.exercise.caloriesBurned} cal',
          isDarkMode,
        ),
        const SizedBox(width: 12),
        _buildStatChip(
          Icons.fitness_center,
          widget.exercise.difficulty.name,
          isDarkMode,
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.05, end: 0);
  }
  
  Widget _buildStatChip(IconData icon, String label, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInstructionsSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Instructions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.exercise.instructions.asMap().entries.map((entry) {
          final index = entry.key;
          final instruction = entry.value;
          final isActive = index == _currentStep && _isExercising;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : (isDarkMode ? Colors.grey[900] : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? AppTheme.primaryColor.withOpacity(0.3)
                    : (isDarkMode ? Colors.grey[800]! : Colors.grey[200]!),
                width: isActive ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.primaryColor
                        : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? Colors.white
                            : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    instruction,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: isActive
                          ? (isDarkMode ? Colors.white : const Color(0xFF1A1A1A))
                          : (isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }
  
  Widget _buildBenefitsSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Benefits',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.exercise.benefits.map((benefit) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    benefit,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }
  
  Widget _buildTimerSection(bool isDarkMode, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          Text(
            _formatTime(_remainingSeconds),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _isCompleted
                    ? const Color(0xFF10B981)
                    : AppTheme.primaryColor,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }
  
  Widget _buildBottomAction(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: _isExercising
            ? Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pauseExercise,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
                        foregroundColor: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Pause',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _resetExercise,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Stop',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: _startExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  foregroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isCompleted ? 'Start Again' : 'Start Exercise',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }
}
