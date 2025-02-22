import 'dart:math';

import 'package:flutter/material.dart';
import 'package:habitual/src/systems/habit_data/habit_data_controller.dart';
import 'package:habitual/src/systems/habit_data/habit_model.dart';
import 'package:polygon/polygon.dart';

enum FluidContainerShape {
  circle,
  rectangle,
  roundedRectangle,
  triangle,
  diamond,
  hexagon,
}

class FluidFillingContainer extends StatefulWidget {
  const FluidFillingContainer({
    super.key,
    required this.habitDataController,
    required this.selectedHabit,
    required this.shape,
    required this.selectedDate,
    required this.onTap,
  });

  final HabitDataController habitDataController;
  final Habit selectedHabit;
  final FluidContainerShape shape;
  final DateTime selectedDate;
  final Function(Habit) onTap;

  @override
  FluidFillingContainerState createState() => FluidFillingContainerState();
}

class FluidFillingContainerState extends State<FluidFillingContainer> with TickerProviderStateMixin {
  late AnimationController _longFillController;
  late AnimationController _waveController;
  late AnimationController _fillCompleteController;
  late bool filled;

  @override
  void initState() {
    super.initState();    

    _longFillController = AnimationController(
      duration: const Duration(milliseconds: 500),
      lowerBound: 0.25,
      vsync: this,
    );

    _waveController = AnimationController(
      duration: Duration(seconds: 4 + widget.selectedHabit.id),
      vsync: this,
    )..repeat(reverse: true);

    _fillCompleteController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    filled = widget.selectedHabit.completed(widget.selectedDate);

    if (filled) {
      _longFillController.value = 1.0;
    }
  }

  void _onTap() {
    if (_longFillController.value >= 1.0) {
      _unfill();
    } else {
      if (widget.selectedHabit.duration != null ) {
        // Navigator.push(context, MaterialPageRoute(builder: (context) {
        //   return TimerView(habit: widget.selectedHabit, date: widget.selectedDate);
        // }));
        widget.onTap(widget.selectedHabit);
        setState(() {
          // Catch the update
        });
      }
    }
  }

  void _unfill() {
    _fillCompleteController.reset();
    _longFillController.reverse().whenComplete(
      () {
        widget.selectedHabit.decrement(widget.selectedDate);
        widget.habitDataController.updateHabit(widget.selectedHabit);
    });

  }

  void _startLongFill() {
    if (_longFillController.value < 1.0) {
      _longFillController.forward().whenComplete(_endLongFill);
    }
  }

  void _endLongFill() {
    if (_longFillController.value >= 1.0) {
      _fillCompleteController.forward().whenComplete(() { widget.selectedHabit.increment(widget.selectedDate);
              widget.habitDataController.updateHabit(widget.selectedHabit);
      });

    } else {
      _longFillController.reverse();
      _fillCompleteController.reset();
    }
  }


