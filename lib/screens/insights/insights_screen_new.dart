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

class _InsightsScreenState extends State<InsightsScreen> {
  String _selectedPeriod = 'Week';
  int _selectedMetricIndex = 0;
  
  final List<String> _periods = ['Day', 'Week', 'Month', 'Year'];
  final List<Map<String, dynamic>> _metrics = [
    {'name': 'Posture', 'icon': Icons.accessibility_new},
    {'name': 'Activity', 'icon': Icons.directions_walk},
    {'name': 'Hydration', 'icon': Icons.water_drop_outlined},
    {'name': 'Wellness', 'icon': Icons.favorite_outline},
  ];
  
  @override
  Widget build(BuildContext context) {
    final postureProvider = context.watch<PostureProvider>();
    final healthProvider = context.watch<HealthProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            // Professional Header
            _buildHeader(isDarkMode),
            
            // Period Selector
            _buildPeriodSelector(isDarkMode),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Score Overview Card
                    _buildScoreOverview(healthProvider, postureProvider, isDarkMode),
                    
                    const SizedBox(height: 20),
                    
                    // Metrics Selector
                    _buildMetricsSelector(isDarkMode),
                    
                    const SizedBox(height: 20),
                    
                    // Main Chart
                    _buildMainChart(postureProvider, healthProvider, isDarkMode),
                    
                    const SizedBox(height: 20),
                    
                    // Statistics Grid
                    _buildStatisticsGrid(postureProvider, healthProvider, isDarkMode),
                    
                    const SizedBox(height: 20),
                    
                    // Insights Section
                    _buildInsightsSection(healthProvider, isDarkMode),
                    
                    const SizedBox(height: 20),
                    
                    // Recommendations
                    _buildRecommendations(isDarkMode),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Track your health progress',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => _showExportOptions(),
            icon: Icon(
              Icons.download_outlined,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }
  
  Widget _buildPeriodSelector(bool isDarkMode) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: _periods.map((period) {
          final isSelected = period == _selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: Container(
                margin: EdgeInsets.only(
                  right: period != _periods.last ? 8 : 0,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDarkMode ? Colors.white : const Color(0xFF1A1A1A))
                      : (isDarkMode ? Colors.grey[900] : Colors.white),
                  borderRadius: BorderRadius.circular(10),
                  border: !isSelected
                      ? Border.all(
                          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                          width: 1,
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    period,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? (isDarkMode ? const Color(0xFF1A1A1A) : Colors.white)
                          : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }
  
  Widget _buildScoreOverview(HealthProvider health, PostureProvider posture, bool isDarkMode) {
    final score = health.overallHealthScore;
    final trend = _calculateTrend(score);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[850]! : Colors.grey[100]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Score Circle
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(score),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        score.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        'Score',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Score Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Health Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(score).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatus(score),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(score),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getHealthMessage(score),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      trend > 0 ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: trend > 0 ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${trend.abs()}% from last period',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: trend > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95));
  }
  
  Widget _buildMetricsSelector(bool isDarkMode) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _metrics.length,
        itemBuilder: (context, index) {
          final metric = _metrics[index];
          final isSelected = index == _selectedMetricIndex;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedMetricIndex = index),
            child: Container(
              width: 80,
              margin: EdgeInsets.only(right: index < _metrics.length - 1 ? 12 : 0),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : (isDarkMode ? Colors.grey[900] : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor.withOpacity(0.3)
                      : (isDarkMode ? Colors.grey[800]! : Colors.grey[200]!),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    metric['icon'],
                    size: 24,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    metric['name'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
  
  Widget _buildMainChart(PostureProvider posture, HealthProvider health, bool isDarkMode) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[850]! : Colors.grey[100]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_metrics[_selectedMetricIndex]['name']} Trend',
                style: TextStyle(
                  fontSize: 14,
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
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Current',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Average',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDarkMode ? Colors.grey[850]! : Colors.grey[200]!,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: isDarkMode ? Colors.grey[600] : Colors.grey[500],
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: TextStyle(
                              fontSize: 10,
                              color: isDarkMode ? Colors.grey[600] : Colors.grey[500],
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  // Main line
                  LineChartBarData(
                    spots: _generateChartData(),
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: AppTheme.primaryColor,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryColor.withOpacity(0.1),
                    ),
                  ),
                  // Average line
                  LineChartBarData(
                    spots: List.generate(7, (i) => FlSpot(i.toDouble(), 65)),
                    isCurved: false,
                    color: Colors.grey,
                    barWidth: 1,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }
  
  Widget _buildStatisticsGrid(PostureProvider posture, HealthProvider health, bool isDarkMode) {
    final stats = [
      {
        'label': 'Avg. Posture',
        'value': '${posture.postureScore.toInt()}%',
        'icon': Icons.accessibility_new,
        'color': Colors.blue,
      },
      {
        'label': 'Water Intake',
        'value': '${health.waterIntake}ml',
        'icon': Icons.water_drop,
        'color': Colors.cyan,
      },
      {
        'label': 'Exercises',
        'value': '${health.exercisesCompleted}',
        'icon': Icons.fitness_center,
        'color': Colors.green,
      },
      {
        'label': 'Breaks Taken',
        'value': '${health.breaksTaken}',
        'icon': Icons.timer,
        'color': Colors.orange,
      },
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    stat['icon'] as IconData,
                    size: 20,
                    color: (stat['color'] as Color).withOpacity(0.7),
                  ),
                  Icon(
                    Icons.arrow_upward,
                    size: 14,
                    color: Colors.green,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat['value'] as String,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stat['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ).animate().fadeIn(delay: 500.ms);
  }
  
  Widget _buildInsightsSection(HealthProvider health, bool isDarkMode) {
    if (health.insights.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Insights',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        ...health.insights.take(3).map((insight) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getInsightColor(insight.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      insight.icon,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        insight.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }
  
  Widget _buildRecommendations(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.05),
            AppTheme.primaryColor.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommendation',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Based on your data, try to increase water intake by 500ml daily.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms);
  }
  
  // Helper methods
  List<FlSpot> _generateChartData() {
    return [
      const FlSpot(0, 75),
      const FlSpot(1, 68),
      const FlSpot(2, 82),
      const FlSpot(3, 79),
      const FlSpot(4, 85),
      const FlSpot(5, 72),
      const FlSpot(6, 88),
    ];
  }
  
  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
  
  Color _getStatusColor(double score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 60) return const Color(0xFFFBBF24);
    return const Color(0xFFF87171);
  }
  
  String _getStatus(double score) {
    if (score >= 80) return 'EXCELLENT';
    if (score >= 60) return 'GOOD';
    if (score >= 40) return 'FAIR';
    return 'NEEDS WORK';
  }
  
  String _getHealthMessage(double score) {
    if (score >= 80) return 'Your health metrics are outstanding. Keep maintaining these habits.';
    if (score >= 60) return 'You\'re doing well. Small improvements can boost your score.';
    return 'Focus on building consistent healthy habits.';
  }
  
  int _calculateTrend(double currentScore) {
    // Simulated trend calculation
    return 12;
  }
  
  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.success:
        return Colors.green;
      case InsightType.warning:
        return Colors.orange;
      case InsightType.info:
        return Colors.blue;
    }
  }
  
  void _showExportOptions() {
    // Implementation for export options
  }
}
