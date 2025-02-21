import 'package:flutter/material.dart';
import 'package:habitual/systems/habit_data/habit_data_controller.dart';
import 'package:habitual/systems/habit_data/habit_model.dart';

class AddActionButton extends StatefulWidget {
  AddActionButton({
    super.key,
    required this.habitDataController,
    required this.selectedHabit,
    required this.turnState,
    required this.onChanged,
  });

  final HabitDataController habitDataController;
  final ValueChanged<bool> onChanged;
  final Habit? selectedHabit;
  bool turnState;

  @override
  State<AddActionButton> createState() => AddActionButtonState();
}

class AddActionButtonState extends State<AddActionButton> {
  double get turns => widget.turnState ? 1.5 : 0;

  void _toggle() {
    setState(() {
      widget.turnState = !widget.turnState;
      widget.onChanged(widget.turnState);
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AnimatedRotation(
      turns: turns,
      duration: const Duration(milliseconds: 500),
      curve: Curves.decelerate,
      child: FloatingActionButton(
        onPressed: () {
          _toggle();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: !widget.turnState ? (widget.selectedHabit == null ? Icon(Icons.add, color: colorScheme.onPrimaryContainer,) : Icon(Icons.edit, color: colorScheme.onPrimaryContainer,)) : Icon(Icons.close, color: colorScheme.onPrimaryContainer,),
        ),
      ),
    );
  }
}
