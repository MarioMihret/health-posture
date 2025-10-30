import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../providers/posture_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/pose_detection_service_export.dart';
import '../../models/posture_data.dart';
import '../../theme/app_theme.dart';

class CameraMonitoringScreen extends StatefulWidget {
  const CameraMonitoringScreen({super.key});

  @override
  State<CameraMonitoringScreen> createState() => _CameraMonitoringScreenState();
}

class _CameraMonitoringScreenState extends State<CameraMonitoringScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _hasPermission = false;
  Timer? _posturCheckTimer;
  
  final PoseDetectionService _poseService = PoseDetectionService();
  // final NotificationService _notificationService = NotificationService();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _posturCheckTimer?.cancel();
    _cameraController?.dispose();
    _poseService.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }
  
  Future<void> _initialize() async {
    // Check camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() => _hasPermission = false);
      return;
    }
    
    setState(() => _hasPermission = true);
    
    // Get available cameras
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) {
      _showError('No cameras available');
      return;
    }
    
    // Initialize pose detection service
    await _poseService.initialize();
    
    // Initialize camera
    await _initializeCamera();
  }
  
  Future<void> _initializeCamera() async {
    if (_cameras == null || _cameras!.isEmpty) return;
    
    final settingsProvider = context.read<SettingsProvider>();
    final useFrontCamera = settingsProvider.useFrontCamera;
    
    // Select camera
    final camera = useFrontCamera
        ? _cameras!.firstWhere(
            (cam) => cam.lensDirection == CameraLensDirection.front,
            orElse: () => _cameras!.first,
          )
        : _cameras!.firstWhere(
            (cam) => cam.lensDirection == CameraLensDirection.back,
            orElse: () => _cameras!.first,
          );
    
    // Create camera controller
    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    
    try {
      await _cameraController!.initialize();
      
      if (!mounted) return;
      
      setState(() => _isInitialized = true);
      
      // Start posture monitoring
      _startPostureMonitoring();
      
      // Start image stream for pose detection
      _cameraController!.startImageStream(_processCameraImage);
    } catch (e) {
      _showError('Failed to initialize camera: $e');
    }
  }
  
  void _startPostureMonitoring() {
    final postureProvider = context.read<PostureProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    
    postureProvider.startMonitoring();
    
    // Set up periodic posture checks
    final checkFrequency = Duration(seconds: settingsProvider.postureCheckFrequency);
    _posturCheckTimer = Timer.periodic(checkFrequency, (timer) {
      if (postureProvider.currentPosture == PostureStatus.bad &&
          settingsProvider.postureAlerts) {
        _sendPostureAlert();
      }
    });
  }
  
  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing || _cameraController == null) return;
    
    _isProcessing = true;
    
    try {
      final status = await _poseService.processImage(
        image,
        _cameraController!.description,
      );
      
      if (mounted) {
        context.read<PostureProvider>().updatePostureStatus(status);
      }
    } catch (e) {
      debugPrint('Error processing camera image: $e');
    } finally {
      _isProcessing = false;
    }
  }
  
  void _sendPostureAlert() {
    HapticFeedback.mediumImpact();
    // Web doesn't support notifications yet
    // _notificationService.showPostureAlert(
    //   title: '⚠️ Poor Posture Detected',
    //   body: 'Time to adjust your sitting position for better health!',
    //   payload: 'posture_alert',
    // );
  }
  
  void _toggleCamera() {
    final settingsProvider = context.read<SettingsProvider>();
    settingsProvider.toggleCamera(!settingsProvider.useFrontCamera);
    _initializeCamera();
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final postureProvider = context.watch<PostureProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posture Monitoring'),
        backgroundColor: Colors.transparent,
        actions: [
          if (_isInitialized)
            IconButton(
              icon: const Icon(Icons.flip_camera_ios),
              onPressed: _toggleCamera,
            ).animate().fadeIn(delay: 200.ms),
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
        child: !_hasPermission
            ? _buildPermissionDenied()
            : !_isInitialized
                ? _buildLoading()
                : _buildMonitoringView(postureProvider, settingsProvider),
      ),
    );
  }
  
  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'Camera Permission Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please grant camera access to monitor your posture',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                openAppSettings();
              },
              icon: const Icon(Icons.settings),
              label: const Text('Open Settings'),
            ),
          ],
        ).animate().fadeIn().slideY(begin: 0.2, end: 0),
      ),
    );
  }
  
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Initializing camera...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ).animate().fadeIn(),
    );
  }
  
  Widget _buildMonitoringView(
    PostureProvider postureProvider,
    SettingsProvider settingsProvider,
  ) {
    return Column(
      children: [
        // Camera preview
        Expanded(
          flex: 2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Camera view
              if (settingsProvider.showCameraPreview)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: _cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraController!),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.visibility_off,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Camera preview hidden',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Monitoring is still active',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Posture overlay
              if (postureProvider.isMonitoring)
                Positioned(
                  top: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: PostureData.getStatusColor(
                        postureProvider.currentPosture,
                      ).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          PostureData.getStatusIcon(
                            postureProvider.currentPosture,
                          ),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          postureProvider.currentPosture.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: -0.5, end: 0),
                ),
              
              // Hide preview button
              Positioned(
                bottom: 16,
                right: 16,
                child: IconButton(
                  onPressed: () {
                    settingsProvider.toggleCameraPreview(
                      !settingsProvider.showCameraPreview,
                    );
                  },
                  icon: Icon(
                    settingsProvider.showCameraPreview
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black45,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms).scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1, 1),
            ),
        
        // Stats and controls
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Posture score
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Score',
                        '${postureProvider.postureScore.toStringAsFixed(0)}%',
                        Icons.score,
                        AppTheme.primaryColor,
                      ),
                      _buildStatItem(
                        'Good Posture',
                        '${postureProvider.todayGoodPosturePercentage.toStringAsFixed(0)}%',
                        Icons.check_circle,
                        AppTheme.successColor,
                      ),
                      _buildStatItem(
                        'Duration',
                        _formatDuration(
                          postureProvider.goodPostureDuration,
                        ),
                        Icons.timer,
                        AppTheme.warningColor,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 16),
                
                // Feedback message
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PostureData.getStatusColor(
                      postureProvider.currentPosture,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: PostureData.getStatusColor(
                        postureProvider.currentPosture,
                      ).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    PostureData.getStatusMessage(
                      postureProvider.currentPosture,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: PostureData.getStatusColor(
                        postureProvider.currentPosture,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms),
                
                const Spacer(),
                
                // Control button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (postureProvider.isMonitoring) {
                        postureProvider.stopMonitoring();
                        Navigator.pop(context);
                      } else {
                        postureProvider.startMonitoring();
                      }
                    },
                    icon: Icon(
                      postureProvider.isMonitoring
                          ? Icons.stop
                          : Icons.play_arrow,
                    ),
                    label: Text(
                      postureProvider.isMonitoring
                          ? 'Stop Monitoring'
                          : 'Start Monitoring',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: postureProvider.isMonitoring
                          ? AppTheme.errorColor
                          : AppTheme.primaryColor,
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
