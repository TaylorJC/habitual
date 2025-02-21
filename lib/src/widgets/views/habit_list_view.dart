import 'package:flutter/material.dart';

import 'package:habitual/src/systems/habit_data/habit_data_controller.dart';
import 'package:habitual/src/systems/habit_data/habit_model.dart';
import 'package:habitual/src/widgets/frequency_filter_buttons.dart';
import 'package:habitual/src/widgets/pinwheel.dart';

class HabitsView extends StatefulWidget {
  const HabitsView({
    super.key,
    required this.habitDataController,
    required this.onHabitSelected,
  });

  final HabitDataController habitDataController;
  final Function(Habit) onHabitSelected;

  @override
  HabitsViewState createState() => HabitsViewState();
}

class HabitsViewState extends State<HabitsView> with TickerProviderStateMixin {
  late List<Habit> userHabits = [];

  Frequency _selectedFrequency = Frequency.all;

  late AnimationController _staggeredController;
  late AnimationController _buttonController;

  static const _initialDelayTime = Duration(milliseconds: 50);
  static const _itemSlideTime = Duration(milliseconds: 350);
  static const _staggerTime = Duration(milliseconds: 100);
  static const _buttonDelayTime = Duration(milliseconds: 150);
  static const _buttonTime = Duration(milliseconds: 500);

  late Duration _animationDuration;

  final List<Interval> _itemSlideIntervals = [];

  @override
  void initState() {
    super.initState();

    _createAnimationIntervals();

    _staggeredController =
        AnimationController(duration: _animationDuration, vsync: this);

    _buttonController =
        AnimationController(duration: Duration(milliseconds: 600), vsync: this)
          ..forward();

    _updateList();
  }

  @override
  void dispose() {
    _staggeredController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _createAnimationIntervals() {
    _animationDuration = _initialDelayTime +
        (_staggerTime * widget.habitDataController.habitList.length) +
        _buttonDelayTime +
        _buttonTime;

    for (var i = 0; i < widget.habitDataController.habitList.length; ++i) {
      final startTime = _initialDelayTime + (_staggerTime * i);
      final endTime = startTime + _itemSlideTime;
      _itemSlideIntervals.add(
        Interval(
          startTime.inMilliseconds / _animationDuration.inMilliseconds,
          endTime.inMilliseconds / _animationDuration.inMilliseconds,
        ),
      );
    }
  }

  void _updateList() {
    _staggeredController.reset();

    setState(() {
      // Rebuilding the list view
      if (_selectedFrequency == Frequency.all) {
        userHabits = widget.habitDataController.habitList;
      } else {
        userHabits = widget.habitDataController.habitList
            .where((x) => x.frequency == _selectedFrequency)
            .toList();
      }
    });

    _staggeredController.forward();
  }

  List<Widget> _buildListItems() {
    final listItems = <Widget>[];
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    Icon habitIcon;

    for (var i = 0; i < userHabits.length; ++i) {
      switch (userHabits[i].frequency) {
        case Frequency.daily:
          habitIcon = Icon(
            Icons.view_agenda_rounded,
            color: colorScheme.primary,
          );
          break;
        case Frequency.weekly:
          habitIcon = Icon(
            Icons.view_week_rounded,
            color: colorScheme.primary,
          );
          break;
        case Frequency.monthly:
          habitIcon = Icon(
            Icons.grid_view_rounded,
            color: colorScheme.primary,
          );
          break;
        default:
          habitIcon = Icon(
            Icons.view_agenda_rounded,
            color: colorScheme.primary,
          );
          break;
      }
      listItems.add(
        AnimatedBuilder(
          key: UniqueKey(),
          animation: _staggeredController,
          builder: (context, child) {
            final animationPercent = Curves.easeOut.transform(
              _itemSlideIntervals[i].transform(_staggeredController.value),
            );
            final opacity = animationPercent;
            final slideDistance = (1.0 - animationPercent) * 150;

            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(slideDistance, 0),
                child: child,
              ),
            );
          },
          child: ListTile(
            tileColor: colorScheme.primaryContainer,
            title: Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12.0),
                onLongPress: () async {
                  showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return ConfirmDeleteAlert();
                      }).then((result) {
                    if (result != null && result) {
                      Habit habit = userHabits[i];
                      setState(() {
                        // Remove the habit for the store and update our list.
                        widget.habitDataController.removeHabit(habit);
                        _updateList();
                      });

                      if (context.mounted) {
                        // Display snackbar annoucing deletion and give opportunity to undo
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('Habit deleted'),
                          action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                widget.habitDataController.updateHabit(habit);
                                _updateList();
                              }),
                        ));
                      }
                    }
                  });
                },
                onTap: () {
                  widget.onHabitSelected(userHabits[i]);
                  // Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //   return HabitHistoryView(habit: userHabits[i]);
                  // }));
                },
                child: Container(
                  margin: EdgeInsets.all(16.0),
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      habitIcon,
                      Column(
                        children: [
                          Text(userHabits[i].title,
                              maxLines: 2,
                              style: TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                  fontSize: 16)),
                          if (userHabits[i].duration != null)
                            Text('${userHabits[i].duration} ${userHabits[i].durationType.name}',
                              maxLines: 2,
                              style: TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                  fontSize: 12)),
                        ],
                      ),
                      Card(
                          color: colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: PinwheelSpinner(
                                speed: userHabits[i].getCurrentStreak()),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return listItems;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _buttonController,
          builder: (context, child) {
            final animationPercent =
                Curves.easeOut.transform(_buttonController.value);
            final opacity = animationPercent;
            final slideDistance = (1.0 - animationPercent) * 150;

            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, -slideDistance),
                child: child,
              ),
            );
          },
          child: FrequencyFilterButtons(
              habitDataController: widget.habitDataController,
              onFrequencyChange: (newFrequency) {
                setState(() {
                  _selectedFrequency = newFrequency;
                  _updateList();
                });
              }),
        ),
        Expanded(
            child: ListView(
          // children: _buildExpansionItems(),
          children: _buildListItems(),
        )),
      ],
    );
  }
}

