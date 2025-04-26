import 'dart:convert';
import 'dart:core';

import 'package:habitual/src/systems/habit_data/habit_model.dart';

class HabitStore {
  List<Habit> habits;

  HabitStore(this.habits);

  factory HabitStore.fromJson(String json) {
    Map<String, dynamic> habitData = jsonDecode(json);
    List<Habit> habits = List.empty(growable: true);

    for (var h in habitData['habits']) {
      habits.add(Habit.fromJson(h));
    }

    return HabitStore(habits);
  }

  String toJson() {
    return jsonEncode({
      'habits': habits,
    });
  }

}

