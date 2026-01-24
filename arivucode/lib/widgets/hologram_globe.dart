import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// A custom painter based widget that renders a rotating 3D-effect tech-sphere.
/// Fits the "Sci-Fi" holographic aesthetic for the ArivuCode dashboard.
class HologramGlobe extends StatefulWidget {
  final double size;
  const HologramGlobe({super.key, this.size = 200});

  @override
  State<HologramGlobe> createState() => _HologramGlobeState();
}

class _HologramGlobeState extends State<HologramGlobe> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: GlobePainter(
            rotation: _controller.value * 2 * math.pi,
            color: AppColors.secondary,
            accentColor: AppColors.primary,
          ),
        );
      },
    );
  }
}

class GlobePainter extends CustomPainter {
  final double rotation;
  final Color color;
  final Color accentColor;

  GlobePainter({
    required this.rotation,
    required this.color,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    // Draw background glow
    canvas.drawCircle(center, radius, glowPaint);

    // Draw outer technical ring
    final ringPaint = Paint()
      ..color = accentColor.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius + 15, ringPaint);
    
    // Technical dashes on ring
    final dashPaint = Paint()
      ..color = accentColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    for (int i = 0; i < 12; i++) {
        final double angle = (i / 12) * 2 * math.pi + (rotation * 0.2);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius + 15),
          angle,
          0.1,
          false,
          dashPaint,
        );
    }

    // Draw GNSS Orbits (abstract planes)
    final orbitPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
      
    for (int i = 0; i < 3; i++) {
      final double tilt = (i - 1) * 0.5;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(tilt);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: radius * 2.6, height: radius * 0.8),
        orbitPaint,
      );
      canvas.restore();
    }

    // Draw Longitudes (rotating)
    for (int i = 0; i < 8; i++) {
        final double angle = (i / 8) * math.pi + rotation;
        final double width = math.cos(angle) * radius;
        final opacity = 0.05 + (math.sin(angle).abs() * 0.2);
        paint.color = color.withOpacity(opacity);
        final rect = Rect.fromCenter(center: center, width: width.abs() * 2, height: radius * 2);
        canvas.drawOval(rect, paint);
    }

    // Draw Latitudes
    for (int i = 1; i < 5; i++) {
        final double hFactor = (i / 5) * 2 - 1;
        final double y = center.dy + hFactor * radius;
        final double w = math.sqrt(1 - hFactor * hFactor) * radius;
        paint.color = color.withOpacity(0.1);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(center.dx, y), width: w * 2, height: w * 0.1),
          paint
        );
    }
    
    // Draw "Geometric Satellites"
    final secondaryColor = color; // mapped locally
    final satPaint = Paint()
      ..color = secondaryColor // Use local color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final double satRotation = rotation * (0.5 + (i * 0.1)) + (i * math.pi / 3);
      final double distFactor = 1.2 + (i % 2 * 0.1);
      final double sx = center.dx + math.cos(satRotation) * (radius * distFactor);
      final double sy = center.dy + math.sin(satRotation * 0.5) * (radius * 0.6);
      
      final double depth = math.sin(satRotation);
      if (depth > -0.5) {
        final double size = 3.0 + (depth + 1) * 2;
        
        // Draw Diamond Shape
        final path = Path();
        path.moveTo(sx, sy - size);
        path.lineTo(sx + size, sy);
        path.lineTo(sx, sy + size);
        path.lineTo(sx - size, sy);
        path.close();
        
        canvas.drawPath(path, satPaint..color = color.withOpacity(0.8));
        canvas.drawCircle(Offset(sx, sy), size * 3, satPaint..color = color.withOpacity(0.1));
        
        // Data scan line
        if (i % 2 == 0) {
          canvas.drawLine(
            Offset(sx, sy), 
            center, 
            Paint()..color = color.withOpacity(0.05)..strokeWidth = 0.5
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant GlobePainter oldDelegate) => oldDelegate.rotation != rotation;
}
