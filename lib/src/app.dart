import 'package:flutter/material.dart';
import 'package:habitual/src/systems/habit_data/habit_data_controller.dart';
import 'package:habitual/src/systems/habit_data/habit_model.dart';
import 'package:habitual/src/systems/settings/settings_controller.dart';
import 'package:habitual/src/widgets/add_action_button.dart';
import 'package:habitual/src/widgets/views/add_habit_view.dart';
import 'package:habitual/src/widgets/nav_components/disappearing_navigation_rail.dart';
import 'package:habitual/src/widgets/nav_components/disappearring_nav_bar.dart';
import 'package:habitual/src/widgets/views/habit_history_view.dart';
import 'package:habitual/src/widgets/views/habit_list_view.dart';
import 'package:habitual/src/widgets/views/settings_view.dart';
import 'package:habitual/src/widgets/views/habit_day_view.dart';
import 'package:habitual/src/widgets/habit_timer_view.dart';

enum AppState {
  main,
  addForm,
  historyForm,
  timerForm,
}

class Habitual extends StatefulWidget {
  const Habitual({
    super.key,
    required this.settingsController,
    required this.habitDataController,
  });

  final HabitDataController habitDataController;
  final SettingsController settingsController;

  @override
  State<Habitual> createState() {
    return HabitualState();
  }
}

class HabitualState extends State<Habitual> with SingleTickerProviderStateMixin {
  int selectedIndex = 0;

  AppState _state = AppState.main;
  bool wideScreen = false;

  late AnimationController _formAnimationController;

  final Key formKey = UniqueKey();
  Habit? _selectedHabit = null;
  late DateTime _selectedDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();