  @override
  void dispose() {
    _waveController.dispose();
    _fillCompleteController.dispose();
    _longFillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextStyle onPrimaryStyle = TextStyle(
      fontSize: 14, 
      fontWeight: FontWeight.bold,
      color: colorScheme.onPrimary,
      overflow: TextOverflow.ellipsis,
    );

    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) => GestureDetector(
        onTap: _onTap,
        onLongPress: _startLongFill,
        // onLongPressUp: _endLongFill,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Center(
            child: Stack(
              children: [
                if (widget.selectedHabit.frequency == Frequency.weekly)
                  WaterDropBurst(
                    fillCompleteController: _fillCompleteController, 
                    colorScheme: colorScheme, 
                    count: 16, 
                    size: 12.0, 
                    distance: 1.4,
                  ),
                
                if (widget.selectedHabit.frequency == Frequency.daily)
                  WaterDropBurst(
                    fillCompleteController: _fillCompleteController, 
                    colorScheme: colorScheme, 
                    count: 16, 
                    size: 12.0, 
                    distance: 1.2,
                  ),
          
                if (widget.selectedHabit.frequency == Frequency.monthly)
                  WaterDropBurst(
                    fillCompleteController: _fillCompleteController, 
                    colorScheme: colorScheme, 
                    count: 16, 
                    size: 12.0, 
                    distance: 1.2,
                  ),
          
                AnimatedBuilder(
                  animation: _longFillController,
                  builder: (context, child) => FluidFilledContainer(
                    shape: widget.shape,
                    fillController: _longFillController, 
                    waveController: _waveController, 
                    colorScheme: colorScheme
                  ),
                ),
                Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: IgnorePointer(
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: colorScheme.primary,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints.loose(Size.square(80)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(widget.selectedHabit.title, style: onPrimaryStyle, maxLines: 3,),
                              if (widget.selectedHabit.duration != null)
                                Text('${widget.selectedHabit.duration} ${widget.selectedHabit.durationType.name}', style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
                overflow: TextOverflow.ellipsis,
              ), maxLines: 1,),
                            ],
                          )),
                      ),
                    ),
                  ),
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}

class FluidFilledContainer extends StatelessWidget {
  const FluidFilledContainer({
    super.key,
    required AnimationController fillController,
    required AnimationController waveController,
    required this.colorScheme,
    required this.shape,
  }) : _fillController = fillController, _waveController = waveController;

  final AnimationController _fillController;
  final AnimationController _waveController;
  final ColorScheme colorScheme;
  final FluidContainerShape shape;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      // width:  400,
      // height: 400,
      child: CustomPaint(
        painter: FluidPainter(_fillController, _waveController, colorScheme.primary, shape),
      ),
    );
  }
}

class WaterDropBurst extends StatelessWidget {
  const WaterDropBurst({
    super.key,
    required AnimationController fillCompleteController,
    required this.colorScheme,
    required this.count,
    required this.size,
    required this.distance,
  }) : _fillCompleteController = fillCompleteController;

  final AnimationController _fillCompleteController;
  final ColorScheme colorScheme;
  final int count;
  final double size;
  final double distance;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fillCompleteController,
      child: AnimatedOpacity(
        opacity: 1 - _fillCompleteController.value,
        curve: Curves.easeOut,
        duration: _fillCompleteController.duration!,
        child: AnimatedRotation(
          duration: _fillCompleteController.duration!,
          turns: _fillCompleteController.value,
          child: SizedBox.expand(
            // width: 200,
            // height: 200,
            child: CustomPaint(
              painter: WaterDropBurstPainter(burstController: _fillCompleteController, dropletColor: colorScheme.primary, dropletCount: count, dropletRadius: size, dropletDistance: distance),
            ),
          ),
        ),
      ),
    );
  }
}

class WaterDropOverflowPainter extends CustomPainter {
  final AnimationController burstController;
  final Color dropColor;
  final int dropletCount;
  final double dropletRadius;
  final double dropletDistance;

