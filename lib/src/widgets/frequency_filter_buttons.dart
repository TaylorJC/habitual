import 'package:flutter/material.dart';
import 'package:habitual/src/systems/habit_data/habit_data_controller.dart';
import 'package:habitual/src/systems/habit_data/habit_model.dart';

class FrequencyFilterButtons extends StatefulWidget {
  const FrequencyFilterButtons({
    super.key,
    required this.onFrequencyChange,
    required this.habitDataController,
  });

  final Function(Frequency frequency) onFrequencyChange;
  final HabitDataController habitDataController;

  @override
  State<FrequencyFilterButtons> createState() => _FrequencyFilterButtonsState();
}

class _FrequencyFilterButtonsState extends State<FrequencyFilterButtons> {
  Frequency _frequency = Frequency.all;

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
      padding: const EdgeInsets.all(0.0),
      child: SegmentedButton(
        segments: <ButtonSegment<Frequency>>[
          ButtonSegment<Frequency>(
            value: Frequency.all,
            label: Text('All', overflow: TextOverflow.fade, maxLines: 1, softWrap: false, style: TextStyle(fontSize: 12)),
            icon: Icon(Icons.view_compact),
          ),
          ButtonSegment<Frequency>(
            value: Frequency.daily,
            label: Text('Daily', overflow: TextOverflow.fade, maxLines: 1, softWrap: false, style: TextStyle(fontSize: 12)),
            icon: Icon(Icons.view_agenda_outlined),
            enabled: widget.habitDataController.frequencyCount(Frequency.daily) > 0,
          ),
          ButtonSegment<Frequency>(
            value: Frequency.weekly,
            label: Text('Weekly', overflow: TextOverflow.fade, maxLines: 1, softWrap: false, style: TextStyle(fontSize: 12)),
            icon: Icon(Icons.view_week_outlined),
            enabled: widget.habitDataController.frequencyCount(Frequency.weekly) > 0,
          ),
          ButtonSegment<Frequency>(
            value: Frequency.monthly,
            label: Text('Monthly', overflow: TextOverflow.fade, maxLines: 1, softWrap: false, style: TextStyle(fontSize: 12)),
            icon: Icon(Icons.grid_view),
            enabled: widget.habitDataController.frequencyCount(Frequency.monthly) > 0,
          ),
        ],
        selected: <Frequency>{_frequency},
        onSelectionChanged: (p0) {
          _frequency = p0.first;
          widget.onFrequencyChange(p0.first);
        },
      ),
    );
  }
}