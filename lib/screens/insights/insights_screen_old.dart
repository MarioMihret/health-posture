import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../providers/posture_provider.dart';
import '../../providers/health_provider.dart';
import '../../models/posture_data.dart';
import '../../models/health_data.dart';
import '../../theme/app_theme.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Today';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final postureProvider = context.watch<PostureProvider>();
    final healthProvider = context.watch<HealthProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Insights'),
        backgroundColor: Colors.transparent,
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Today', child: Text('Today')),
              const PopupMenuItem(value: 'Week', child: Text('This Week')),
              const PopupMenuItem(value: 'Month', child: Text('This Month')),
            ],
            child: Chip(
              label: Text(_selectedPeriod),
              avatar: const Icon(Icons.calendar_today, size: 16),
            ),
          ),
          const SizedBox(width: 16),
        ],
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall Health Score
              _buildOverallHealthScore(
                healthProvider.overallHealthScore,
                isDarkMode,
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 24),
              
              // Quick Stats Grid
              _buildQuickStats(
                postureProvider,
                healthProvider,
                isDarkMode,
              ).animate().fadeIn(delay: 100.ms),
              
              const SizedBox(height: 24),
              
              // Posture Chart
              Text(
                'Posture Trend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              _buildPostureChart(
                postureProvider.postureHistory,
                isDarkMode,
              ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
              
              const SizedBox(height: 24),
              
              // Daily Goals Progress
              Text(
                'Daily Goals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              _buildDailyGoals(
                healthProvider,
                isDarkMode,
              ).animate().fadeIn(delay: 300.ms),
              
              const SizedBox(height: 24),
              
              // Recent Insights
              Text(
                'Recent Insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              ...healthProvider.insights.map((insight) {
                return _buildInsightCard(insight, isDarkMode)
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .slideX(begin: 0.1, end: 0);
              }),
              
              const SizedBox(height: 24),
              
              // Tips and Recommendations
              _buildTipsSection(isDarkMode)
                  .animate()
                  .fadeIn(delay: 500.ms)
                  .slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildOverallHealthScore(double score, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.8),
            AppTheme.secondaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Overall Health Score',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          CircularPercentIndicator(
            radius: 60.0,
            lineWidth: 12.0,
            animation: true,
            percent: score / 100,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${score.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'points',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Colors.white,
            backgroundColor: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            _getHealthScoreMessage(score),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getHealthScoreMessage(double score) {
    if (score >= 80) {
      return 'Excellent! Keep up the great work!';
    } else if (score >= 60) {
      return 'Good job! Room for improvement.';
    } else if (score >= 40) {
      return 'Fair. Let\'s work on healthier habits.';
    } else {
      return 'Needs attention. Start with small steps!';
    }
  }
  
  Widget _buildQuickStats(
    PostureProvider postureProvider,
    HealthProvider healthProvider,
    bool isDarkMode,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Good Posture',
          '${postureProvider.todayGoodPosturePercentage.toStringAsFixed(0)}%',
          Icons.trending_up,
          AppTheme.successColor,
          isDarkMode,
        ),
        _buildStatCard(
          'Hydration',
          '${healthProvider.waterIntake}ml',
          Icons.water_drop,
          AppTheme.secondaryColor,
          isDarkMode,
        ),
        _buildStatCard(
          'Exercises',
          '${healthProvider.exercisesCompleted}',
          Icons.fitness_center,
          AppTheme.primaryColor,
          isDarkMode,
        ),
        _buildStatCard(
          'Streak',
          '${healthProvider.exerciseStreak} days',
          Icons.local_fire_department,
          AppTheme.warningColor,
          isDarkMode,
        ),
      ],
    );
  }
  
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPostureChart(List<PostureData> history, bool isDarkMode) {
    if (history.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkSurface : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No posture data available yet',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
      );
    }
    
    // Prepare data for chart
    final spots = <FlSpot>[];
    final recentHistory = history.length > 20
        ? history.sublist(history.length - 20)
        : history;
    
    for (int i = 0; i < recentHistory.length; i++) {
      spots.add(FlSpot(i.toDouble(), recentHistory[i].score));
    }
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 20,
            verticalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
            ),
          ),
          minX: 0,
          maxX: spots.length.toDouble() - 1,
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.secondaryColor,
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.2),
                    AppTheme.secondaryColor.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDailyGoals(HealthProvider healthProvider, bool isDarkMode) {
    return Column(
      children: [
        _buildGoalItem(
          'Water Intake',
          Icons.water_drop,
          AppTheme.secondaryColor,
          healthProvider.waterProgress,
          '${healthProvider.waterIntake} / ${healthProvider.waterGoal}ml',
          isDarkMode,
        ),
        const SizedBox(height: 12),
        _buildGoalItem(
          'Exercises',
          Icons.fitness_center,
          AppTheme.primaryColor,
          healthProvider.exercisesCompleted / 5,
          '${healthProvider.exercisesCompleted} / 5',
          isDarkMode,
        ),
        const SizedBox(height: 12),
        _buildGoalItem(
          'Breaks',
          Icons.pause_circle,
          AppTheme.warningColor,
          healthProvider.breaksProgress,
          '${healthProvider.breaksTaken} / ${healthProvider.breaksGoal}',
          isDarkMode,
        ),
      ],
    );
  }
  
  Widget _buildGoalItem(
    String title,
    IconData icon,
    Color color,
    double progress,
    String progressText,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      progressText,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInsightCard(HealthInsight insight, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: insight.getColor().withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: insight.getColor().withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              insight.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (insight.actionText != null)
            TextButton(
              onPressed: insight.action,
              child: Text(insight.actionText!),
            ),
        ],
      ),
    );
  }
  
  Widget _buildTipsSection(bool isDarkMode) {
    final tips = [
      'Take a 5-minute break every 30 minutes',
      'Keep your screen at eye level',
      'Maintain a 90-degree angle at your elbows',
      'Keep feet flat on the floor',
      'Drink water regularly throughout the day',
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                  const Color(0xFF3B82F6).withOpacity(0.1),
                ]
              : [
                  const Color(0xFF8B5CF6).withOpacity(0.05),
                  const Color(0xFF3B82F6).withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppTheme.warningColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Health Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '•',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
