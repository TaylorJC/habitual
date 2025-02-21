import 'package:flutter/material.dart';

class DisappearingNavigationRail extends StatefulWidget {
  const DisappearingNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.title,
    required this.destinations,
    this.onDestinationSelected,
  });

  final int selectedIndex;
  final String title;
  final List<NavigationRailDestination> destinations;
  final ValueChanged<int>? onDestinationSelected;

  @override
  State<DisappearingNavigationRail> createState() =>
      _DisappearingNavigationRailState();
}

class _DisappearingNavigationRailState
    extends State<DisappearingNavigationRail> with SingleTickerProviderStateMixin {
  final showBadge = false;

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
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
            animation: _animationController,
      builder: (context, child) {
        final animationPercent = Curves.easeOut.transform(_animationController.value);
        final opacity = 1.0;
        final slideDistance = (1.0 - animationPercent) * 150;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(-slideDistance, 0),
            child: child,
          ),
        );
      },
      child: NavigationRail(
        selectedIndex: widget.selectedIndex,
        backgroundColor: colorScheme.primaryContainer,
        onDestinationSelected: widget.onDestinationSelected,
        useIndicator: true,
        indicatorColor: colorScheme.primary,
        labelType: NavigationRailLabelType.selected,
        leading: Column(
          children: [
            Container(
                margin: EdgeInsets.all(4.0),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: colorScheme.primary,
                ),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                )),
            const SizedBox(height: 20),
          ],
        ),
        groupAlignment: -0.85,
        destinations: widget.destinations,
      ),
    );
  }
}