// class HabitExpansionTile extends StatefulWidget {
//   const HabitExpansionTile({
//     super.key,
//     required this.colorScheme,
//     required this.habit,
//     required this.widget,
//     required this.updateCallback,
//   });

//   final ColorScheme colorScheme;
//   final Habit habit;
//   final HabitsView widget;
//   final Function() updateCallback;

//   @override
//   State<HabitExpansionTile> createState() => _HabitExpansionTileState();
// }

// class _HabitExpansionTileState extends State<HabitExpansionTile> {
//   @override
//   Widget build(BuildContext context) {
//     return ExpansionTile(
//       shape: Border.all(style: BorderStyle.none),
//       showTrailingIcon: false,
//       title: Builder(builder: (context) {
//         return Card(
//             margin: EdgeInsets.all(5.0),
//             clipBehavior: Clip.hardEdge,
//             color: widget.colorScheme.surfaceContainer,
//             child: InkWell(
//               splashColor: widget.colorScheme.primaryFixedDim,
//               onTap: () {
//                 var controller = ExpansionTileController.of(context);
//                 if (controller.isExpanded) {
//                   controller.collapse();
//                 } else {
//                   controller.expand();
//                 }
//               },
//               onLongPress: () async {
//                 showDialog<bool>(
//                     context: context,
//                     builder: (context) {
//                       return ConfirmDeleteAlert();
//                     }).then((result) {
//                   if (result != null && result) {
//                     var controller = ExpansionTileController.of(context);
//                     if (controller.isExpanded) {
//                       controller.collapse();
//                     }
//                     setState(() {
//                       // Remove the habit for the store and update our list.
//                       widget.widget.habitDataController
//                           .removeHabit(widget.habit);

//                       widget.updateCallback();
//                     });

//                     // Display snackbar annoucing deletion and give opportunity to undo
//                     if (context.mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                         content: const Text('Habit deleted'),
//                         action: SnackBarAction(
//                             label: 'Undo',
//                             onPressed: () {
//                               widget.widget.habitDataController
//                                   .updateHabit(widget.habit);
//                               widget.updateCallback();
//                             }),
//                       ));
//                     }
//                   }
//                 });
//               },
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     Column(
//                       children: [
//                         if (widget.habit.frequency == Frequency.monthly)
//                           Icon(Icons.grid_view_rounded),
//                         if (widget.habit.frequency == Frequency.weekly)
//                           Icon(Icons.view_week_rounded),
//                         if (widget.habit.frequency == Frequency.daily)
//                           Icon(Icons.view_agenda_rounded),
//                       ],
//                     ),
//                     Expanded(
//                       child: Container(
//                         alignment: Alignment.topCenter,
//                         padding: EdgeInsets.all(4.0),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Text(
//                             widget.habit.title,
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: widget.colorScheme.onSecondaryContainer),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                         padding: EdgeInsets.all(4.0),
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8.0),
//                             color: widget.colorScheme.secondaryContainer),
//                         child: PinwheelSpinner(
//                             speed: min(widget.habit.getCurrentStreak(), 5))),
//                   ],
//                 ),
//               ),
//             ));
//       }),
//       children: [
//         Align(
//           alignment: Alignment.centerLeft,
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Card(
//               margin: EdgeInsets.all(5.0),
//               color: widget.colorScheme.surfaceContainer,
//               child: Padding(
//                 padding: const EdgeInsets.all(0.0),
//                 child: Column(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8.0),
//                           gradient: SweepGradient(
//                               center: Alignment.bottomCenter,
//                               colors: [
//                                 widget.colorScheme.primaryContainer,
//                                 widget.colorScheme.surfaceContainer,
//                               ])),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(
//                               'Current Streak: ${widget.habit.getCurrentStreak()}',
//                               style: TextStyle(
//                                 color: widget.colorScheme.onPrimaryContainer,
//                               ),
//                             ),
//                           ),
//                           Divider(
//                             height: 1,
//                             indent: 8.0,
//                             endIndent: 128.0,
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(
//                               'Longest Streak: ${widget.habit.getLongestStreak()}',
//                               style: TextStyle(
//                                 color: widget.colorScheme.onPrimaryContainer,
//                               ),
//                             ),
//                           ),
//                           Divider(
//                             height: 1,
//                             indent: 8.0,
//                             endIndent: 64.0,
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(
//                               'Date Created: ${dateTimeIntToYMDString(widget.habit.dateCreated)}',
//                               style: TextStyle(
//                                 color: widget.colorScheme.onPrimaryContainer,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     if (widget.habit.datesCompleted.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(16.0, 16, 16, 8.0),
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 widget.colorScheme.secondaryContainer,
//                           ),
//                           onPressed: () {
//                             Navigator.push(context,
//                                 MaterialPageRoute(builder: (context) {
//                               return HabitHistoryView(habit: widget.habit);
//                             }));
//                           },
//                           child: Text(
//                             'View History',
//                             style: TextStyle(
//                               color: widget.colorScheme.onPrimaryContainer,
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }
// }

class ConfirmDeleteAlert extends StatelessWidget {
  const ConfirmDeleteAlert({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text('Delete habit?'),
        icon: Icon(Icons.delete_forever),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Delete', style: TextStyle(color: Colors.white))),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel')),
        ]);
  }
}
