// Export the appropriate camera monitoring screen based on platform
export 'camera_monitoring_screen_web.dart'
    if (dart.library.io) 'camera_monitoring_screen.dart';
