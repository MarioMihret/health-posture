import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            // Professional Header
            _buildHeader(isDarkMode),
            
            // Settings List
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 8),
                  
                  // Profile Section
                  _buildProfileSection(isDarkMode),
                  
                  const SizedBox(height: 24),
                  
                  // Appearance Section
                  _buildSectionHeader('Preferences', isDarkMode),
                  _buildSettingsGroup(
                    [
                      _buildThemeRow(settingsProvider, isDarkMode),
                      _buildDivider(isDarkMode),
                      _buildNotificationRow(isDarkMode),
                    ],
                    isDarkMode,
                  ).animate().fadeIn(delay: 100.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Health & Goals Section
                  _buildSectionHeader('Health & Goals', isDarkMode),
                  _buildSettingsGroup(
                    [
                      _buildGoalRow('Water Goal', '${settingsProvider.dailyWaterGoal}ml', 
                          Icons.water_drop_outlined, isDarkMode, () => _showGoalDialog('Water', settingsProvider)),
                      _buildDivider(isDarkMode),
                      _buildGoalRow('Exercise Goal', '${settingsProvider.dailyExerciseGoal} daily', 
                          Icons.fitness_center_outlined, isDarkMode, () => _showGoalDialog('Exercise', settingsProvider)),
                      _buildDivider(isDarkMode),
                      _buildGoalRow('Break Reminders', '${settingsProvider.dailyBreaksGoal} daily', 
                          Icons.timer_outlined, isDarkMode, () => _showGoalDialog('Break', settingsProvider)),
                    ],
                    isDarkMode,
                  ).animate().fadeIn(delay: 200.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Monitoring Section
                  _buildSectionHeader('Camera & Monitoring', isDarkMode),
                  _buildSettingsGroup(
                    [
                      _buildSwitchRow('Front Camera', 'Use front-facing camera', 
                          Icons.camera_front_outlined, settingsProvider.useFrontCamera,
                          (value) => settingsProvider.toggleCamera(value), isDarkMode),
                      _buildDivider(isDarkMode),
                      _buildSwitchRow('Camera Preview', 'Show live preview', 
                          Icons.visibility_outlined, settingsProvider.showCameraPreview,
                          (value) => settingsProvider.toggleCameraPreview(value), isDarkMode),
                      _buildDivider(isDarkMode),
                      _buildIntervalRow('Check Frequency', '${settingsProvider.postureCheckFrequency}s', 
                          Icons.update, isDarkMode, () => _showFrequencyDialog(settingsProvider)),
                    ],
                    isDarkMode,
                  ).animate().fadeIn(delay: 300.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Sound & Haptics Section
                  _buildSectionHeader('Sound & Haptics', isDarkMode),
                  _buildSettingsGroup(
                    [
                      _buildSwitchRow('Sound Effects', 'Play notification sounds', 
                          Icons.volume_up_outlined, settingsProvider.soundEnabled,
                          (value) => settingsProvider.toggleSound(value), isDarkMode),
                      _buildDivider(isDarkMode),
                      _buildSwitchRow('Haptic Feedback', 'Vibration alerts', 
                          Icons.vibration, settingsProvider.vibrationEnabled,
                          (value) => settingsProvider.toggleVibration(value), isDarkMode),
                    ],
                    isDarkMode,
                  ).animate().fadeIn(delay: 400.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Support Section
                  _buildSectionHeader('Support', isDarkMode),
                  _buildSettingsGroup(
                    [
                      _buildNavigationRow('Help Center', Icons.help_outline, isDarkMode, () => _showHelp()),
                      _buildDivider(isDarkMode),
                      _buildNavigationRow('Privacy Policy', Icons.privacy_tip_outlined, isDarkMode, () => _showPrivacy()),
                      _buildDivider(isDarkMode),
                      _buildNavigationRow('Terms of Service', Icons.description_outlined, isDarkMode, () => _showTerms()),
                      _buildDivider(isDarkMode),
                      _buildNavigationRow('Send Feedback', Icons.feedback_outlined, isDarkMode, () => _showFeedback()),
                    ],
                    isDarkMode,
                  ).animate().fadeIn(delay: 500.ms),
                  
                  const SizedBox(height: 24),
                  
                  // App Info
                  _buildAppInfo(isDarkMode),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      color: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F7),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }
  
  Widget _buildProfileSection(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[850]! : Colors.grey[200]!,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.8),
                  AppTheme.primaryColor,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your health preferences',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 50.ms).scale(begin: const Offset(0.95, 0.95));
  }
  
  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.grey[600] : Colors.grey[500],
          letterSpacing: 0.8,
        ),
      ),
    );
  }
  
  Widget _buildSettingsGroup(List<Widget> children, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[850]! : Colors.grey[200]!,
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }
  
  Widget _buildThemeRow(SettingsProvider provider, bool isDarkMode) {
    return InkWell(
      onTap: () => provider.toggleTheme(),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                size: 18,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDarkMode ? 'Dark Mode' : 'Light Mode',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isDarkMode ? 'Dark' : 'Light',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNotificationRow(bool isDarkMode) {
    return InkWell(
      onTap: () => _showNotificationSettings(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                size: 18,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Manage alerts and reminders',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSwitchRow(String title, String subtitle, IconData icon, 
      bool value, Function(bool) onChanged, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGoalRow(String title, String value, IconData icon, 
      bool isDarkMode, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildIntervalRow(String title, String value, IconData icon, 
      bool isDarkMode, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNavigationRow(String title, IconData icon, bool isDarkMode, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDivider(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(left: 60),
      height: 0.5,
      color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
    );
  }
  
  Widget _buildAppInfo(bool isDarkMode) {
    return Center(
      child: Column(
        children: [
          Text(
            'Posture Health Assistant',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
  
  // Dialog Methods
  void _showNotificationSettings() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final settingsProvider = context.read<SettingsProvider>();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Notification Settings',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildNotificationOption('Posture Alerts', settingsProvider.postureAlerts,
                        (value) {
                          setState(() {});
                          settingsProvider.togglePostureAlerts(value);
                        }, isDarkMode),
                    const SizedBox(height: 12),
                    _buildNotificationOption('Water Reminders', settingsProvider.waterReminders,
                        (value) {
                          setState(() {});
                          settingsProvider.toggleWaterReminders(value);
                        }, isDarkMode),
                    const SizedBox(height: 12),
                    _buildNotificationOption('Break Reminders', settingsProvider.breakReminders,
                        (value) {
                          setState(() {});
                          settingsProvider.toggleBreakReminders(value);
                        }, isDarkMode),
                    const SizedBox(height: 12),
                    _buildNotificationOption('Exercise Reminders', settingsProvider.exerciseReminders,
                        (value) {
                          setState(() {});
                          settingsProvider.toggleExerciseReminders(value);
                        }, isDarkMode),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildNotificationOption(String title, bool value, Function(bool) onChanged, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showGoalDialog(String type, SettingsProvider provider) {
    // Implementation for goal dialog
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    int currentValue = type == 'Water' ? provider.dailyWaterGoal :
                      type == 'Exercise' ? provider.dailyExerciseGoal :
                      provider.dailyBreaksGoal;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
          title: Text('Set $type Goal'),
          content: Text('Current: $currentValue'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  
  void _showFrequencyDialog(SettingsProvider provider) {
    // Implementation for frequency dialog
  }
  
  void _showHelp() {
    // Implementation
  }
  
  void _showPrivacy() {
    // Implementation
  }
  
  void _showTerms() {
    // Implementation
  }
  
  void _showFeedback() {
    // Implementation
  }
}
