import 'package:flutter/material.dart';
import 'package:habitual/src/datetime_parse.dart';
import 'package:habitual/src/systems/habit_data/habit_data_controller.dart';
import 'package:habitual/src/systems/habit_data/habit_model.dart';

/// Form to add a new habit or edit an existing one.
class AddHabitForm extends StatefulWidget {
  const AddHabitForm({
    super.key,
    required this.onSubmit,
    required this.editingHabit,
    required this.habitDataController,
  });

  final ValueChanged<bool> onSubmit;
  final Habit? editingHabit;
  final HabitDataController habitDataController;

  @override
  AddHabitFormState createState() {
    return AddHabitFormState();
  }
}

class AddHabitFormState extends State<AddHabitForm> with SingleTickerProviderStateMixin {
  final _formkey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final durationController = TextEditingController();
  late AnimationController _animationController;

  Frequency _selectedFrequency = Frequency.daily;
  DurationType _selectedDuration = DurationType.minutes;
  int? _enteredDuration;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 400))..forward();
    if (widget.editingHabit != null) {
      titleController.text = widget.editingHabit!.title;
      _selectedFrequency = widget.editingHabit!.frequency;
      _selectedDuration = widget.editingHabit!.durationType;

      if (widget.editingHabit!.duration != null) {
        durationController.text = widget.editingHabit!.duration.toString();
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animationPercent =
            Curves.easeOut.transform(_animationController.value);
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
      child: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 600,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.0),
                  color: colorScheme.surfaceContainer,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    spacing: 8.0,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          // color: colorScheme.primaryContainer
                        ),
                        child: Text(
                          widget.editingHabit == null
                              ? 'Track A New Habit'
                              : 'Edit Habit',
                          style: TextStyle(
                            fontSize: 20,
                            // fontWeight: FontWeight.w100,
                            // color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      Divider(
                        height: 5,
                      ),
                      Form(
                          key: _formkey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 8.0,
                            children: <Widget>[
                              Card(
                                color: colorScheme.surfaceBright,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: Size.infinite.width,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16.0, 16, 16, 8),
                                        child: TextFormField(
                                          controller: titleController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Title (Required)',
                                          ),
                                          textCapitalization:
                                              TextCapitalization.words,
                                          autofocus: true,
                                          maxLength: 30,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter a descriptive name';
                                            }

                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: Size.infinite.width,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 0, 8, 8),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Center(
                                              child: Wrap(
                                                spacing: 8.0,
                                                runSpacing: 8.0,
                                                children: [
                                                  FilterChip.elevated(
                                                      label: Text('Daily'),
                                                      selected:
                                                          _selectedFrequency ==
                                                              (Frequency.daily),
                                                      onSelected: (selected) {
                                                        if (selected) {
                                                          setState(() {
                                                            _selectedFrequency =
                                                                Frequency.daily;
                                                          });
                                                        }
                                                      }),
                                                  FilterChip.elevated(
                                                      label: Text('Weekly'),
                                                      selected:
                                                          _selectedFrequency ==
                                                              (Frequency
                                                                  .weekly),
                                                      onSelected: (selected) {
                                                        if (selected) {
                                                          setState(() {
                                                            _selectedFrequency =
                                                                Frequency
                                                                    .weekly;
                                                          });
                                                        }
                                                      }),
                                                  FilterChip.elevated(
                                                      label: Text('Monthly'),
                                                      selected:
                                                          _selectedFrequency ==
                                                              (Frequency
                                                                  .monthly),
                                                      onSelected: (selected) {
                                                        if (selected) {
                                                          setState(() {
                                                            _selectedFrequency =
                                                                Frequency
                                                                    .monthly;
                                                          });
                                                        }
                                                      }),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Card(
                                color: colorScheme.surfaceBright,
                                // width: Size.infinite.width,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: TextFormField(
                                          controller: durationController,
                                          maxLength: 4,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            border: UnderlineInputBorder(),
                                            labelText: 'Duration (Optional)',
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return null;
                                            }

                                            int? duration = int.tryParse(value);
                                            if (duration == null) {
                                              return 'Please enter a valid number or leave blank';
                                            } else {
                                              _enteredDuration = duration;
                                              return null;
                                            }
                                          },
                                        ),
                                      ),
                                      Center(
                                        child: Wrap(
                                          spacing: 8.0,
                                          runSpacing: 8.0,
                                          children: [
                                            FilterChip.elevated(
                                                label: Text('Seconds'),
                                                selected: _selectedDuration ==
                                                    (DurationType.seconds),
                                                onSelected: (selected) {
                                                  if (selected) {
                                                    setState(() {
                                                      _selectedDuration =
                                                          DurationType.seconds;
                                                    });
                                                  }
                                                }),
                                            FilterChip.elevated(
                                                label: Text('Minutes'),
                                                selected: _selectedDuration ==
                                                    (DurationType.minutes),
                                                onSelected: (selected) {
                                                  if (selected) {
                                                    setState(() {
                                                      _selectedDuration =
                                                          DurationType.minutes;
                                                    });
                                                  }
                                                }),
                                            FilterChip.elevated(
                                                label: Text('Hours'),
                                                selected: _selectedDuration ==
                                                    (DurationType.hours),
                                                onSelected: (selected) {
                                                  if (selected) {
                                                    setState(() {
                                                      _selectedDuration =
                                                          DurationType.hours;
                                                    });
                                                  }
                                                }),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
                        child: ElevatedButton(
                            onPressed: () {
                              if (_formkey.currentState!.validate()) {
                                int index = widget.editingHabit != null ? widget.editingHabit!.id :
                                    widget.habitDataController.habitList.length;
         
      
                                widget.habitDataController.updateHabit(Habit(
                                  index,
                                  titleController.text,
                                  _selectedFrequency,
                                  _selectedDuration,
                                  _enteredDuration,
                                  widget.editingHabit != null ? widget.editingHabit!.datesCompleted : List<int>.empty(growable: true),
                                  widget.editingHabit != null ? widget.editingHabit!.dateCreated : dateTimeNowToInt(),
                                ));
      

                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: widget.editingHabit != null
                                            ? Text('Habit updated!')
                                            : Text('Habit added!')));
                              }

                              setState(() {
                                widget.onSubmit(true);
                              });
                            },
                            child: Text(
                              'Submit',
                              style: TextStyle(fontSize: 20),
                            )),
                      )
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
