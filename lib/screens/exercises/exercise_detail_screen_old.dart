import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
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
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration,
                  color: AppTheme.successColor,
                  size: 40,
                ),
              ).animate().scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: 16),
              const Text(
                'Exercise Completed!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You burned ${widget.exercise.caloriesBurned} calories',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetExercise();
              },
              child: const Text('Do Again'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
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
    final progress = 1 -
        (_remainingSeconds / widget.exercise.duration.inSeconds);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [AppTheme.darkBackground, const Color(0xFF1E293B)]
                : [AppTheme.lightBackground, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise animation/image placeholder
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Exercise.getCategoryColor(widget.exercise.category)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isExercising
                            ? 1.0 + (_animationController.value * 0.1)
                            : 1.0,
                        child: Icon(
                          Exercise.getCategoryIcon(widget.exercise.category),
                          size: 80,
                          color: Exercise.getCategoryColor(
                              widget.exercise.category),
                        ),
                      );
                    },
                  ),
                ),
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 24),
              
              // Exercise info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(
                    Icons.timer,
                    'Duration',
                    '${widget.exercise.duration.inMinutes} min',
                    Colors.blue,
                  ),
                  _buildInfoItem(
                    Icons.local_fire_department,
                    'Calories',
                    '${widget.exercise.caloriesBurned}',
                    Colors.orange,
                  ),
                  _buildInfoItem(
                    Icons.signal_cellular_alt,
                    'Difficulty',
                    widget.exercise.difficulty.name,
                    Exercise.getDifficultyColor(widget.exercise.difficulty),
                  ),
                ].animate(interval: 100.ms).fadeIn().slideY(begin: 0.2, end: 0),
              ),
              
              const SizedBox(height: 24),
              
              // Timer and progress
              if (_isExercising || _isCompleted) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _formatTime(_remainingSeconds),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isCompleted
                              ? AppTheme.successColor
                              : Exercise.getCategoryColor(
                                  widget.exercise.category),
                        ),
                        minHeight: 8,
                      ),
                    ],
                  ),
                ).animate().fadeIn().scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                    ),
                const SizedBox(height: 24),
              ],
              
              // Description
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.exercise.description,
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.grey[300]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 16),
              
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                              ? Exercise.getCategoryColor(
                                      widget.exercise.category)
                                  .withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? Exercise.getCategoryColor(
                                    widget.exercise.category)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Exercise.getCategoryColor(
                                        widget.exercise.category)
                                    : Colors.grey.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isActive
                                        ? Colors.white
                                        : isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                instruction,
                                style: TextStyle(
                                  fontWeight:
                                      isActive ? FontWeight.w600 : null,
                                  color: isActive
                                      ? null
                                      : isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 16),
              
              // Benefits
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Benefits',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.exercise.benefits.map((benefit) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppTheme.successColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                benefit,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey[300]
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 24),
              
              // Control buttons
              Row(
                children: [
                  if (!_isExercising && !_isCompleted)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _startExercise,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text(
                          'Start Exercise',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Exercise.getCategoryColor(
                              widget.exercise.category),
                        ),
                      ),
                    )
                  else if (_isExercising) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pauseExercise,
                        icon: const Icon(Icons.pause),
                        label: const Text(
                          'Pause',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _completeExercise,
                        icon: const Icon(Icons.stop),
                        label: const Text(
                          'Complete',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppTheme.successColor,
                        ),
                      ),
                    ),
                  ] else if (_isCompleted) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _resetExercise,
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          'Do Again',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.check),
                        label: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppTheme.successColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
