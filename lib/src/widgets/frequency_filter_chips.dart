import 'package:flutter/material.dart';
import 'package:habitual/src/systems/habit_data/habit_data_controller.dart';
import 'package:habitual/src/systems/habit_data/habit_model.dart';

class FrequencyFilterChips extends StatefulWidget {
  const FrequencyFilterChips({
    super.key,
    required this.onFrequencyChange,
    required this.habitDataController,
  });

  final Function(List<Frequency> frequencies) onFrequencyChange;
  final HabitDataController habitDataController;

  @override
  State<FrequencyFilterChips> createState() => _FrequencyFilterChipsState();
}

class _FrequencyFilterChipsState extends State<FrequencyFilterChips> {
  List<Frequency> selectedFrequencies = List.of([Frequency.all], growable: true);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        runSpacing: 4.0,
        spacing: 4.0,
        children: [
          if (widget.habitDataController.frequencyCount(Frequency.daily) > 0)
            FilterChip.elevated(
              label: Text('Daily', style: TextStyle(fontSize: 14),), 
              showCheckmark: false,
              selected: selectedFrequencies.contains(Frequency.daily),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedFrequencies.add(Frequency.daily);
                    selectedFrequencies.remove(Frequency.all);
                  } else {
                    selectedFrequencies.remove(Frequency.daily);
                  }
      
                  widget.onFrequencyChange(selectedFrequencies);
                });
              }
            ),
          if (widget.habitDataController.frequencyCount(Frequency.weekly) > 0)
            FilterChip.elevated(
              label: Text('Weekly', style: TextStyle(fontSize: 14)), 
              showCheckmark: false,
              selected: selectedFrequencies.contains(Frequency.weekly),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedFrequencies.add(Frequency.weekly);
                    selectedFrequencies.remove(Frequency.all);
                  } else {
                    selectedFrequencies.remove(Frequency.weekly);
                  }
      
                  widget.onFrequencyChange(selectedFrequencies);
                });
              }
            ),
          if (widget.habitDataController.frequencyCount(Frequency.monthly) > 0)
            FilterChip.elevated(
              label: Text('Monthly', style: TextStyle(fontSize: 14)),
              showCheckmark: false, 
              selected: selectedFrequencies.contains(Frequency.monthly),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedFrequencies.add(Frequency.monthly);
                    selectedFrequencies.remove(Frequency.all);
                  } else {
                    selectedFrequencies.remove(Frequency.monthly);
                  }
      
                  widget.onFrequencyChange(selectedFrequencies);
                });
              }
            ),
        ]
      ),
    );
  }
}