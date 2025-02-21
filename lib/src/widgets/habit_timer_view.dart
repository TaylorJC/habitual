import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:habitual/src/systems/habit_data/habit_data_controller.dart';
import 'package:habitual/src/systems/habit_data/habit_model.dart';

class HabitTimerView extends StatefulWidget {
  const HabitTimerView(
      {super.key,
      required this.habit,
      required this.habitDataController,
      required this.date,
      required this.onClose});

  final Habit habit;
  final HabitDataController habitDataController;
  final DateTime date;
  final Function onClose;

  @override
  State<HabitTimerView> createState() => _HabitTimerViewState();
}

class _HabitTimerViewState extends State<HabitTimerView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late CountDownController _countDownController;
  late ColorScheme colorScheme;
  late int habitDuration;

  @override
  void initState() {
    _countDownController = CountDownController();

    final int durationLen = widget.habit.duration!;
    switch (widget.habit.durationType) {
      case DurationType.hours:
        habitDuration = durationLen * (60 * 60);
        break;
      case DurationType.minutes:
        habitDuration = durationLen * 60;
        break;
      case DurationType.seconds:
        habitDuration = durationLen;
        break;
    }

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateHabit() {
    setState(() {
      widget.habit.increment(widget.date);
      widget.habitDataController.updateHabit(widget.habit);
    });
  }

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final animationPercent =
                  Curves.easeOut.transform(_animationController.value);
              final opacity = _animationController.value;
              final slideDistance = (-1.0 + animationPercent) * 150;
        
              return Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(0, slideDistance),
                  child: child,
                ),
              );
            },
            child: Center(
              child: SizedBox(
                width: 350,
                child: Card(
                  color: colorScheme.surfaceContainer,
                  margin: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            widget.onClose();
                          },
                          label: Icon(Icons.close),
                        ),
                      ),
        
                      Text(
                        widget.habit.title,
                        style: TextStyle(color: colorScheme.onPrimaryContainer),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                          '${widget.habit.duration} ${widget.habit.durationType.name}',
                          style:
                              TextStyle(color: colorScheme.onPrimaryContainer)),
                      Divider(
                        indent: 26,
                        endIndent: 26,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                        margin: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.0),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                colorScheme.primaryContainer,
                                colorScheme.surfaceContainer,
                              ]
                            )
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: _countDownController.getTime() != '0' ?  Column(
                              children: [
                                  CircularCountDownTimer(
                                    controller: _countDownController,
                                    width: 200,
                                    height: 200,
                                    autoStart: false,
                                    isReverse: true,
                                    isReverseAnimation: false,
                                    duration: habitDuration,
                                    textStyle: TextStyle(
                                      fontSize: 18,
                                      color: colorScheme.onSurface,
                                    ),
                                    fillColor: colorScheme.primary,
                                    ringColor: colorScheme.surfaceContainer,
                                    onComplete: () {
                                      if (_countDownController.getTime() == '0') {
                                        _updateHabit();
                                      }
                                      
                                    },
                                  ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 24, 12, 0),
                                  child: Row(
                                    spacing: 24,
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                          onPressed: () {
                                            if (_countDownController
                                                .isPaused.value) {
                                              _countDownController.resume();
                                            } else if (!_countDownController
                                                .isStarted.value) {
                                              _countDownController.start();
                                            } else {
                                              _countDownController.pause();
                                            }
                                            setState(() {
                                              // Rebuild icon
                                            });
                                          },
                                          label: _countDownController
                                                      .isPaused.value ||
                                                  !_countDownController
                                                      .isStarted.value
                                              ? Icon(Icons.play_circle_rounded)
                                              : Icon(Icons
                                                  .pause_circle_filled_rounded)),
                                      ElevatedButton.icon(
                                          onPressed: () {
                                            _countDownController.restart();
                                            _countDownController.pause();
                                            setState(() {});
                                          },
                                          label: Icon(Icons.restart_alt_rounded)),
                                    ],
                                  ),
                                )
                              ],
                            ) : SizedBox( width: 400, child: Center(child: Text('Complete!', ))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
