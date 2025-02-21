import 'dart:math';

import 'package:flutter/material.dart';

class PinwheelSpinner extends StatefulWidget {
  const PinwheelSpinner({
    super.key,
    required this.speed,
  });

  final int speed;

  @override
  PinwheelSpinnerState createState() => PinwheelSpinnerState();
}

class PinwheelSpinnerState extends State<PinwheelSpinner>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();

    final spinDurationSecs = (5 - widget.speed) * 2;

    _controller = AnimationController(
      duration: Duration(seconds: spinDurationSecs),// Spin duration
      vsync: this,
    )..repeat(); // Repeat the animation indefinitely
  }

  @override
  void dispose() {

    _controller.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * 3.14, // Convert animation value to radians
            child: CustomPaint(
              size: Size(50, 50), // Size of the pinwheel
              painter: PinwheelPainter(colorScheme),
            ),
          );
        },
      ),
    );
  }
}

class PinwheelPainter extends CustomPainter {
  final ColorScheme colorScheme;

  PinwheelPainter(this.colorScheme);


  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw the pinwheel blades
    for (int i = 0; i < 6; i++) {
      final paint = Paint()
        ..color = colorScheme.primary
        ..style = PaintingStyle.fill;

      // Calculate the angle for each blade
      final angle = i * 3.14 / 3; // 90 degrees in radians

      // Define the path for each blade
      final path = Path();
      path.moveTo(center.dx, center.dy); // Start at the center
      path.lineTo(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      path.lineTo(
        center.dx + (radius / 2) * cos(angle + 3.14 / 4),
        center.dy + (radius / 2) * sin(angle + 3.14 / 4),
      );
      path.close();

      // Draw the blade
      canvas.drawPath(path, paint);
    }

    // Draw the center circle of the pinwheel
    final centerPaint = Paint()
      ..color = colorScheme.inversePrimary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.15, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // No need to repaint unless the pinwheel design changes
  }
}