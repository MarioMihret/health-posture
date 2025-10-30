import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/exercise.dart';
import '../../providers/health_provider.dart';
import '../../theme/app_theme.dart';
import 'exercise_detail_screen.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  String _selectedFilter = 'all';
  ExerciseCategory? _selectedCategory;
  List<Exercise> _filteredExercises = ExerciseDatabase.exercises;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _filterExercises();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _filterExercises() {
    setState(() {
      if (_selectedFilter == 'all') {
        _filteredExercises = _selectedCategory == null 
            ? ExerciseDatabase.exercises
            : ExerciseDatabase.exercises
                .where((e) => e.category == _selectedCategory)
                .toList();
      } else if (_selectedFilter == 'quick') {
        _filteredExercises = ExerciseDatabase.getQuickExercises();
      } else if (_selectedFilter == 'favorites') {
        // Filter favorites (for demo, just show first 3)
        _filteredExercises = ExerciseDatabase.exercises.take(3).toList();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final healthProvider = context.watch<HealthProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Minimal Header
            _buildHeader(isDarkMode),
            
            // Filter Pills
            _buildFilterSection(isDarkMode),
            
            // Exercise Grid/List
            Expanded(
              child: _buildExerciseContent(isDarkMode, healthProvider),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
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
                  'Exercises',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_filteredExercises.length} exercises available',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // Stats Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.grey[900] 
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '3',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }
  
  Widget _buildFilterSection(bool isDarkMode) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _buildFilterPill('All', 'all', isDarkMode),
          _buildFilterPill('Quick', 'quick', isDarkMode),
          _buildFilterPill('Favorites', 'favorites', isDarkMode),
          const SizedBox(width: 16),
          _buildCategoryDropdown(isDarkMode),
        ],
      ),
    );
  }
  
  Widget _buildFilterPill(String label, String value, bool isDarkMode) {
    final isSelected = _selectedFilter == value;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedFilter = value;
            });
            _filterExercises();
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDarkMode ? Colors.white : const Color(0xFF1A1A1A))
                  : (isDarkMode ? Colors.grey[900] : Colors.white),
              borderRadius: BorderRadius.circular(24),
              border: !isSelected
                  ? Border.all(
                      color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                    )
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? (isDarkMode ? const Color(0xFF1A1A1A) : Colors.white)
                    : (isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (100).ms).slideX(begin: 0.1, end: 0);
  }
  
  Widget _buildCategoryDropdown(bool isDarkMode) {
    return PopupMenuButton<ExerciseCategory?>(
      onSelected: (category) {
        setState(() {
          _selectedCategory = category;
        });
        _filterExercises();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: null,
          child: Text('All Categories'),
        ),
        ...ExerciseCategory.values.map((category) => PopupMenuItem(
          value: category,
          child: Row(
            children: [
              Icon(Exercise.getCategoryIcon(category), size: 18),
              const SizedBox(width: 8),
              Text(category.name),
            ],
          ),
        )),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _selectedCategory != null
                ? AppTheme.primaryColor.withOpacity(0.5)
                : (isDarkMode ? Colors.grey[800]! : Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            Icon(
              _selectedCategory != null
                  ? Exercise.getCategoryIcon(_selectedCategory!)
                  : Icons.filter_list,
              size: 16,
              color: _selectedCategory != null
                  ? AppTheme.primaryColor
                  : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(width: 6),
            Text(
              _selectedCategory?.name ?? 'Category',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _selectedCategory != null
                    ? AppTheme.primaryColor
                    : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
  
  Widget _buildExerciseContent(bool isDarkMode, HealthProvider healthProvider) {
    if (_filteredExercises.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      itemCount: _filteredExercises.length,
      itemBuilder: (context, index) {
        final exercise = _filteredExercises[index];
        return _buildExerciseCard(exercise, index, isDarkMode);
      },
    );
  }
  
  Widget _buildExerciseCard(Exercise exercise, int index, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExerciseDetailScreen(exercise: exercise),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode ? Colors.grey[850]! : Colors.grey[100]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Exercise Icon/Image
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Exercise.getDifficultyColor(exercise.difficulty).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Exercise.getCategoryIcon(exercise.category),
                    size: 24,
                    color: Exercise.getDifficultyColor(exercise.difficulty).withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Exercise Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.timer_outlined,
                            '${exercise.duration.inMinutes}min',
                            isDarkMode,
                          ),
                          const SizedBox(width: 12),
                          _buildInfoChip(
                            Icons.local_fire_department_outlined,
                            '${exercise.caloriesBurned} cal',
                            isDarkMode,
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(exercise.difficulty).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              exercise.difficulty.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getDifficultyColor(exercise.difficulty),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
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
      ),
    ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.05, end: 0);
  }
  
  Widget _buildInfoChip(IconData icon, String label, bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 32,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }
  
  Color _getDifficultyColor(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return const Color(0xFF4ADE80);
      case ExerciseDifficulty.medium:
        return const Color(0xFFFBBF24);
      case ExerciseDifficulty.hard:
        return const Color(0xFFF87171);
    }
  }
}
