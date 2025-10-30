import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../../models/exercise.dart';
import '../../providers/health_provider.dart';
import '../../theme/app_theme.dart';
import 'exercise_detail_screen.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ExerciseCategory? _selectedCategory;
  ExerciseDifficulty? _selectedDifficulty;
  List<Exercise> _filteredExercises = ExerciseDatabase.exercises;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filterExercises();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _filterExercises() {
    setState(() {
      _filteredExercises = ExerciseDatabase.exercises.where((exercise) {
        final categoryMatch = _selectedCategory == null ||
            exercise.category == _selectedCategory;
        final difficultyMatch = _selectedDifficulty == null ||
            exercise.difficulty == _selectedDifficulty;
        return categoryMatch && difficultyMatch;
      }).toList();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final healthProvider = context.watch<HealthProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.grid_view)),
            Tab(text: 'Quick', icon: Icon(Icons.flash_on)),
            Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
          ],
        ),
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
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAllExercises(),
            _buildQuickExercises(),
            _buildCompletedExercises(healthProvider),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAllExercises() {
    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Category filter
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_selectedCategory?.name ?? 'All Categories'),
                    selected: _selectedCategory != null,
                    onSelected: (_) => _showCategoryFilter(),
                    avatar: Icon(
                      _selectedCategory != null
                          ? Exercise.getCategoryIcon(_selectedCategory!)
                          : Icons.category,
                      size: 18,
                    ),
                  ),
                ).animate().fadeIn(delay: 100.ms),
                
                // Difficulty filter
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_selectedDifficulty?.name ?? 'All Levels'),
                    selected: _selectedDifficulty != null,
                    onSelected: (_) => _showDifficultyFilter(),
                    avatar: const Icon(Icons.signal_cellular_alt, size: 18),
                  ),
                ).animate().fadeIn(delay: 150.ms),
                
                // Clear filters
                if (_selectedCategory != null || _selectedDifficulty != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                        _selectedDifficulty = null;
                      });
                      _filterExercises();
                    },
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear filters',
                  ).animate().fadeIn(delay: 200.ms),
              ],
            ),
          ),
        ),
        
        // Exercise list
        Expanded(
          child: _filteredExercises.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _filteredExercises[index];
                    return _buildExerciseCard(exercise, index);
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildQuickExercises() {
    final quickExercises = ExerciseDatabase.getQuickExercises();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quickExercises.length,
      itemBuilder: (context, index) {
        final exercise = quickExercises[index];
        return _buildExerciseCard(exercise, index, isQuick: true);
      },
    );
  }
  
  Widget _buildCompletedExercises(HealthProvider healthProvider) {
    if (healthProvider.completedExercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No exercises completed yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start exercising to see your progress here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ).animate().fadeIn().slideY(begin: 0.2, end: 0),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: healthProvider.completedExercises.length,
      itemBuilder: (context, index) {
        final exercise = healthProvider.completedExercises[
            healthProvider.completedExercises.length - 1 - index
        ];
        return _buildExerciseCard(exercise, index, isCompleted: true);
      },
    );
  }
  
  Widget _buildExerciseCard(
    Exercise exercise,
    int index, {
    bool isQuick = false,
    bool isCompleted = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseDetailScreen(exercise: exercise),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Exercise icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Exercise.getCategoryColor(exercise.category)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Exercise.getCategoryIcon(exercise.category),
                  color: Exercise.getCategoryColor(exercise.category),
                  size: 30,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Exercise details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            exercise.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isCompleted)
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.successColor,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Duration
                        _buildInfoChip(
                          Icons.timer,
                          '${exercise.duration.inMinutes}min',
                          Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        // Difficulty
                        _buildInfoChip(
                          Icons.signal_cellular_alt,
                          exercise.difficulty.name,
                          Exercise.getDifficultyColor(exercise.difficulty),
                        ),
                        const SizedBox(width: 8),
                        // Calories
                        _buildInfoChip(
                          Icons.local_fire_department,
                          '${exercise.caloriesBurned} cal',
                          Colors.orange,
                        ),
                        if (isQuick) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.warningColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flash_on,
                                  size: 12,
                                  color: AppTheme.warningColor,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Quick',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.warningColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.2, end: 0);
  }
  
  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ).animate().fadeIn().slideY(begin: 0.2, end: 0),
    );
  }
  
  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    label: const Text('All'),
                    onPressed: () {
                      setState(() => _selectedCategory = null);
                      _filterExercises();
                      Navigator.pop(context);
                    },
                  ),
                  ...ExerciseCategory.values.map((category) {
                    return ActionChip(
                      avatar: Icon(
                        Exercise.getCategoryIcon(category),
                        size: 18,
                      ),
                      label: Text(category.name),
                      backgroundColor: _selectedCategory == category
                          ? Exercise.getCategoryColor(category)
                              .withOpacity(0.2)
                          : null,
                      onPressed: () {
                        setState(() => _selectedCategory = category);
                        _filterExercises();
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
  
  void _showDifficultyFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Difficulty',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    label: const Text('All Levels'),
                    onPressed: () {
                      setState(() => _selectedDifficulty = null);
                      _filterExercises();
                      Navigator.pop(context);
                    },
                  ),
                  ...ExerciseDifficulty.values.map((difficulty) {
                    return ActionChip(
                      label: Text(difficulty.name),
                      backgroundColor: _selectedDifficulty == difficulty
                          ? Exercise.getDifficultyColor(difficulty)
                              .withOpacity(0.2)
                          : null,
                      onPressed: () {
                        setState(() => _selectedDifficulty = difficulty);
                        _filterExercises();
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
