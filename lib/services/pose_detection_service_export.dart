// Export the appropriate pose detection service based on platform
export 'pose_detection_service_web.dart'
    if (dart.library.io) 'pose_detection_service.dart';
