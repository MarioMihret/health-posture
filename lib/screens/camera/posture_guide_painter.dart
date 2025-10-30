import 'package:flutter/material.dart';
import '../../models/posture_data.dart';

// Custom painter for posture guide overlay
class PostureGuidePainter extends CustomPainter {
  final PostureStatus status;
  final bool isDarkMode;
  
  PostureGuidePainter(this.status, this.isDarkMode);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _getGuideColor().withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Draw guide lines for proper posture
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Head position guide
    canvas.drawCircle(
      Offset(centerX, centerY - 40),
      30,
      paint,
    );
    
    // Shoulder line
    canvas.drawLine(
      Offset(centerX - 50, centerY + 20),
      Offset(centerX + 50, centerY + 20),
      paint,
    );
    
    // Spine line
    canvas.drawLine(
      Offset(centerX, centerY - 10),
      Offset(centerX, centerY + 60),
      paint,
    );
  }
  
  Color _getGuideColor() {
    switch (status) {
      case PostureStatus.good:
        return Colors.green;
      case PostureStatus.moderate:
        return Colors.orange;
      case PostureStatus.bad:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  @override
  bool shouldRepaint(PostureGuidePainter oldDelegate) {
    return oldDelegate.status != status;
  }
}
