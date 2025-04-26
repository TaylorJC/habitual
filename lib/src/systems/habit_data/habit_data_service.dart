import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:habitual/src/systems/habit_data/habit_model.dart';
import 'package:habitual/src/systems/habit_data/habit_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service that stores and retrieves user habit data.
class HabitDataService {
  /// Loads the user's habit data from local or remote storage.
  Future<HashMap<int, Habit>> getUserHabits() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.clear();

    HashMap<int, Habit> userHabits = HashMap<int, Habit>();

    final List<String>? habitIds = prefs.getStringList('habits');

    // If in debug mode, create some test habits.
    if (kDebugMode) {
      prefs.clear();

      // Longest Streak: 3, Current Streak: 1
      Habit testWeek = Habit(0, 'Week Test', Frequency.weekly, DurationType.hours, 2, [20250101, 20250108, 20250115, 20250201, 20250202, 20250214], 20250101);
      // Longest Streak: 3, Current Streak: 3
      Habit testMonth = Habit(1, 'Month Test', Frequency.monthly, DurationType.minutes, null, [20241101, 20241201, 20250101, 20250214], 20241001);
      
      Habit testDay = Habit(2, 'Day Test', Frequency.daily, DurationType.minutes, null, [20241101, 20241201, 20250101, 20250210, 20250211, 20250212, 20250213, 20250220, 20250221, 20250222], 20241001);

      userHabits.putIfAbsent(0, () => testWeek);
      userHabits.putIfAbsent(1, () => testMonth);
      userHabits.putIfAbsent(2, () => testDay);
    }

    if (habitIds == null ) {
      return userHabits;
    }

    for (var id in habitIds) {
      String? habitJsonData = prefs.getString(id);

      Habit habit = Habit.fromJson(habitJsonData!);

      userHabits.putIfAbsent(int.parse(id), () => habit);
    }

    return userHabits;
    
  }

  Future<HashMap<int, Habit>?> getUserHabitsFromStore(String path) async {
    try {
      String habitJsonData = await File(path).readAsString();
      HabitStore habitStore = HabitStore.fromJson(habitJsonData);

      HashMap<int, Habit> userHabits = HashMap<int, Habit>();

      for (var habit in habitStore.habits) {
        userHabits.putIfAbsent(habit.id, () => habit);
      }

      return userHabits;
    } catch (e) {
      return null;
    }
    
  }

  /// Update or add a Habit
  Future<void> updateHabit(Habit habit) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String habitId = habit.id.toString();

    List<String>? habitIds = prefs.getStringList('habits');

    if (habitIds == null) {
      habitIds = {habitId}.toList();
    } else {
      if (!habitIds.contains(habitId)) {
        habitIds.add(habitId);
      }
    }

    prefs.setStringList('habits', habitIds);

    String habitJsonData = habit.toJson();

    prefs.setString(habitId, habitJsonData);
  }

  /// Remove a Habit
  Future<void> removeHabit(Habit habit) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String habitId = habit.id.toString();

    List<String>? habitIds = prefs.getStringList('habits');

    if (habitIds == null) return;

    habitIds.remove(habitId);

    prefs.setStringList('habits', habitIds);

    prefs.remove(habitId);
  }
}