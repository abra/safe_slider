import 'package:flutter/material.dart';

class TrackPainter extends CustomPainter {
  TrackPainter({
    required this.thumbPosition,
    required this.inactiveColor,
    required this.activeColor,
    required this.strokeWidth,
    required this.thumbRadius,
  })  : activePartPaint = Paint()
          ..color = activeColor
          ..style = PaintingStyle.fill
          ..strokeWidth = strokeWidth,
        inactivePartPaint = Paint()
          ..color = inactiveColor
          ..style = PaintingStyle.fill
          ..strokeWidth = strokeWidth;

  final double thumbPosition;
  final Paint activePartPaint;
  final Paint inactivePartPaint;
  final double strokeWidth;
  final double thumbRadius;
  final Color inactiveColor;
  final Color activeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;

    // Left padding
    canvas.drawLine(
      Offset(0, centerY),
      Offset(thumbRadius, centerY),
      activePartPaint,
    );
    // Active part
    canvas.drawLine(
      Offset(thumbRadius, centerY),
      Offset(thumbPosition + thumbRadius, centerY),
      activePartPaint,
    );
    // Inactive part
    canvas.drawLine(
      Offset(thumbPosition + thumbRadius, centerY),
      Offset(size.width - thumbRadius, centerY),
      inactivePartPaint,
    );
    // Right padding
    canvas.drawLine(
      Offset(size.width - thumbRadius, centerY),
      Offset(size.width, centerY),
      inactivePartPaint,
    );
  }

  @override
  bool shouldRepaint(covariant TrackPainter oldDelegate) =>
      oldDelegate.thumbPosition != thumbPosition ||
      oldDelegate.activeColor != activeColor ||
      oldDelegate.inactiveColor != inactiveColor ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.thumbRadius != thumbRadius;
}
