import 'dart:math';

import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:habitual/src/systems/habit_data/habit_data_controller.dart';
import 'package:habitual/src/systems/habit_data/habit_model.dart';
import 'package:habitual/src/widgets/fluid_container.dart';
import 'package:habitual/src/widgets/frequency_filter_chips.dart';
import 'package:habitual/src/datetime_parse.dart';

class HabitDayView extends StatefulWidget {
  const HabitDayView({
    super.key,
    required this.habitDataController,
    required this.onDateChange,
    required this.onHabitSelected,
  });

  final HabitDataController habitDataController;
  final Function(DateTime) onDateChange;
  final Function(Habit) onHabitSelected;

  @override
  HabitDayViewState createState() => HabitDayViewState();
}

class HabitDayViewState extends State<HabitDayView>
    with TickerProviderStateMixin {
  List<Frequency> selectedFrequencies =
      List.of([Frequency.all], growable: true);
  // Frequency _selectedFrequency = Frequency.all;
  late List<Habit> shownHabits;
  late AnimationController _animationController;
  late AnimationController _dateAnimationController;
  DateTime _selectedDate = DateTime.now();
  bool _showDates = false;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    )..forward();

    _dateAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    shownHabits = widget.habitDataController.habitList;
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dateAnimationController.dispose();
    super.dispose();
  }

  void _updateList() {
    int selectedDateInt = dateTimeToInt(_selectedDate);

    shownHabits = widget.habitDataController.habitList.where((habit) {
        if (habit.dateCreated > selectedDateInt) return false;
        if (selectedFrequencies.contains(Frequency.all)) return true;
        if (selectedFrequencies.isEmpty) return true;

        return selectedFrequencies.contains(habit.frequency);
      }).toList();

    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      int columnCount =
          max((MediaQuery.of(context).size.width / 300).floor(), 2);
      DateTime today = DateTime.now();
      ColorScheme colorScheme = Theme.of(context).colorScheme;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final animationPercent =
                    Curves.easeOut.transform(_animationController.value);
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_showDates)
                    AnimatedBuilder(
                      animation: _dateAnimationController,
                      builder: (context, child) {
                        final animationPercent = Curves.fastEaseInToSlowEaseOut
                            .transform(_dateAnimationController.value);
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                            child: EasyTheme(
                              data: EasyTheme.of(context),
                              child: EasyDateTimeLinePicker(
                                firstDate: today.subtract(Duration(days: 30)),
                                lastDate: today,
                                headerOptions:
                                    HeaderOptions(headerType: HeaderType.none),
                                timelineOptions: TimelineOptions(height: 50),
                                selectionMode: SelectionMode.autoCenter(),
                                focusedDate: _selectedDate,
                                onDateChange: (date) {
                                  setState(() {
                                    _selectedDate = date;
                                    widget.onDateChange(_selectedDate);
                                    _updateList();
                                  });
                                },
                              ),
                            ),
                          ),
                          Divider(
                            height: 1,
                          ),
                        ],
                      ),
                    ),
                  AnimatedBuilder(
                    animation: _dateAnimationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _dateAnimationController.value),
                        child: child,
                      );
                    },
                    child: Wrap(
                      spacing: 8.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      runSpacing: 8.0,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (!_showDates) {
                              setState(() {
                                _showDates = !_showDates;
                              });
                              _dateAnimationController.forward(from: 0.0);
                            } else {
                              _dateAnimationController
                                  .reverse()
                                  .whenComplete(() {
                                setState(() {
                                  _showDates = !_showDates;
                                });
                              });
                            }
                          },
                          icon: _showDates
                              ? Icon(Icons.arrow_drop_up_sharp)
                              : Icon(
                                  Icons.arrow_drop_down_sharp,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                        ),
                        FrequencyFilterChips(
                            onFrequencyChange: (frequencies) {
                              selectedFrequencies = frequencies;
                        
                              _updateList();
                            },
                            habitDataController: widget.habitDataController),
                        if (_selectedDate.difference(DateTime.now()).inDays < 0)
                          Card(
                            color: colorScheme.secondaryContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${_selectedDate.year} - ${_selectedDate.month} - ${_selectedDate.day}',
                                style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        colorScheme.onSecondaryContainer),
                              ),
                            ),
                          ),
                        if (_selectedDate.difference(DateTime.now()).inDays ==
                            0)
                          Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: BubbleGrid(
                          selectedDate: _selectedDate,
                          shownHabits: shownHabits,
                          columnCount: columnCount,
                          widget: widget,
                        ),
          ),
        ],
      );
    });
  }
}

class BubbleGrid extends StatefulWidget {
  const BubbleGrid({
    super.key,
    required this.shownHabits,
    required this.columnCount,
    required this.widget,
    required this.selectedDate,
  });

  final List<Habit> shownHabits;
  final int columnCount;
  final HabitDayView widget;
  final DateTime selectedDate;

  @override
  BubbleGridState createState() => BubbleGridState();
}

class BubbleGridState extends State<BubbleGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggeredController;

  static const _initialDelayTime = Duration(milliseconds: 50);
  static const _itemSlideTime = Duration(milliseconds: 450);
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
        AnimationController(duration: _animationDuration, vsync: this)
          ..forward();
  }

  @override
  void dispose() {
    _itemSlideIntervals.clear();
    _staggeredController.dispose();
    super.dispose();
  }

  void _createAnimationIntervals() {
    _animationDuration = _initialDelayTime +
        (_staggerTime * widget.widget.habitDataController.habitList.length) +
        _buttonDelayTime +
        _buttonTime;

    for (var i = 0;
        i < widget.widget.habitDataController.habitList.length;
        ++i) {
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

  List<Widget> _buildListItems() {
    final listItems = <Widget>[];

    for (var i = 0; i < widget.shownHabits.length; ++i) {
      listItems.add(
        AnimatedBuilder(
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FluidFillingContainer(
            key: UniqueKey(),
                        shape: switch (widget.shownHabits[i].frequency) {
            Frequency.daily => FluidContainerShape.circle,
            Frequency.weekly => FluidContainerShape.roundedRectangle,
            Frequency.monthly => FluidContainerShape.diamond,
            _ => FluidContainerShape.roundedRectangle,
                        },
                        habitDataController: widget.widget.habitDataController,
                        selectedHabit: widget.shownHabits[i],
                        selectedDate: widget.selectedDate,
                        onTap: (habit) {
            widget.widget.onHabitSelected(habit);
                        }),
          ),
        ),
      );
    }
    return listItems;
  }

    @override
  Widget build(BuildContext context) {
    int count = (MediaQuery.sizeOf(context).width / 370).floor() + 1;
    return GridView.count(
      crossAxisCount: count,
      children: _buildListItems(),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Padding(
  //     padding: const EdgeInsets.all(32.0),
  //     child: Wrap(
  //       runSpacing: 32.0,
  //       spacing: 32.0,
  //       children: _buildListItems(),
  //     ),
  //   );
  // }
}