    _formAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final double width = MediaQuery.of(context).size.width;
    wideScreen = width > 600;
  }

  @override
  void dispose() {
    _formAnimationController.dispose();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) => 
        MaterialApp(
            title: 'Habitual',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: widget.settingsController.themeColor),
              useMaterial3: true,
            ),
            darkTheme: ThemeData.from(
                colorScheme: ColorScheme.fromSeed(
                    seedColor: widget.settingsController.themeColor,
                    brightness: Brightness.dark)),
            themeMode: widget.settingsController.themeMode,
            home: Builder(builder: (context) {
              return Scaffold(
                backgroundColor: Theme.of(context).colorScheme.surface,
                body: Row(
                  children: [
                    if (wideScreen)
                      DisappearingNavigationRail(
                        selectedIndex: selectedIndex,
                        title: 'Habitual',
                        destinations: [
                          NavigationRailDestination(
                            icon: Icon(Icons.home, color: Theme.of(context).colorScheme.onPrimaryContainer,), 
                            label: Text("Home", style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer,),)),
                        NavigationRailDestination(
                            icon: Icon(Icons.list_alt_sharp, color: Theme.of(context).colorScheme.onPrimaryContainer,), label: Text("Habits", style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer,),)),
                        NavigationRailDestination(
                            icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.onPrimaryContainer,), label: Text("Settings", style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer,),)),
                        ],
                        onDestinationSelected: (index) {
                          setState(() {
                            selectedIndex = index;
                            _selectedHabit = null;
                            _state = AppState.main;
                          });
                        },
                      ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0.0, 10, 0, 0),
                        child: Card(
                          child: Builder(builder: (context) {
                            if (_state == AppState.addForm) {
                              return AnimatedBuilder(
                                animation: _formAnimationController,
                                builder: (context, child) {
                                  final animationPercent = Curves.fastEaseInToSlowEaseOut.transform(_formAnimationController.value);
                                  final opacity = _formAnimationController.value;
                                  final slideDistance = (1.0 - animationPercent) * 150;
                                                      
                                  return Opacity(
                                    opacity: opacity,
                                    child: Transform.translate(
                                      offset: Offset(slideDistance, 0),
                                      child: child,
                                    ),
                                  );
                                },
                                child: AddHabitForm(
                                key: formKey,
                                habitDataController: widget.habitDataController,
                                editingHabit: _selectedHabit,
                                onSubmit: (value) {
                                  _formAnimationController.reverse().whenComplete(() {
                                  setState(() {
                                    _state = AppState.main;
                                    _selectedHabit = null;
                                  });
                                });
                                },
                                ),
                              );
                            }
                          if (_state == AppState.historyForm) {
                            return AnimatedBuilder(
                              animation: _formAnimationController,
                                builder: (context, child) {
                                  final animationPercent = Curves.fastOutSlowIn.transform(_formAnimationController.value);
                                  final opacity = _formAnimationController.value;
                                  final slideDistance = (-1.0 + animationPercent) * 150;
                            
                                  return Opacity(
                                    opacity: opacity,
                                    child: Transform.translate(
                                      offset: Offset(0, slideDistance),
                                      child: child,
                                    ),
                                  );
                                },
                              child: HabitHistoryView(habit: _selectedHabit!, onClose: () {
                                _formAnimationController.reverse().whenComplete(() {
                                      setState(() {
                                        _state = AppState.main;
                                        _selectedHabit = null;
                                      });
                                    });
                              },
                              onEdit: () {
                                setState(() {
                                  _state = AppState.addForm;
                                });
                              },
                              ),
                            );
                          }
                          
                          if (_state == AppState.timerForm) {
                            return AnimatedBuilder(
                              animation: _formAnimationController,
                                builder: (context, child) {
                                  final animationPercent = Curves.fastOutSlowIn.transform(_formAnimationController.value);
                                  final opacity = _formAnimationController.value;
                                  final slideDistance = (-1.0 + animationPercent) * 150;
                            
                                  return Opacity(
                                    opacity: opacity,
                                    child: Transform.translate(
                                      offset: Offset(0, slideDistance),
                                      child: child,
                                    ),
                                  );
                                },
                              child: HabitTimerView(habit: _selectedHabit!, habitDataController: widget.habitDataController, date: _selectedDate, onClose: () {
                                _formAnimationController.reverse().whenComplete(() {
                                      setState(() {
                                        _state = AppState.main;
                                        _selectedHabit = null;
                                      });
                                    });
                              },),
                            );
                          }
                          
                          if (_state == AppState.main) {
                            return Container(
                              color: Theme.of(context).colorScheme.surface,
                              child: Builder(builder: (context) {
                                if (selectedIndex == 0) {
                                  return HabitDayView(
                                      habitDataController:
                                          widget.habitDataController,
                                      onHabitSelected: (habit) {
                                        setState(() {
                                          _selectedHabit = habit;
                                          _state = AppState.timerForm;
                                          _formAnimationController.forward(from: 0.0);
                                        });
                                      },
                                      onDateChange: (newDate) {
                                        setState(() {
                                          _selectedDate = newDate;
                                        });
                                      }
                                  );
                                } else if (selectedIndex == 1) {
                                  return HabitsView(
                                      habitDataController:
                                          widget.habitDataController,
                                      onHabitSelected: (habit) {
                                        setState(() {
                                          _selectedHabit = habit;
                                          _state = AppState.historyForm;
                                          _formAnimationController.forward(from: 0.0);
                                        });
                                      },
                                    );
                                } else if (selectedIndex == 2) {
                                  return SettingsView(
                                      settingsController:
                                          widget.settingsController
                                  );
                                }
                                                      
                                return SettingsView(
                                    settingsController:
                                        widget.settingsController);
                              }),
                            );
                          }
                          
                          return Container();
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                floatingActionButton: AnimatedBuilder(
                  animation: _formAnimationController,
                  builder: (context, child) {
                    return AnimatedRotation(
                      turns: _selectedHabit  == null ? 0 : 1, 
                      duration: Duration(milliseconds: 400),
                      child: child,
                    );
                  },
                  child: AddActionButton(
                          habitDataController: widget.habitDataController,
                          selectedHabit: _selectedHabit,
                          turnState: _state == AppState.addForm,
                          onChanged: (formState) {
                            if (formState) {
                              setState(() {
                                  _state = AppState.addForm;
                                });
                              _formAnimationController.forward();
                            } else {
                              _formAnimationController.reverse();
                              setState(() {
                                  _state = AppState.main;
                                  _selectedHabit = null;
                                });
                            }
                            
                          }),
                ),
                bottomNavigationBar: wideScreen
                    ? null
                    : DisappearringNavBar(
                        selectedIndex: selectedIndex,
                        destinations: [
                          NavigationDestination(icon: Icon(Icons.home, color: Theme.of(context).colorScheme.onPrimaryContainer), label: "Home"),
                          NavigationDestination(
                              icon: Icon(Icons.list_alt_sharp, color: Theme.of(context).colorScheme.onPrimaryContainer), label: "Habits"),
                          NavigationDestination(icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.onPrimaryContainer), label: "Settings"),
                        ],
                        onDestinationSelected: (index) {
                          setState(() {
                            selectedIndex = index;
                            _selectedHabit = null;
                            _state = AppState.main;
                          });
                        },
                      ),
              );
            })),
    );
  }
}
