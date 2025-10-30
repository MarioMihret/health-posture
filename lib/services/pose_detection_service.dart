import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:camera/camera.dart';
import 'dart:math' as math;
import '../models/posture_data.dart';

class PoseDetectionService {
  static final PoseDetectionService _instance = PoseDetectionService._internal();
  factory PoseDetectionService() => _instance;
  PoseDetectionService._internal();
  
  late PoseDetector _poseDetector;
  bool _isInitialized = false;
  
  // Initialize pose detector
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    final options = PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.base,
    );
    
    _poseDetector = PoseDetector(options: options);
    _isInitialized = true;
  }
  
  // Process camera image for pose detection
  Future<PostureStatus> processImage(CameraImage image, CameraDescription camera) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      final inputImage = _convertCameraImage(image, camera);
      if (inputImage == null) return PostureStatus.unknown;
      
      final poses = await _poseDetector.processImage(inputImage);
      
      if (poses.isEmpty) {
        return PostureStatus.unknown;
      }
      
      // Analyze the first detected pose
      return _analyzePosture(poses.first);
    } catch (e) {
      debugPrint('Error processing image for pose detection: $e');
      return PostureStatus.unknown;
    }
  }
  
  // Convert CameraImage to InputImage for ML Kit
  InputImage? _convertCameraImage(CameraImage image, CameraDescription camera) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();
      
      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      
      final InputImageRotation rotation = _getImageRotation(camera);
      final InputImageFormat format = InputImageFormat.nv21;
      
      final planeData = image.planes.map(
        (Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow ?? 0,
            height: plane.height ?? image.height,
            width: plane.width ?? image.width,
          );
        },
      ).toList();
      
      final inputImageData = InputImageData(
        size: imageSize,
        imageRotation: rotation,
        inputImageFormat: format,
        planeData: planeData,
      );
      
      return InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
    } catch (e) {
      debugPrint('Error converting camera image: $e');
      return null;
    }
  }
  
  // Get image rotation based on camera
  InputImageRotation _getImageRotation(CameraDescription camera) {
    final sensorOrientation = camera.sensorOrientation;
    
    switch (sensorOrientation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }
  
  // Analyze posture based on detected pose landmarks
  PostureStatus _analyzePosture(Pose pose) {
    try {
      // Get key landmarks
      final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
      final leftEar = pose.landmarks[PoseLandmarkType.leftEar];
      final rightEar = pose.landmarks[PoseLandmarkType.rightEar];
      final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
      final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
      
      // Check if all required landmarks are detected
      if (leftShoulder == null || rightShoulder == null || 
          leftEar == null || rightEar == null ||
          leftHip == null || rightHip == null) {
        return PostureStatus.unknown;
      }
      
      // Calculate posture metrics
      final shoulderAlignment = _calculateShoulderAlignment(leftShoulder, rightShoulder);
      final neckAngle = _calculateNeckAngle(leftEar, rightEar, leftShoulder, rightShoulder);
      final backAngle = _calculateBackAngle(leftShoulder, rightShoulder, leftHip, rightHip);
      
      // Determine posture status based on metrics
      if (_isGoodPosture(shoulderAlignment, neckAngle, backAngle)) {
        return PostureStatus.good;
      } else if (_isModeratePosture(shoulderAlignment, neckAngle, backAngle)) {
        return PostureStatus.moderate;
      } else {
        return PostureStatus.bad;
      }
    } catch (e) {
      debugPrint('Error analyzing posture: $e');
      return PostureStatus.unknown;
    }
  }
  
  // Calculate shoulder alignment (should be relatively horizontal)
  double _calculateShoulderAlignment(PoseLandmark leftShoulder, PoseLandmark rightShoulder) {
    final deltaY = (leftShoulder.y - rightShoulder.y).abs();
    final deltaX = (leftShoulder.x - rightShoulder.x).abs();
    
    if (deltaX == 0) return 90.0; // Vertical alignment
    
    final angle = math.atan(deltaY / deltaX) * (180 / math.pi);
    return angle;
  }
  
  // Calculate neck angle (forward head posture detection)
  double _calculateNeckAngle(
    PoseLandmark leftEar, 
    PoseLandmark rightEar,
    PoseLandmark leftShoulder, 
    PoseLandmark rightShoulder,
  ) {
    // Calculate ear midpoint
    final earMidX = (leftEar.x + rightEar.x) / 2;
    final earMidY = (leftEar.y + rightEar.y) / 2;
    
    // Calculate shoulder midpoint
    final shoulderMidX = (leftShoulder.x + rightShoulder.x) / 2;
    final shoulderMidY = (leftShoulder.y + rightShoulder.y) / 2;
    
    // Calculate angle between ear and shoulder midpoints
    final deltaX = earMidX - shoulderMidX;
    final deltaY = earMidY - shoulderMidY;
    
    final angle = math.atan2(deltaY, deltaX) * (180 / math.pi);
    return angle.abs();
  }
  
  // Calculate back angle (slouching detection)
  double _calculateBackAngle(
    PoseLandmark leftShoulder,
    PoseLandmark rightShoulder,
    PoseLandmark leftHip,
    PoseLandmark rightHip,
  ) {
    // Calculate shoulder midpoint
    final shoulderMidX = (leftShoulder.x + rightShoulder.x) / 2;
    final shoulderMidY = (leftShoulder.y + rightShoulder.y) / 2;
    
    // Calculate hip midpoint
    final hipMidX = (leftHip.x + rightHip.x) / 2;
    final hipMidY = (leftHip.y + rightHip.y) / 2;
    
    // Calculate angle of spine
    final deltaX = shoulderMidX - hipMidX;
    final deltaY = shoulderMidY - hipMidY;
    
    final angle = math.atan2(deltaX, deltaY) * (180 / math.pi);
    return angle.abs();
  }
  
  // Check if posture is good
  bool _isGoodPosture(double shoulderAlignment, double neckAngle, double backAngle) {
    return shoulderAlignment < 10 &&  // Shoulders are level
           neckAngle > 75 && neckAngle < 95 &&  // Head is above shoulders
           backAngle < 15;  // Back is straight
  }
  
  // Check if posture is moderate
  bool _isModeratePosture(double shoulderAlignment, double neckAngle, double backAngle) {
    return shoulderAlignment < 20 &&  // Shoulders slightly uneven
           neckAngle > 65 && neckAngle < 105 &&  // Head slightly forward
           backAngle < 25;  // Back slightly curved
  }
  
  // Get posture feedback
  String getPostureFeedback(PostureStatus status, {
    double? shoulderAlignment,
    double? neckAngle,
    double? backAngle,
  }) {
    switch (status) {
      case PostureStatus.good:
        return 'Excellent posture! Keep maintaining this position.';
      case PostureStatus.moderate:
        final feedback = StringBuffer('Your posture needs adjustment:\n');
        if (shoulderAlignment != null && shoulderAlignment > 10) {
          feedback.write('• Level your shoulders\n');
        }
        if (neckAngle != null && (neckAngle < 75 || neckAngle > 95)) {
          feedback.write('• Align your head with shoulders\n');
        }
        if (backAngle != null && backAngle > 15) {
          feedback.write('• Straighten your back\n');
        }
        return feedback.toString();
      case PostureStatus.bad:
        return '''Poor posture detected! Please:
• Sit up straight
• Pull shoulders back
• Align head over shoulders
• Keep feet flat on floor''';
      case PostureStatus.unknown:
        return 'Unable to detect posture. Please ensure you are visible to the camera.';
    }
  }
  
  // Dispose resources
  void dispose() {
    if (_isInitialized) {
      _poseDetector.close();
      _isInitialized = false;
    }
  }
}
