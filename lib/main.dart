import 'package:flutter/material.dart';
import 'package:habitual/src/app.dart';

import 'package:habitual/src/systems/habit_data/habit_data_controller.dart';
import 'package:habitual/src/systems/habit_data/habit_data_service.dart';
import 'package:habitual/src/systems/settings/settings_controller.dart';
import 'package:habitual/src/systems/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SettingsController settingsController = SettingsController(SettingsService());
  final HabitDataController habitDataController = HabitDataController(HabitDataService());

  await settingsController.loadSettings();
  await habitDataController.loadHabits();

  runApp(Habitual(settingsController: settingsController, habitDataController: habitDataController,));
}