  WaterDropOverflowPainter({
    required this.burstController, 
    required this.dropColor,
    required this.dropletCount,
    required this.dropletRadius,
    required this.dropletDistance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final maxDistance = radius * dropletDistance;


    final paint = Paint()
      ..color = dropColor
      ..style = PaintingStyle.fill;

    // Main droplets
    for (int i = 0 ; i < dropletCount; ++i) {
      final angle = - 1 * (pi / 4 + (pi / 4 * i));
      final distance = maxDistance * burstController.value;
      final dropletCenter = Offset(
        center.dx + distance * cos(angle), 
        center.dy + distance * sin(angle),
      );

      canvas.drawCircle(dropletCenter, dropletRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return burstController.isAnimating;
  }
}

class WaterDropBurstPainter extends CustomPainter {
  final AnimationController burstController;
  final Color dropletColor;
  final int dropletCount;
  final double dropletRadius;
  final double dropletDistance;

  WaterDropBurstPainter({
    required this.burstController, 
    required this.dropletColor,
    required this.dropletCount,
    required this.dropletRadius,
    required this.dropletDistance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final maxDistance = radius * dropletDistance;


    final paint = Paint()
      ..color = dropletColor
      ..style = PaintingStyle.fill;

    // Main droplets
    for (int i = 0 ; i < dropletCount; ++i) {
      final angle = 2 * pi * i / dropletCount;
      final distance = maxDistance * burstController.value;
      final dropletCenter = Offset(
        center.dx + distance * cos(angle), 
        center.dy + distance * sin(angle),
      );

      // Draw a circle
      canvas.drawCircle(dropletCenter, dropletRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return burstController.isAnimating;
  }
}

class FluidPainter extends CustomPainter {
  final AnimationController fillController; // Current fill level (0.0 to 1.0)
  final Color paintColor;
  final AnimationController waveController;
  final FluidContainerShape shape;

  FluidPainter(this.fillController, this.waveController, this.paintColor, this.shape);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = paintColor
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Calculate the height of the fluid based on the fill level
    final fluidHeight = size.height * (0.9 - fillController.value);

    // Draw the fluid with a sloshing effect
    final path = Path();
    path.moveTo(0, fluidHeight);

    // Create a sloshing effect using multiple sine waves
    for (double x = 0; x <= size.width; x++) {
      final time = waveController.value * 2 * 3.14 * (1 - fillController.value) ;

      // Combine multiple sine waves for a sloshing effect
      final wave1 = 6 * sin((x / size.width * 4 * 3.14) + time); // High frequency
      final wave2 = 4 * sin((x / size.width * 2 * 3.14) + time * 1.5); // Medium frequency
      final wave3 = 3 * sin((x / size.width * 1 * 3.14) + time * 2); // Low frequency

      // Combine the waves and add them to the fluid height
      final y = fluidHeight + wave1 + wave2 + wave3;

      path.lineTo(x, y);
    }

    // Close the path to fill the container
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Clip the path to the circular container
    switch (shape) {
      case FluidContainerShape.circle:
        canvas.clipPath(Path()
        ..addOval(Rect.fromCircle(center: center, radius: radius)));
        break;
      case FluidContainerShape.rectangle:
        canvas.clipPath(Path()
        ..addRect(Rect.fromCircle(center: center, radius: radius)));
        break;
      case FluidContainerShape.roundedRectangle:
        canvas.clipPath(Path()
        ..addRRect(RRect.fromRectAndRadius(Rect.fromCircle(center: center, radius: radius), Radius.circular(36.0))));
        break;
      case FluidContainerShape.triangle:
        final triangle = Polygon([
          Offset(0, -1),
          Offset(1, 1),
          Offset(-1, 1),
        ]);
        
        canvas.clipPath(
          triangle.computePath(
            radius: 36.0,
            rect: Rect.fromCircle(center: center, radius: radius + 10)
          )
        );
        break;
      case FluidContainerShape.diamond:
        final diamond = Polygon([
          Offset(0, -1),
          Offset(1, 0),
          Offset(0, 1),
          Offset(-1, 0),
        ]);
        
        canvas.clipPath(
          diamond.computePath(
            radius: 36.0,
            rect: Rect.fromCircle(center: center, radius: radius + 12)
          )
        );
        break;
      case FluidContainerShape.hexagon:
        final hexagon = Polygon([
          Offset(0, -1),
          Offset(0.5, -0.5),
          Offset(1, 0),
          Offset(0.5, 0.5),
          Offset(0, 1),
          Offset(-0.5, 0.5),
          Offset(-1, 0),
          Offset(-0.5, -0.5),
        ]);
        
        canvas.clipPath(
          hexagon.computePath(
            radius: 36.0,
            rect: Rect.fromCircle(center: center, radius: radius + 12)
          )
        );

        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint to animate the fluid
  }
}
