import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      appBar: AppBar(
        title: const Text('Settings'),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance Section
              _buildSectionTitle('Appearance', Icons.palette)
                  .animate()
                  .fadeIn()
                  .slideX(begin: -0.1, end: 0),
              const SizedBox(height: 12),
              _buildCard([
                _buildThemeTile(settingsProvider),
              ]).animate().fadeIn(delay: 50.ms),
              
              const SizedBox(height: 24),
              
              // Notifications Section
              _buildSectionTitle('Notifications', Icons.notifications)
                  .animate()
                  .fadeIn(delay: 100.ms)
                  .slideX(begin: -0.1, end: 0),
              const SizedBox(height: 12),
              _buildCard([
                _buildSwitchTile(
                  'Posture Alerts',
                  'Get notified about poor posture',
                  Icons.accessibility_new,
                  settingsProvider.postureAlerts,
                  (value) => settingsProvider.togglePostureAlerts(value),
                ),
                _buildDivider(),
                _buildSwitchTile(
                  'Water Reminders',
                  'Stay hydrated with regular reminders',
                  Icons.water_drop,
                  settingsProvider.waterReminders,
                  (value) => settingsProvider.toggleWaterReminders(value),
                ),
                _buildDivider(),
                _buildSwitchTile(
                  'Break Reminders',
                  'Get reminded to take breaks',
                  Icons.pause_circle,
                  settingsProvider.breakReminders,
                  (value) => settingsProvider.toggleBreakReminders(value),
                ),
                _buildDivider(),
                _buildSwitchTile(
                  'Exercise Reminders',
                  'Daily exercise notifications',
                  Icons.fitness_center,
                  settingsProvider.exerciseReminders,
                  (value) => settingsProvider.toggleExerciseReminders(value),
                ),
              ]).animate().fadeIn(delay: 150.ms),
              
              const SizedBox(height: 24),
              
              // Monitoring Settings
              _buildSectionTitle('Monitoring', Icons.videocam)
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .slideX(begin: -0.1, end: 0),
              const SizedBox(height: 12),
              _buildCard([
                _buildSwitchTile(
                  'Use Front Camera',
                  'Monitor posture with front camera',
                  Icons.camera_front,
                  settingsProvider.useFrontCamera,
                  (value) => settingsProvider.toggleCamera(value),
                ),
                _buildDivider(),
                _buildSwitchTile(
                  'Show Camera Preview',
                  'Display camera feed while monitoring',
                  Icons.visibility,
                  settingsProvider.showCameraPreview,
                  (value) => settingsProvider.toggleCameraPreview(value),
                ),
                _buildDivider(),
                _buildSliderTile(
                  'Posture Check Frequency',
                  'Check posture every ${settingsProvider.postureCheckFrequency} seconds',
                  Icons.timer,
                  settingsProvider.postureCheckFrequency.toDouble(),
                  5,
                  60,
                  (value) => settingsProvider.setPostureCheckFrequency(value.toInt()),
                ),
              ]).animate().fadeIn(delay: 250.ms),
              
              const SizedBox(height: 24),
              
              // Daily Goals
              _buildSectionTitle('Daily Goals', Icons.flag)
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .slideX(begin: -0.1, end: 0),
              const SizedBox(height: 12),
              _buildCard([
                _buildNumberInputTile(
                  'Water Goal',
                  '${settingsProvider.dailyWaterGoal}ml',
                  Icons.water_drop,
                  () => _showNumberDialog(
                    'Set Water Goal',
                    'Enter daily water goal in ml',
                    settingsProvider.dailyWaterGoal,
                    500,
                    5000,
                    (value) => settingsProvider.setDailyWaterGoal(value),
                  ),
                ),
                _buildDivider(),
                _buildNumberInputTile(
                  'Break Goal',
                  '${settingsProvider.dailyBreaksGoal} breaks',
                  Icons.pause_circle,
                  () => _showNumberDialog(
                    'Set Break Goal',
                    'Enter daily break goal',
                    settingsProvider.dailyBreaksGoal,
                    1,
                    20,
                    (value) => settingsProvider.setDailyBreaksGoal(value),
                  ),
                ),
                _buildDivider(),
                _buildNumberInputTile(
                  'Exercise Goal',
                  '${settingsProvider.dailyExerciseGoal} exercises',
                  Icons.fitness_center,
                  () => _showNumberDialog(
                    'Set Exercise Goal',
                    'Enter daily exercise goal',
                    settingsProvider.dailyExerciseGoal,
                    1,
                    20,
                    (value) => settingsProvider.setDailyExerciseGoal(value),
                  ),
                ),
              ]).animate().fadeIn(delay: 350.ms),
              
              const SizedBox(height: 24),
              
              // Sound & Haptics
              _buildSectionTitle('Sound & Haptics', Icons.volume_up)
                  .animate()
                  .fadeIn(delay: 400.ms)
                  .slideX(begin: -0.1, end: 0),
              const SizedBox(height: 12),
              _buildCard([
                _buildSwitchTile(
                  'Sound Effects',
                  'Play sounds for notifications',
                  Icons.volume_up,
                  settingsProvider.soundEnabled,
                  (value) => settingsProvider.toggleSound(value),
                ),
                _buildDivider(),
                _buildSwitchTile(
                  'Vibration',
                  'Vibrate for alerts',
                  Icons.vibration,
                  settingsProvider.vibrationEnabled,
                  (value) => settingsProvider.toggleVibration(value),
                ),
              ]).animate().fadeIn(delay: 450.ms),
              
              const SizedBox(height: 24),
              
              // About Section
              _buildSectionTitle('About', Icons.info)
                  .animate()
                  .fadeIn(delay: 500.ms)
                  .slideX(begin: -0.1, end: 0),
              const SizedBox(height: 12),
              _buildCard([
                _buildInfoTile('Version', '1.0.0', Icons.info_outline),
                _buildDivider(),
                _buildActionTile(
                  'Privacy Policy',
                  'View privacy policy',
                  Icons.privacy_tip,
                  () => _showInfoDialog('Privacy Policy'),
                ),
                _buildDivider(),
                _buildActionTile(
                  'Terms of Service',
                  'View terms and conditions',
                  Icons.description,
                  () => _showInfoDialog('Terms of Service'),
                ),
                _buildDivider(),
                _buildActionTile(
                  'Contact Support',
                  'Get help and support',
                  Icons.help,
                  () => _showInfoDialog('Support'),
                ),
              ]).animate().fadeIn(delay: 550.ms),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, IconData icon) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
  
  Widget _buildThemeTile(SettingsProvider provider) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.dark_mode,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: const Text('Theme'),
      subtitle: Text(
        provider.themeMode == ThemeMode.system
            ? 'System'
            : provider.themeMode == ThemeMode.dark
                ? 'Dark'
                : 'Light',
      ),
      trailing: PopupMenuButton<ThemeMode>(
        initialValue: provider.themeMode,
        onSelected: (value) => provider.setThemeMode(value),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: ThemeMode.system,
            child: Text('System'),
          ),
          const PopupMenuItem(
            value: ThemeMode.light,
            child: Text('Light'),
          ),
          const PopupMenuItem(
            value: ThemeMode.dark,
            child: Text('Dark'),
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.themeMode == ThemeMode.system
                    ? 'System'
                    : provider.themeMode == ThemeMode.dark
                        ? 'Dark'
                        : 'Light',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }
  
  Widget _buildSliderTile(
    String title,
    String subtitle,
    IconData icon,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) / 5).round(),
            label: value.round().toString(),
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
  
  Widget _buildNumberInputTile(
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: Text(title),
      subtitle: Text(value),
      trailing: Icon(
        Icons.edit,
        color: Theme.of(context).primaryColor,
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }
  
  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }
  
  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }
  
  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }
  
  void _showNumberDialog(
    String title,
    String description,
    int currentValue,
    int min,
    int max,
    Function(int) onSave,
  ) {
    final controller = TextEditingController(text: currentValue.toString());
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(description),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: 'Enter value ($min - $max)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value != null && value >= min && value <= max) {
                  onSave(value);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a value between $min and $max'),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  
  void _showInfoDialog(String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(
            'This is a demo app. $title information would be displayed here in a production version.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
