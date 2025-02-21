import 'package:flutter/material.dart';

class DisappearringNavBar extends StatefulWidget {
  const DisappearringNavBar({
    super.key,
    required this.selectedIndex,
    required this.destinations,
    this.onDestinationSelected,
  });

  final int selectedIndex;
  final List<NavigationDestination> destinations;
  final ValueChanged<int>? onDestinationSelected;

  @override
  State<DisappearringNavBar> createState() => _DisappearringNavBarState();
}

class _DisappearringNavBarState extends State<DisappearringNavBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this, 
      duration: Duration(milliseconds: 600)
    )..forward();

    super.initState();
  } 

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animationPercent = Curves.easeOut.transform(_animationController.value);
        final opacity = 1.0;
        final slideDistance = (1.0 - animationPercent) * 150;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, slideDistance),
            child: child,
          ),
        );
      },
      child: NavigationBar(
        elevation: 0,
        backgroundColor: colorScheme.primaryContainer,
        indicatorColor: colorScheme.primary,
        destinations: widget.destinations,
        selectedIndex: widget.selectedIndex,
        onDestinationSelected: widget.onDestinationSelected,
      ),
    );
  }
}
