

import 'package:flutter/material.dart';
import 'package:habitual/systems/settings/settings_controller.dart';
import 'package:habitual/widgets/animations/slide_in.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  State<SettingsView> createState() {
    return SettingsViewState();
  }
}


class SettingsViewState extends State<SettingsView> {
  final TextStyle optionStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold);
  final TextStyle titleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  final int colorCount = 4;

  final List<String> colorChoiceNames = List.from(
    {
      'Amber',
      'Orange',
      'Red',
      'Everybody Rock The Dinosaur',
      'Purple',
      'Indigo',
      'Blue',
      'Teal',
      'Cyan',
      'Green',
    }
  );

  final List<Color> colorChoices = List.from(
    {
      Colors.amberAccent,
      Colors.orangeAccent,
      Colors.red,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blueAccent,
      Colors.teal,
      Colors.cyanAccent,
      Colors.green,
    }
  );

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SlideIn(
      slideInDirection: AxisDirection.right,
      animationCurve: Curves.fastEaseInToSlowEaseOut,
      child: Card(
        margin: EdgeInsets.all(24),
        child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                  children: [
                    ListTile(
                      // leading: 
                      //   ConstrainedBox(constraints: BoxConstraints(minWidth: 100), child: Text('Theme Mode', style: optionStyle)),
                      title:
                        Wrap(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ChoiceChip.elevated(
                                showCheckmark: false,
                                label: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    Icon(Icons.computer_rounded, color: colorScheme.primary,),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                                      child: Text('System', overflow: TextOverflow.fade,),
                                    ),
                                  ],
                                ), 
                                selected: ThemeMode.system == widget.settingsController.themeMode,
                                onSelected: (bool selected) {
                                  selected ? widget.settingsController.updateThemeMode(ThemeMode.system) : null;
                                },
                              )
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ChoiceChip.elevated(
                                showCheckmark: false,
                                label: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    Icon(Icons.dark_mode, color: colorScheme.primary,),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                                      child: Text('Dark', overflow: TextOverflow.fade,),
                                    ),
                                  ],
                                ), 
                                selected: ThemeMode.dark == widget.settingsController.themeMode,
                                onSelected: (bool selected) {
                                  selected ? widget.settingsController.updateThemeMode(ThemeMode.dark) : null;
                                },
                              )
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ChoiceChip.elevated(
                                showCheckmark: false,
                                label: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    Icon(Icons.light_mode, color: colorScheme.primary,),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                                      child: Text('Light', overflow: TextOverflow.fade,),
                                    ),
                                  ],
                                ),
                                selected: ThemeMode.light == widget.settingsController.themeMode,
                                onSelected: (bool selected) {
                                  selected ? widget.settingsController.updateThemeMode(ThemeMode.light) : null;
                                },
                              )
                            ),
                          ],
                        ),
                    ),
                    Divider(
                      indent: 16,
                      endIndent: 16,
                    ),
                    ListTile(
                      // leading: 
                      //   ConstrainedBox(constraints: BoxConstraints(minWidth: 100), child: Text('Theme Color', style: optionStyle)),
                      title: Wrap(
                        children: List<Widget>.generate(
                          colorChoiceNames.length,
                          (int index) {
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ChoiceChip.elevated(
                                showCheckmark: false,
                                label: Text(colorChoiceNames[index]), 
                                selected: colorChoices[index] == widget.settingsController.themeColor,
                                onSelected: (bool selected) {
                                  selected ? widget.settingsController.updateThemeColor(colorChoices[index]) : null;
                                },
                              ),
                            );
                          }),
                        ),
                    ),
                  ],
                ),
            ),
      ),
    );
  }
}