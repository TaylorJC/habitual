import 'dart:collection';

import 'package:habitual/systems/habit_data/habit_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service that stores and retrieves user habit data.
class HabitDataService {
  /// Loads the User's preferred ThemeMode from local or remote storage.
  Future<HashMap<int, Habit>> getUserHabits() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // prefs.clear();

    HashMap<int, Habit> userHabits = HashMap<int, Habit>();

    final List<String>? habitIds = prefs.getStringList('habits');

    if (habitIds == null ) {
      // // Longest Streak: 3, Current Streak: 1
      // Habit testWeek = Habit(0, 'Week Test', Frequency.weekly, DurationType.hours, 2, [20250101, 20250108, 20250115, 20250201, 20250202, 20250214], 20250101);
      // // Longest Streak: 3, Current Streak: 3
      // Habit testMonth = Habit(1, 'Month Test', Frequency.monthly, DurationType.minutes, null, [20241101, 20241201, 20250101, 20250214], 20241001);
      
      // userHabits.putIfAbsent(0, () => testWeek);
      // userHabits.putIfAbsent(1, () => testMonth);
      
      return userHabits;
    }

    for (var id in habitIds) {
      String? habitJsonData = prefs.getString(id);

      Habit habit = Habit.fromJson(habitJsonData!);

      userHabits.putIfAbsent(int.parse(id), () => habit);
    }

    return userHabits;
    
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