import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:habitual/src/datetime_parse.dart';
import 'package:habitual/src/systems/habit_data/habit_model.dart';

enum HistoryView { heatmap, calendar }

class HabitHistoryView extends StatefulWidget {
  const HabitHistoryView({
    super.key,
    required this.habit,
    required this.onClose,
    required this.onEdit,
  });

  final Habit habit;
  final Function onClose;
  final Function onEdit;

  @override
  State<HabitHistoryView> createState() => _HabitHistoryViewState();
}

class _HabitHistoryViewState extends State<HabitHistoryView>
    with TickerProviderStateMixin {
  HistoryView view = HistoryView.heatmap;

  late AnimationController _animationController;
  late AnimationController _viewTransitionController;
  late ScrollController _scrollController;

  late ColorScheme colorScheme;
  late Map<DateTime, int> dataset = {};

  @override
  void initState() {
    _scrollController = ScrollController();

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600))
          ..forward();

    _viewTransitionController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400))
          ..forward();

    for (var date in widget.habit.datesCompleted) {
      dataset.putIfAbsent(intToDateTime(date).toLocal(), () => 1);
    }
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _viewTransitionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: 600,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final animationPercent =
                  Curves.fastOutSlowIn.transform(_animationController.value);
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
            child: Card(
              color: colorScheme.surfaceContainer,
              margin: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        widget.onClose();
                      },
                      label: Icon(Icons.close, color: colorScheme.onSurface),
                    ),
                  ),
                  Text(widget.habit.title,
                      maxLines: 2,
                      style: TextStyle(
                          color: colorScheme.onPrimaryContainer, fontSize: 16)),
                  if (widget.habit.duration != null)
                    Text(
                        '${widget.habit.duration} ${widget.habit.durationType.name}',
                        maxLines: 2,
                        style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontSize: 12)),
                  Divider(
                    color: colorScheme.primary,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SegmentedButton<HistoryView>(
                      segments: [
                        ButtonSegment<HistoryView>(
                          value: HistoryView.heatmap,
                          label: Text('Heatmap'),
                          icon: Icon(Icons.grid_on),
                        ),
                        ButtonSegment<HistoryView>(
                          value: HistoryView.calendar,
                          label: Text('Calendar'),
                          icon: Icon(Icons.calendar_month),
                        ),
                      ],
                      selected: <HistoryView>{view},
                      onSelectionChanged: (p0) {
                        setState(() {
                          view = p0.first;
                        });
                        _viewTransitionController.forward(from: 0.0);
                      },
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _viewTransitionController,
                    builder: (context, child) {
                      final animationPercent = Curves.easeOut
                          .transform(_viewTransitionController.value);
                      final opacity = _viewTransitionController.value;
                      final slideDistance = view == HistoryView.calendar
                          ? (1.0 - animationPercent) * 150
                          : (-1.0 + animationPercent) * 150;

                      return Opacity(
                        opacity: opacity,
                        child: Transform.translate(
                          offset: Offset(slideDistance, 0),
                          child: child,
                        ),
                      );
                    },
                    child: view == HistoryView.calendar
                        ? HeatMapCalendar(
                            borderRadius: 48,
                            datasets: dataset,
                            showColorTip: false,
                            fontSize: 14,
                            size: 26,
                            monthFontSize: 14,
                            weekFontSize: 12,
                            defaultColor: colorScheme.surfaceContainer,
                            colorsets: {1: colorScheme.primary},
                            textColor: colorScheme.onSurface,
                          )
                        : GestureDetector(
                            onHorizontalDragUpdate: (details) {
                              _scrollController.jumpTo(
                                  _scrollController.offset -
                                      details.primaryDelta!);
                            },
                            child: Scrollbar(
                              thumbVisibility: true,
                              interactive: true,
                              scrollbarOrientation: ScrollbarOrientation.bottom,
                              controller: _scrollController,
                              radius: Radius.circular(16.0),
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                reverse: true,
                                scrollDirection: Axis.horizontal,
                                child: HeatMap(
                                  startDate:
                                      intToDateTime(widget.habit.dateCreated),
                                  endDate: DateTime.now(),
                                  borderRadius: 48,
                                  showText: true,
                                  datasets: dataset,
                                  fontSize: 14,
                                  size: 24,
                                  defaultColor: colorScheme.surfaceContainer,
                                  scrollable: false,
                                  showColorTip: false,
                                  colorsets: {1: colorScheme.primary},
                                  textColor: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                  ),
                  Divider(
                    color: colorScheme.primary,
                    thickness: 1,
                    indent: 24,
                    endIndent: 24,
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(16.0, 4, 16, 16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        color: colorScheme.primaryContainer),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.bar_chart_rounded,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                      Text(
                                        'Current: ${widget.habit.getCurrentStreak()}',
                                        style: TextStyle(
                                          color: colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Icon(Icons.bar_chart_rounded,
                                          color:
                                              colorScheme.onPrimaryContainer),
                                      Text(
                                        'Longest: ${widget.habit.getLongestStreak()}',
                                        style: TextStyle(
                                          color: colorScheme.onPrimaryContainer,
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
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Date Created: ${dateTimeIntToYMDString(widget.habit.dateCreated)}',
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
