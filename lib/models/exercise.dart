import 'package:flutter/material.dart';

enum ExerciseCategory {
  neck,
  shoulder,
  back,
  eyes,
  wrist,
  legs,
  fullBody,
}

enum ExerciseDifficulty {
  easy,
  medium,
  hard,
}

class Exercise {
  final String id;
  final String name;
  final String description;
  final ExerciseCategory category;
  final ExerciseDifficulty difficulty;
  final Duration duration;
  final List<String> instructions;
  final String? animationAsset;
  final String? imageAsset;
  final int caloriesBurned;
  final List<String> benefits;
  final List<String> targetMuscles;
  final bool requiresEquipment;
  final String motivationalQuote;
  
  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.duration,
    required this.instructions,
    this.animationAsset,
    this.imageAsset,
    required this.caloriesBurned,
    required this.benefits,
    required this.targetMuscles,
    this.requiresEquipment = false,
    required this.motivationalQuote,
  });
  
  // Get category color
  static Color getCategoryColor(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.neck:
        return const Color(0xFF8B5CF6);
      case ExerciseCategory.shoulder:
        return const Color(0xFF3B82F6);
      case ExerciseCategory.back:
        return const Color(0xFF10B981);
      case ExerciseCategory.eyes:
        return const Color(0xFF06B6D4);
      case ExerciseCategory.wrist:
        return const Color(0xFFF59E0B);
      case ExerciseCategory.legs:
        return const Color(0xFFEF4444);
      case ExerciseCategory.fullBody:
        return const Color(0xFFEC4899);
    }
  }
  
  // Get difficulty color
  static Color getDifficultyColor(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return const Color(0xFF10B981);
      case ExerciseDifficulty.medium:
        return const Color(0xFFF59E0B);
      case ExerciseDifficulty.hard:
        return const Color(0xFFEF4444);
    }
  }
  
  // Get category icon
  static IconData getCategoryIcon(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.neck:
        return Icons.face;
      case ExerciseCategory.shoulder:
        return Icons.accessibility_new;
      case ExerciseCategory.back:
        return Icons.airline_seat_recline_normal;
      case ExerciseCategory.eyes:
        return Icons.visibility;
      case ExerciseCategory.wrist:
        return Icons.pan_tool;
      case ExerciseCategory.legs:
        return Icons.directions_walk;
      case ExerciseCategory.fullBody:
        return Icons.fitness_center;
    }
  }
}

