import 'package:flutter/material.dart';

enum AnimationDirection {
  forward,
  reverse,
}

/// Animates a slide and fade in from the given direction
class SlideIn extends StatefulWidget {
  const SlideIn({
    super.key,
    this.animationCurve = Curves.fastOutSlowIn,
    this.duration = const Duration(milliseconds: 600),
    this.slideInDirection = AxisDirection.right,
    this.animationDirection = AnimationDirection.forward,
    this.onForwardComplete,
    this.onReverseComplete,
    this.onDismissed,
    required this.child,
  });

  /// Curve to apply to the animation, default is FastOutSlowIn
  final Curve animationCurve;
  /// Duration of the animation, default is 800 milliseconds
  final Duration duration;
  /// Direction to slide in from, default is the right
  final AxisDirection slideInDirection;
  /// The direction to run the animation
  final AnimationDirection animationDirection;
  /// A callback to execute when the animation completes its forward run
  final Function? onForwardComplete;
  /// A callback to execute when the animation completes its reverse run
  final Function? onReverseComplete;
  /// A callback to execute when the animation is dismissed
  final Function? onDismissed;
  final Widget child;

  @override
  State<SlideIn> createState() => _SlideInState();
}

class _SlideInState extends State<SlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationStatusListener _statusListener;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _statusListener = forwardStatus;

    _controller.addStatusListener(_statusListener);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void forwardStatus(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.completed:
        switch (widget.animationDirection) {
          case AnimationDirection.forward:
            widget.onForwardComplete != null ? widget.onForwardComplete!() : null;
            break;
          case AnimationDirection.reverse:
            widget.onReverseComplete != null ?  widget.onReverseComplete!(): null;
            break;
        }
        break;
      case AnimationStatus.dismissed:
        widget.onDismissed != null ?  widget.onDismissed!(): null;
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animationDirection == AnimationDirection.forward) {
      _controller.forward(from: 0.0);
    } else if (widget.animationDirection == AnimationDirection.reverse) {
      _controller.reverse(from: 1.0);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final animationPercent = widget.animationCurve.transform(_controller.value);
        final opacity = _controller.value;
        final slideDistance = (1.0 - animationPercent) * 150;

        Offset offset;

        switch (widget.slideInDirection) {
          case AxisDirection.down:
            offset = Offset(0, slideDistance);
            break;
          case AxisDirection.up:
            offset = Offset(0, -slideDistance);
            break;
          case AxisDirection.right:
            offset = Offset(slideDistance, 0);
            break;
          case AxisDirection.left:
            offset = Offset(-slideDistance, 0);
            break;
        }
  
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: offset,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}