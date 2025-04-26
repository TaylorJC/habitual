import 'package:flutter/material.dart';
import 'package:habitual/src/systems/habit_data/habit_data_controller.dart';
import 'package:habitual/src/systems/settings/settings_controller.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:path_provider/path_provider.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({
    super.key,
    required this.settingsController,
    required this.habitDataController,
  });

  final SettingsController settingsController;
  final HabitDataController habitDataController;

  @override
  State<SettingsView> createState() {
    return SettingsViewState();
  }
}


class SettingsViewState extends State<SettingsView> with SingleTickerProviderStateMixin{
  final TextStyle optionStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold);
  final TextStyle titleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  final int colorCount = 4;

  late AnimationController _animationController;

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
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 600))..forward();

    super.initState();

  }

  @override
  void dispose() {
    _animationController.dispose();
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
                          runAlignment: WrapAlignment.center,
                          alignment: WrapAlignment.center,
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
                        runAlignment: WrapAlignment.start,
                          alignment: WrapAlignment.center,
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
                    Divider(
                      indent: 16,
                      endIndent: 16,
                    ),
                    ListTile(
                      title: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8.0,
                        runAlignment: WrapAlignment.center,
                        children: [
                          ElevatedButton.icon(style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
              ), onPressed: () {
                            showDialog<bool>(context: context, builder: (context) {
                              return AlertDialog(title: Text('Backup data?'), actionsAlignment: MainAxisAlignment.center, 
                              actions: [
                                ElevatedButton(onPressed: () {Navigator.of(context).pop(true);}, child: Text('Backup')),
                                ElevatedButton(onPressed: () {Navigator.of(context).pop(false);}, child: Text('Cancel')),
                              ],);
                            }).then( (result) async {
                              if (result != null && result) {
                                final savePath = await widget.habitDataController.exportHabits();

                                if (context.mounted) {
                                  // Display snackbar annoucing export
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('Success: Data exported to $savePath'),
                                  ));
                                }
                              }
                            });
                            // Ask where to save data
                          }, icon: Icon(Icons.download), label: Text('Backup Data', textAlign: TextAlign.center,)),
                          ElevatedButton.icon(style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.tertiaryContainer,
                foregroundColor: colorScheme.onTertiaryContainer,
              ), icon: Icon(Icons.upload), label: Text('Restore Data'), onPressed: () {
                            String? chosenPath;
                            showDialog<bool>(context: context, builder: (context) {
                              return AlertDialog(title: Text('Restore data from file?'), actionsAlignment: MainAxisAlignment.center, 
                              content: Text('Caution: This will overwrite your existing data.', style: TextStyle(color: Colors.red),),
                              actions: [
                                ElevatedButton(onPressed: () async {
                                  chosenPath = await FilesystemPicker.open(context: context, rootDirectory: await getApplicationDocumentsDirectory(), fsType: FilesystemType.file, title: 'Select data file', allowedExtensions: ['.json']);
                                  Navigator.of(context).pop(true);}, child: Text('Select File')),
                                ElevatedButton(onPressed: () {Navigator.of(context).pop(false);}, child: Text('Cancel')),
                              ],);
                            }).then( (result) async {
                              if (result != null && result && chosenPath != null) {
                                final didImport = await widget.habitDataController.importHabits(chosenPath!);

                                if (context.mounted) {
                                  if (didImport) {
                                    // Display snackbar annoucing import
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: const Text('Success: Data restored'),
                                  ));
                                  } else {
                                    // Display snackbar annoucing import
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: const Text('Error Bad Data: Data restoration failed'),
                                  ));
                                  }
                                  
                                }
                              }
                            });
                          })
                        ],
                      )
                    )
                  ],
                ),
            ),
      ),
    );
  }
}