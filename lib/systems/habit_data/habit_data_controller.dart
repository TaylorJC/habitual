import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:habitual/systems/habit_data/habit_data_service.dart';
import 'package:habitual/systems/habit_data/habit_model.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class HabitDataController with ChangeNotifier {
  HabitDataController(this._habitService);

  final HabitDataService _habitService;

  late HashMap<int, Habit> _userHabits;
  late List<Habit> _habitList;

  HashMap<int, Habit> get userHabits => _userHabits;
  List<Habit> get habitList => _habitList;


  List<Habit> uncompletedHabits(DateTime checkDate) {
    return habitList.where((habit) => !habit.completed(checkDate)).toList();
  }

  int frequencyCount(Frequency frequency) {
    return habitList.where((habit) => habit.frequency == frequency).length;
  }

  Future<void> loadHabits() async {
    _userHabits = await _habitService.getUserHabits();
    _habitList = List.from(_userHabits.values);

    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  Future<void> updateHabit(Habit? habit) async {
    if (habit == null) return;

    _userHabits.update(habit.id, (value) => habit, ifAbsent: () => habit);
    _habitList = List.from(_userHabits.values);

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _habitService.updateHabit(habit);
  }

  Future<void> removeHabit(Habit? habit) async {
    if (habit == null) return;

    _userHabits.remove(habit.id);
    _habitList = List.from(_userHabits.values);

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _habitService.removeHabit(habit);
  }
}