// Predefined exercises database
class ExerciseDatabase {
  static final List<Exercise> exercises = [
    // Neck exercises
    Exercise(
      id: 'neck_rotation',
      name: 'Neck Rotation',
      description: 'Slowly rotate your neck to relieve tension',
      category: ExerciseCategory.neck,
      difficulty: ExerciseDifficulty.easy,
      duration: const Duration(minutes: 2),
      instructions: [
        'Sit or stand with spine straight',
        'Slowly turn head to the right',
        'Hold for 10 seconds',
        'Return to center',
        'Turn head to the left',
        'Hold for 10 seconds',
        'Repeat 5 times each side',
      ],
      caloriesBurned: 5,
      benefits: ['Relieves neck tension', 'Improves flexibility', 'Reduces headaches'],
      targetMuscles: ['Neck muscles', 'Upper trapezius'],
      motivationalQuote: 'Your body is your temple. Keep it pure and clean for the soul to reside in.',
    ),
    
    // Shoulder exercises
    Exercise(
      id: 'shoulder_rolls',
      name: 'Shoulder Rolls',
      description: 'Roll your shoulders to release tension',
      category: ExerciseCategory.shoulder,
      difficulty: ExerciseDifficulty.easy,
      duration: const Duration(minutes: 1),
      instructions: [
        'Sit or stand with arms relaxed',
        'Lift shoulders up towards ears',
        'Roll shoulders backward in circular motion',
        'Complete 10 backward rolls',
        'Roll shoulders forward',
        'Complete 10 forward rolls',
      ],
      caloriesBurned: 3,
      benefits: ['Reduces shoulder tension', 'Improves circulation', 'Prevents stiffness'],
      targetMuscles: ['Shoulders', 'Upper back'],
      motivationalQuote: 'The only bad workout is the one that didn\'t happen. Keep moving!',
    ),
    
    // Back exercises
    Exercise(
      id: 'cat_cow_stretch',
      name: 'Cat-Cow Stretch',
      description: 'Gentle spine mobility exercise',
      category: ExerciseCategory.back,
      difficulty: ExerciseDifficulty.easy,
      duration: const Duration(minutes: 2),
      instructions: [
        'Stand with hands on desk',
        'Round your back upward (cat)',
        'Hold for 5 seconds',
        'Arch your back downward (cow)',
        'Hold for 5 seconds',
        'Repeat 10 times',
      ],
      caloriesBurned: 8,
      benefits: ['Improves spine flexibility', 'Relieves back pain', 'Strengthens core'],
      targetMuscles: ['Spine', 'Core', 'Back muscles'],
      motivationalQuote: 'A healthy spine is the key to a vibrant life. Invest in your posture today!',
    ),
    
    // Eye exercises
    Exercise(
      id: 'eye_palming',
      name: 'Eye Palming',
      description: 'Relax your eyes from screen strain',
      category: ExerciseCategory.eyes,
      difficulty: ExerciseDifficulty.easy,
      duration: const Duration(minutes: 1),
      instructions: [
        'Rub palms together to warm them',
        'Close your eyes',
        'Place palms over eyes gently',
        'Breathe deeply',
        'Hold for 30 seconds',
        'Remove hands slowly',
      ],
      caloriesBurned: 2,
      benefits: ['Reduces eye strain', 'Improves focus', 'Relaxes eye muscles'],
      targetMuscles: ['Eye muscles'],
      motivationalQuote: 'Give your eyes the rest they deserve. Vision is a gift worth protecting.',
    ),
    
    // Wrist exercises
    Exercise(
      id: 'wrist_circles',
      name: 'Wrist Circles',
      description: 'Prevent carpal tunnel syndrome',
      category: ExerciseCategory.wrist,
      difficulty: ExerciseDifficulty.easy,
      duration: const Duration(minutes: 1),
      instructions: [
        'Extend arms in front',
        'Make fists with both hands',
        'Rotate wrists clockwise 10 times',
        'Rotate wrists counter-clockwise 10 times',
        'Shake hands to relax',
      ],
      caloriesBurned: 2,
      benefits: ['Prevents RSI', 'Improves flexibility', 'Reduces wrist pain'],
      targetMuscles: ['Wrists', 'Forearms'],
      motivationalQuote: 'Small movements create big changes. Take care of your wrists, they carry your work.',
    ),
    
    // Leg exercises
    Exercise(
      id: 'desk_leg_lifts',
      name: 'Desk Leg Lifts',
      description: 'Strengthen legs while seated',
      category: ExerciseCategory.legs,
      difficulty: ExerciseDifficulty.medium,
      duration: const Duration(minutes: 2),
      instructions: [
        'Sit straight in chair',
        'Extend one leg straight out',
        'Hold for 5 seconds',
        'Lower slowly',
        'Repeat 10 times',
        'Switch to other leg',
      ],
      caloriesBurned: 10,
      benefits: ['Strengthens quadriceps', 'Improves circulation', 'Tones legs'],
      targetMuscles: ['Quadriceps', 'Hip flexors'],
      motivationalQuote: 'Strong legs carry you through life. Build your foundation one lift at a time.',
    ),
    
    // Full body
    Exercise(
      id: 'standing_stretch',
      name: 'Full Body Stretch',
      description: 'Complete body stretch routine',
      category: ExerciseCategory.fullBody,
      difficulty: ExerciseDifficulty.easy,
      duration: const Duration(minutes: 3),
      instructions: [
        'Stand up from chair',
        'Reach arms overhead',
        'Interlace fingers and stretch up',
        'Lean to right side, hold 10 seconds',
        'Lean to left side, hold 10 seconds',
        'Touch toes or reach toward floor',
        'Roll up slowly',
      ],
      caloriesBurned: 12,
      benefits: ['Improves flexibility', 'Boosts energy', 'Reduces stiffness'],
      targetMuscles: ['Full body'],
      motivationalQuote: 'Stretch your body, expand your mind. Every movement is progress!',
    ),
  ];
  
  // Get exercises by category
  static List<Exercise> getByCategory(ExerciseCategory category) {
    return exercises.where((e) => e.category == category).toList();
  }
  
  // Get exercises by difficulty
  static List<Exercise> getByDifficulty(ExerciseDifficulty difficulty) {
    return exercises.where((e) => e.difficulty == difficulty).toList();
  }
  
  // Get quick exercises (under 2 minutes)
  static List<Exercise> getQuickExercises() {
    return exercises.where((e) => e.duration.inMinutes <= 2).toList();
  }
}
